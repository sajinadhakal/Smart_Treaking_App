"""
Greedy Algorithm Service

Implements greedy algorithms for budget optimization.
For TU BCA 6th Semester - Data Structures & Algorithms
"""

import time
from typing import List, Dict, Any


class GreedyService:
    """Service class for greedy algorithms"""
    
    @staticmethod
    def maximize_trips_in_budget(destinations: List[Dict], budget: float) -> Dict[str, Any]:
        """
        Greedy Algorithm: Maximize number of trips within budget
        Strategy: Sort by price (ascending) and select cheapest trips first
        
        Time Complexity: O(n log n)
        Space Complexity: O(n)
        
        Args:
            destinations: List of destination dictionaries
            budget: Maximum budget
        
        Returns:
            Dictionary with selected trips, steps, and metadata
        """
        start_time = time.time()
        steps = []
        
        # Sort by price (greedy choice: cheapest first)
        sorted_dests = sorted(destinations, key=lambda x: float(x.get('price', 0)))
        
        steps.append({
            'step': 1,
            'action': 'sort',
            'strategy': 'Sort destinations by price (ascending)',
            'total_destinations': len(sorted_dests)
        })
        
        selected = []
        remaining_budget = budget
        total_cost = 0
        
        for i, dest in enumerate(sorted_dests):
            price = float(dest.get('price', 0))
            
            steps.append({
                'step': len(steps) + 1,
                'action': 'consider',
                'destination': dest.get('name'),
                'price': price,
                'remaining_budget': remaining_budget
            })
            
            if price <= remaining_budget:
                selected.append(dest)
                remaining_budget -= price
                total_cost += price
                
                steps.append({
                    'step': len(steps) + 1,
                    'action': 'select',
                    'destination': dest.get('name'),
                    'price': price,
                    'new_remaining': remaining_budget,
                    'total_selected': len(selected)
                })
            else:
                steps.append({
                    'step': len(steps) + 1,
                    'action': 'skip',
                    'destination': dest.get('name'),
                    'reason': f'Price {price} exceeds remaining budget {remaining_budget}'
                })
        
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': 'Greedy - Maximize Trips in Budget',
            'strategy': 'Select cheapest trips first',
            'budget': budget,
            'total_cost': round(total_cost, 2),
            'remaining_budget': round(remaining_budget, 2),
            'selected_trips': selected,
            'total_trips_selected': len(selected),
            'steps': steps,
            'time_complexity': 'O(n log n)',
            'space_complexity': 'O(n)',
            'execution_time_ms': round(execution_time, 4),
            'is_optimal': True,
            'description': 'Maximizes number of trips by selecting cheapest options first',
            'pseudocode': [
                'sort destinations by price (ascending)',
                'selected = []',
                'remaining = budget',
                'for each destination in sorted order:',
                '    if destination.price <= remaining:',
                '        add destination to selected',
                '        remaining -= destination.price',
                'return selected'
            ]
        }
    
    @staticmethod
    def maximize_value_in_budget(destinations: List[Dict], budget: float) -> Dict[str, Any]:
        """
        Greedy Algorithm: Maximize value (rating * days) within budget
        Strategy: Sort by value-to-cost ratio
        
        Time Complexity: O(n log n)
        Space Complexity: O(n)
        
        Args:
            destinations: List of destination dictionaries
            budget: Maximum budget
        
        Returns:
            Dictionary with selected trips, steps, and metadata
        """
        start_time = time.time()
        steps = []
        
        # Calculate value-to-cost ratio for each destination
        enriched_dests = []
        for dest in destinations:
            price = float(dest.get('price', 1))
            rating = float(dest.get('average_rating', 0))
            days = int(dest.get('duration_days', 1))
            value = rating * days
            ratio = value / price if price > 0 else 0
            
            enriched_dests.append({
                **dest,
                'value': value,
                'value_to_cost_ratio': ratio
            })
        
        # Sort by value-to-cost ratio (greedy choice: best ratio first)
        sorted_dests = sorted(enriched_dests, key=lambda x: x['value_to_cost_ratio'], reverse=True)
        
        steps.append({
            'step': 1,
            'action': 'calculate_ratios',
            'strategy': 'Calculate value/cost ratio (rating × days / price)',
            'total_destinations': len(sorted_dests)
        })
        
        selected = []
        remaining_budget = budget
        total_cost = 0
        total_value = 0
        
        for dest in sorted_dests:
            price = float(dest.get('price', 0))
            value = dest['value']
            ratio = dest['value_to_cost_ratio']
            
            steps.append({
                'step': len(steps) + 1,
                'action': 'consider',
                'destination': dest.get('name'),
                'price': price,
                'value': round(value, 2),
                'ratio': round(ratio, 4),
                'remaining_budget': remaining_budget
            })
            
            if price <= remaining_budget:
                selected.append(dest)
                remaining_budget -= price
                total_cost += price
                total_value += value
                
                steps.append({
                    'step': len(steps) + 1,
                    'action': 'select',
                    'destination': dest.get('name'),
                    'price': price,
                    'value_gained': round(value, 2),
                    'new_remaining': remaining_budget
                })
            else:
                steps.append({
                    'step': len(steps) + 1,
                    'action': 'skip',
                    'destination': dest.get('name'),
                    'reason': f'Price {price} exceeds remaining budget'
                })
        
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': 'Greedy - Maximize Value in Budget',
            'strategy': 'Select highest value/cost ratio first',
            'budget': budget,
            'total_cost': round(total_cost, 2),
            'total_value': round(total_value, 2),
            'remaining_budget': round(remaining_budget, 2),
            'selected_trips': selected,
            'total_trips_selected': len(selected),
            'steps': steps,
            'time_complexity': 'O(n log n)',
            'space_complexity': 'O(n)',
            'execution_time_ms': round(execution_time, 4),
            'is_optimal': False,
            'description': 'Approximates optimal solution using value/cost ratio (fractional knapsack approach)',
            'note': 'Not guaranteed optimal for 0/1 knapsack (use DP for optimal)',
            'pseudocode': [
                'for each destination:',
                '    calculate value = rating × days',
                '    calculate ratio = value / price',
                'sort by ratio (descending)',
                'selected = []',
                'remaining = budget',
                'for each destination in sorted order:',
                '    if destination.price <= remaining:',
                '        add to selected',
                '        remaining -= price',
                'return selected'
            ]
        }
