"""
Dynamic Programming Service

Implements DP algorithms for optimal trip planning.
For TU BCA 6th Semester - Data Structures & Algorithms
"""

import time
from typing import List, Dict, Any, Tuple


class DynamicProgrammingService:
    """Service class for dynamic programming algorithms"""
    
    @staticmethod
    def knapsack_trip_planner(
        destinations: List[Dict],
        budget: float,
        max_days: int = None
    ) -> Dict[str, Any]:
        """
        0/1 Knapsack Dynamic Programming for optimal trip selection
        Maximizes total value (rating × days) within budget and time constraints
        
        Time Complexity: O(n * W) where W is budget
        Space Complexity: O(n * W)
        
        Args:
            destinations: List of destination dictionaries
            budget: Maximum budget
            max_days: Maximum days available (optional)
        
        Returns:
            Dictionary with optimal trips, DP table, steps, and metadata
        """
        start_time = time.time()
        steps = []
        
        # Prepare items
        items = []
        for dest in destinations:
            price = int(float(dest.get('price', 0)))
            rating = float(dest.get('average_rating', 0))
            days = int(dest.get('duration_days', 1))
            
            # Skip if exceeds max_days
            if max_days and days > max_days:
                continue
            
            value = int(rating * days * 100)  # Scale for integer DP
            items.append({
                'destination': dest,
                'price': price,
                'days': days,
                'value': value,
                'name': dest.get('name')
            })
        
        n = len(items)
        W = int(budget)
        
        steps.append({
            'step': 1,
            'action': 'initialize',
            'items_count': n,
            'budget': W,
            'max_days': max_days,
            'table_size': f'{n+1} × {W+1}'
        })
        
        # Create DP table
        dp = [[0 for _ in range(W + 1)] for _ in range(n + 1)]
        
        # Build table
        for i in range(1, n + 1):
            item = items[i - 1]
            price = item['price']
            value = item['value']
            
            for w in range(W + 1):
                # Don't include current item
                dp[i][w] = dp[i-1][w]
                
                # Include current item if it fits
                if price <= w:
                    include_value = dp[i-1][w-price] + value
                    if include_value > dp[i][w]:
                        dp[i][w] = include_value
                        
                        if w % 10000 == 0:  # Log key steps only
                            steps.append({
                                'step': len(steps) + 1,
                                'action': 'include_item',
                                'item': item['name'],
                                'budget': w,
                                'value': value,
                                'total_value': dp[i][w]
                            })
        
        # Backtrack to find selected items
        selected_items = []
        w = W
        total_cost = 0
        total_days = 0
        total_value = dp[n][W]
        
        steps.append({
            'step': len(steps) + 1,
            'action': 'backtrack_start',
            'optimal_value': total_value
        })
        
        for i in range(n, 0, -1):
            if dp[i][w] != dp[i-1][w]:
                item = items[i-1]
                selected_items.append(item['destination'])
                w -= item['price']
                total_cost += item['price']
                total_days += item['days']
                
                steps.append({
                    'step': len(steps) + 1,
                    'action': 'select_item',
                    'destination': item['name'],
                    'price': item['price'],
                    'days': item['days'],
                    'value': item['value']
                })
        
        selected_items.reverse()
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': '0/1 Knapsack Dynamic Programming',
            'budget': budget,
            'max_days': max_days,
            'total_cost': total_cost,
            'total_days': total_days,
            'total_value': total_value / 100,  # Descale
            'remaining_budget': budget - total_cost,
            'selected_trips': selected_items,
            'total_trips_selected': len(selected_items),
            'steps': steps[:50],  # Limit steps for API response
            'dp_table_size': f'{n+1} rows × {W+1} columns',
            'time_complexity': 'O(n × W)',
            'space_complexity': 'O(n × W)',
            'execution_time_ms': round(execution_time, 4),
            'is_optimal': True,
            'description': 'Finds optimal combination of trips maximizing value within constraints',
            'pseudocode': [
                'create DP table dp[n+1][W+1]',
                'initialize dp[0][w] = 0 for all w',
                'for i from 1 to n:',
                '    for w from 0 to W:',
                '        dp[i][w] = dp[i-1][w]  // exclude item',
                '        if item[i].price <= w:',
                '            include = dp[i-1][w-price[i]] + value[i]',
                '            dp[i][w] = max(dp[i][w], include)',
                'backtrack from dp[n][W] to find selected items',
                'return selected items'
            ]
        }
    
    @staticmethod
    def maximize_destinations_in_days(
        destinations: List[Dict],
        max_days: int,
        budget: float = None
    ) -> Dict[str, Any]:
        """
        DP Algorithm: Maximize number of destinations in limited days
        Similar to unbounded knapsack
        
        Time Complexity: O(n * D) where D is max_days
        Space Complexity: O(D)
        
        Args:
            destinations: List of destination dictionaries
            max_days: Maximum days available
            budget: Maximum budget (optional filter)
        
        Returns:
            Dictionary with optimal trips and metadata
        """
        start_time = time.time()
        steps = []
        
        # Filter by budget if provided
        filtered = destinations
        if budget:
            filtered = [d for d in destinations if float(d.get('price', 0)) <= budget]
        
        # Sort by duration for easier processing
        sorted_dests = sorted(filtered, key=lambda x: int(x.get('duration_days', 1)))
        
        steps.append({
            'step': 1,
            'action': 'initialize',
            'max_days': max_days,
            'budget': budget,
            'available_destinations': len(sorted_dests)
        })
        
        # DP array: dp[d] = max destinations possible in d days
        dp = [0] * (max_days + 1)
        selected = [[] for _ in range(max_days + 1)]
        
        for day in range(1, max_days + 1):
            for dest in sorted_dests:
                duration = int(dest.get('duration_days', 1))
                
                if duration <= day:
                    new_count = dp[day - duration] + 1
                    
                    if new_count > dp[day]:
                        dp[day] = new_count
                        selected[day] = selected[day - duration] + [dest]
                        
                        steps.append({
                            'step': len(steps) + 1,
                            'action': 'update',
                            'days_available': day,
                            'destination': dest.get('name'),
                            'duration': duration,
                            'new_count': new_count
                        })
        
        optimal_trips = selected[max_days]
        total_days_used = sum(int(d.get('duration_days', 0)) for d in optimal_trips)
        total_cost = sum(float(d.get('price', 0)) for d in optimal_trips)
        
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': 'DP - Maximize Destinations in Days',
            'max_days': max_days,
            'budget': budget,
            'total_days_used': total_days_used,
            'remaining_days': max_days - total_days_used,
            'total_cost': round(total_cost, 2),
            'selected_trips': optimal_trips,
            'total_trips_selected': len(optimal_trips),
            'steps': steps[:50],
            'time_complexity': 'O(n × D)',
            'space_complexity': 'O(D)',
            'execution_time_ms': round(execution_time, 4),
            'is_optimal': True,
            'description': 'Maximizes number of destinations that fit in available days',
            'pseudocode': [
                'create dp[max_days + 1] = 0',
                'for d from 1 to max_days:',
                '    for each destination:',
                '        if destination.days <= d:',
                '            new_count = dp[d - destination.days] + 1',
                '            if new_count > dp[d]:',
                '                dp[d] = new_count',
                '                update selected[d]',
                'return selected[max_days]'
            ]
        }
