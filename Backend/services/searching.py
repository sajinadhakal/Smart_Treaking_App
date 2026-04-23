"""
Searching Algorithms Service

Implements Linear Search and Binary Search with step tracking.
For TU BCA 6th Semester - Data Structures & Algorithms
"""

import time
from typing import List, Dict, Any, Tuple


class SearchingService:
    """Service class for search algorithms"""
    
    @staticmethod
    def linear_search(data: List[Dict], query: str, key: str = 'name') -> Dict[str, Any]:
        """
        Linear Search Algorithm
        Time Complexity: O(n)
        Space Complexity: O(1)
        
        Args:
            data: List of dictionaries to search
            query: Search query
            key: Key to search in (default: 'name')
        
        Returns:
            Dictionary with result, steps, and metadata
        """
        start_time = time.time()
        steps = []
        comparisons = 0
        
        query_lower = query.lower()
        result = None
        
        for i, item in enumerate(data):
            comparisons += 1
            item_value = str(item.get(key, '')).lower()
            
            steps.append({
                'step': comparisons,
                'action': 'compare',
                'index': i,
                'value': item.get(key),
                'query': query,
                'match': query_lower in item_value
            })
            
            if query_lower in item_value:
                result = item
                steps.append({
                    'step': comparisons + 1,
                    'action': 'found',
                    'index': i,
                    'result': item
                })
                break
        
        if not result and data:
            steps.append({
                'step': comparisons + 1,
                'action': 'not_found',
                'message': f'Query "{query}" not found in {len(data)} items'
            })
        
        execution_time = (time.time() - start_time) * 1000  # Convert to ms
        
        return {
            'algorithm': 'Linear Search',
            'result': result,
            'found': result is not None,
            'steps': steps,
            'comparisons': comparisons,
            'time_complexity': 'O(n)',
            'space_complexity': 'O(1)',
            'execution_time_ms': round(execution_time, 4),
            'total_items': len(data),
            'pseudocode': [
                'for each item in list:',
                '    if item matches query:',
                '        return item',
                'return not found'
            ]
        }
    
    @staticmethod
    def binary_search(data: List[Dict], query: str, key: str = 'name') -> Dict[str, Any]:
        """
        Binary Search Algorithm (requires sorted data)
        Time Complexity: O(log n)
        Space Complexity: O(1)
        
        Args:
            data: List of dictionaries to search (must be sorted)
            query: Search query
            key: Key to search in (default: 'name')
        
        Returns:
            Dictionary with result, steps, and metadata
        """
        start_time = time.time()
        steps = []
        comparisons = 0
        
        # Sort data first
        sorted_data = sorted(data, key=lambda x: str(x.get(key, '')).lower())
        query_lower = query.lower()
        
        left = 0
        right = len(sorted_data) - 1
        result = None
        
        while left <= right:
            mid = (left + right) // 2
            comparisons += 1
            mid_value = str(sorted_data[mid].get(key, '')).lower()
            
            steps.append({
                'step': comparisons,
                'action': 'compare',
                'left': left,
                'right': right,
                'mid': mid,
                'mid_value': sorted_data[mid].get(key),
                'query': query
            })
            
            if query_lower in mid_value:
                result = sorted_data[mid]
                steps.append({
                    'step': comparisons + 1,
                    'action': 'found',
                    'index': mid,
                    'result': result
                })
                break
            elif mid_value < query_lower:
                left = mid + 1
                steps.append({
                    'step': comparisons + 1,
                    'action': 'search_right',
                    'message': 'Query is greater, search right half'
                })
            else:
                right = mid - 1
                steps.append({
                    'step': comparisons + 1,
                    'action': 'search_left',
                    'message': 'Query is smaller, search left half'
                })
        
        if not result:
            steps.append({
                'step': comparisons + 1,
                'action': 'not_found',
                'message': f'Query "{query}" not found'
            })
        
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': 'Binary Search',
            'result': result,
            'found': result is not None,
            'steps': steps,
            'comparisons': comparisons,
            'time_complexity': 'O(log n)',
            'space_complexity': 'O(1)',
            'execution_time_ms': round(execution_time, 4),
            'total_items': len(data),
            'efficiency_gain': f'{len(data) - comparisons} comparisons saved vs linear search',
            'pseudocode': [
                'sort the list',
                'left = 0, right = n-1',
                'while left <= right:',
                '    mid = (left + right) / 2',
                '    if arr[mid] == query:',
                '        return found',
                '    elif arr[mid] < query:',
                '        left = mid + 1',
                '    else:',
                '        right = mid - 1',
                'return not found'
            ]
        }
