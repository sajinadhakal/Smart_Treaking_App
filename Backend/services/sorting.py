"""
Sorting Algorithms Service

Implements Merge Sort and Quick Sort with step tracking.
For TU BCA 6th Semester - Data Structures & Algorithms
"""

import time
from typing import List, Dict, Any


class SortingService:
    """Service class for sorting algorithms"""
    
    @staticmethod
    def merge_sort(data: List[Dict], key: str = 'price', reverse: bool = False) -> Dict[str, Any]:
        """
        Merge Sort Algorithm
        Time Complexity: O(n log n)
        Space Complexity: O(n)
        
        Args:
            data: List of dictionaries to sort
            key: Key to sort by
            reverse: Sort in descending order if True
        
        Returns:
            Dictionary with sorted result, steps, and metadata
        """
        start_time = time.time()
        steps = []
        comparisons = 0
        
        def merge_sort_recursive(arr: List[Dict], depth: int = 0) -> List[Dict]:
            nonlocal comparisons, steps
            
            if len(arr) <= 1:
                return arr
            
            mid = len(arr) // 2
            steps.append({
                'step': len(steps) + 1,
                'action': 'divide',
                'depth': depth,
                'size': len(arr),
                'mid': mid,
                'message': f'Dividing array of size {len(arr)} at index {mid}'
            })
            
            left = merge_sort_recursive(arr[:mid], depth + 1)
            right = merge_sort_recursive(arr[mid:], depth + 1)
            
            return merge(left, right, depth)
        
        def merge(left: List[Dict], right: List[Dict], depth: int) -> List[Dict]:
            nonlocal comparisons, steps
            
            result = []
            i = j = 0
            
            steps.append({
                'step': len(steps) + 1,
                'action': 'merge',
                'depth': depth,
                'left_size': len(left),
                'right_size': len(right),
                'message': f'Merging arrays of size {len(left)} and {len(right)}'
            })
            
            while i < len(left) and j < len(right):
                comparisons += 1
                left_val = left[i].get(key, 0)
                right_val = right[j].get(key, 0)
                
                if (left_val <= right_val) if not reverse else (left_val >= right_val):
                    result.append(left[i])
                    i += 1
                else:
                    result.append(right[j])
                    j += 1
            
            result.extend(left[i:])
            result.extend(right[j:])
            
            return result
        
        sorted_data = merge_sort_recursive(data.copy())
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': 'Merge Sort',
            'result': sorted_data,
            'steps': steps,
            'comparisons': comparisons,
            'sorted_by': key,
            'order': 'descending' if reverse else 'ascending',
            'time_complexity': 'O(n log n)',
            'space_complexity': 'O(n)',
            'execution_time_ms': round(execution_time, 4),
            'total_items': len(data),
            'pseudocode': [
                'function mergeSort(arr):',
                '    if length(arr) <= 1:',
                '        return arr',
                '    mid = length(arr) / 2',
                '    left = mergeSort(arr[0...mid])',
                '    right = mergeSort(arr[mid...end])',
                '    return merge(left, right)',
                '',
                'function merge(left, right):',
                '    result = []',
                '    while left and right have elements:',
                '        if left[0] < right[0]:',
                '            append left[0] to result',
                '        else:',
                '            append right[0] to result',
                '    append remaining elements',
                '    return result'
            ]
        }
    
    @staticmethod
    def quick_sort(data: List[Dict], key: str = 'price', reverse: bool = False) -> Dict[str, Any]:
        """
        Quick Sort Algorithm
        Time Complexity: O(n log n) average, O(n²) worst case
        Space Complexity: O(log n)
        
        Args:
            data: List of dictionaries to sort
            key: Key to sort by
            reverse: Sort in descending order if True
        
        Returns:
            Dictionary with sorted result, steps, and metadata
        """
        start_time = time.time()
        steps = []
        comparisons = 0
        swaps = 0
        
        def quick_sort_recursive(arr: List[Dict], low: int, high: int, depth: int = 0):
            nonlocal comparisons, swaps, steps
            
            if low < high:
                pivot_index = partition(arr, low, high, depth)
                quick_sort_recursive(arr, low, pivot_index - 1, depth + 1)
                quick_sort_recursive(arr, pivot_index + 1, high, depth + 1)
        
        def partition(arr: List[Dict], low: int, high: int, depth: int) -> int:
            nonlocal comparisons, swaps, steps
            
            pivot = arr[high].get(key, 0)
            steps.append({
                'step': len(steps) + 1,
                'action': 'select_pivot',
                'depth': depth,
                'pivot_index': high,
                'pivot_value': pivot,
                'range': f'[{low}...{high}]'
            })
            
            i = low - 1
            
            for j in range(low, high):
                comparisons += 1
                current_val = arr[j].get(key, 0)
                
                should_swap = (current_val <= pivot) if not reverse else (current_val >= pivot)
                
                if should_swap:
                    i += 1
                    arr[i], arr[j] = arr[j], arr[i]
                    swaps += 1
                    
                    steps.append({
                        'step': len(steps) + 1,
                        'action': 'swap',
                        'depth': depth,
                        'indices': [i, j],
                        'values': [arr[i].get(key), arr[j].get(key)]
                    })
            
            arr[i + 1], arr[high] = arr[high], arr[i + 1]
            swaps += 1
            
            steps.append({
                'step': len(steps) + 1,
                'action': 'place_pivot',
                'depth': depth,
                'pivot_final_position': i + 1
            })
            
            return i + 1
        
        sorted_data = data.copy()
        quick_sort_recursive(sorted_data, 0, len(sorted_data) - 1)
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': 'Quick Sort',
            'result': sorted_data,
            'steps': steps,
            'comparisons': comparisons,
            'swaps': swaps,
            'sorted_by': key,
            'order': 'descending' if reverse else 'ascending',
            'time_complexity': 'O(n log n) average, O(n²) worst',
            'space_complexity': 'O(log n)',
            'execution_time_ms': round(execution_time, 4),
            'total_items': len(data),
            'pseudocode': [
                'function quickSort(arr, low, high):',
                '    if low < high:',
                '        pivot = partition(arr, low, high)',
                '        quickSort(arr, low, pivot-1)',
                '        quickSort(arr, pivot+1, high)',
                '',
                'function partition(arr, low, high):',
                '    pivot = arr[high]',
                '    i = low - 1',
                '    for j from low to high-1:',
                '        if arr[j] < pivot:',
                '            i++',
                '            swap arr[i] and arr[j]',
                '    swap arr[i+1] and arr[high]',
                '    return i+1'
            ]
        }
