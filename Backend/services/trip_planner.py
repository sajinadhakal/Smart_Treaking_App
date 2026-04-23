"""
Trip planner algorithm service.

Implements 0/1 Knapsack Dynamic Programming for selecting an optimal
set of treks under budget and day constraints.
"""

from decimal import Decimal
from typing import Any, Dict, List


class TripPlannerService:
    USD_TO_NPR = Decimal('133.00')

    @staticmethod
    def optimize_itinerary(
        treks: List[Dict[str, Any]],
        user_budget: int,
        max_days: int,
    ) -> Dict[str, Any]:
        """
        0/1 Knapsack DP implementation.

        - Capacity (W): user_budget
        - Weight: trek cost
        - Value: trek rating * trek duration_days

        Time Complexity: O(n * W)
            n = number of treks
            W = user budget (integer NPR capacity)
        Space Complexity: O(n * W)
            Uses a 2D DP table for deterministic backtracking.
        """
        if user_budget <= 0 or max_days <= 0 or not treks:
            return {
                'selected_treks': [],
                'total_cost': 0,
                'total_days': 0,
                'total_value': 0,
            }

        filtered_treks = [
            trek for trek in treks
            if trek.get('duration_days', 0) <= max_days and trek.get('cost', 0) <= user_budget
        ]

        if not filtered_treks:
            return {
                'selected_treks': [],
                'total_cost': 0,
                'total_days': 0,
                'total_value': 0,
            }

        item_count = len(filtered_treks)
        capacity = int(user_budget)

        # dp[i][w] = best achievable value using first i items and budget w.
        dp = [[0.0] * (capacity + 1) for _ in range(item_count + 1)]

        for index in range(1, item_count + 1):
            trek = filtered_treks[index - 1]
            weight = int(trek['cost'])
            value = float(trek['rating']) * int(trek['duration_days'])

            for budget in range(capacity + 1):
                # Option 1: exclude current trek.
                exclude_value = dp[index - 1][budget]

                # Option 2: include current trek if affordable.
                include_value = 0.0
                if weight <= budget:
                    include_value = dp[index - 1][budget - weight] + value

                # Pick local optimum to build global optimum solution.
                dp[index][budget] = max(exclude_value, include_value)

        selected_treks: List[Dict[str, Any]] = []
        remaining_budget = capacity
        for index in range(item_count, 0, -1):
            if dp[index][remaining_budget] != dp[index - 1][remaining_budget]:
                chosen_trek = filtered_treks[index - 1]
                selected_treks.append(chosen_trek)
                remaining_budget -= int(chosen_trek['cost'])

        selected_treks.reverse()

        total_cost = sum(int(trek['cost']) for trek in selected_treks)
        total_days = sum(int(trek['duration_days']) for trek in selected_treks)
        total_value = round(sum(float(trek['rating']) * int(trek['duration_days']) for trek in selected_treks), 2)

        return {
            'selected_treks': selected_treks,
            'total_cost': total_cost,
            'total_days': total_days,
            'total_value': total_value,
        }

    @staticmethod
    def is_safe_acclimatization(altitudes: List[int]) -> bool:
        """
        Acclimatization Safety Guard rule.

        High risk if altitude jump is >500m and destination point is >3000m.

        Time Complexity: O(n)
        Space Complexity: O(1)
        """
        for index in range(1, len(altitudes)):
            jump = altitudes[index] - altitudes[index - 1]
            if jump > 500 and altitudes[index] > 3000:
                return False
        return True

    @classmethod
    def calculate_cash_required_npr(
        cls,
        duration_days: int,
        number_of_people: int,
        base_cost: Decimal,
        permit_cost: Decimal,
    ) -> float:
        """
        Cash-only logistics formula.

        total_cash = (duration_days * daily_teahouse_average) + permit_fees + 20% buffer
        where daily_teahouse_average is inferred from base_cost and trip composition.
        """
        days = max(int(duration_days or 1), 1)
        people = max(int(number_of_people or 1), 1)

        daily_teahouse_avg_usd = (Decimal(base_cost) / Decimal(days)) / Decimal(people)
        total_teahouse_usd = daily_teahouse_avg_usd * Decimal(days) * Decimal(people)
        cash_usd = (total_teahouse_usd + Decimal(permit_cost)) * Decimal('1.20')
        cash_npr = cash_usd * cls.USD_TO_NPR
        return float(cash_npr.quantize(Decimal('0.01')))
