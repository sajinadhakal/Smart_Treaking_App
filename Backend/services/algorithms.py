"""
Core DSA Algorithms for Nepal Trekking App
Implements: Dijkstra's, 0/1 Knapsack, Binary Search, Quick Sort, Merge Sort
Each algorithm includes execution_steps for visualization on frontend.

Time & Space Complexity noted for viva defense.
"""

import heapq
import json
from typing import List, Dict, Tuple, Optional
from decimal import Decimal


class KnapsackAlgorithm:
    """
    0/1 Knapsack Problem: Maximize trek quality/rating within budget and days constraints.
    
    Problem Statement:
    - User has max_budget (USD) and max_days (integer)
    - Each detour has: cost, days_required, quality_rating
    - Goal: Select detours to maximize total quality_rating without exceeding budget or days
    
    Time Complexity: O(n * W) where n = number of detours, W = max_budget
    Space Complexity: O(n * W) for DP table
    """
    
    def __init__(self):
        self.execution_steps = []
    
    def solve(self, detours: List[Dict], max_budget: float, max_days: int) -> Dict:
        """
        Solve 0/1 Knapsack for trek optimization.
        
        Args:
            detours: List of {name, cost, days, quality_rating}
            max_budget: Maximum budget in USD
            max_days: Maximum days available
        
        Returns:
            {
                selected_detours: List[Dict],
                total_cost: float,
                total_days: int,
                total_quality: float,
                execution_steps: List[str]
            }
        """
        self.execution_steps = []
        n = len(detours)
        
        step = f"Starting 0/1 Knapsack: {n} detours, Budget=${max_budget}, Days={max_days}"
        self.execution_steps.append(step)
        
        # Convert to integer budget for DP (multiply by 100 to handle decimals)
        w = int(max_budget * 100)
        
        # DP table: dp[i][j] = (max_quality, total_days)
        dp = [[None for _ in range(w + 1)] for _ in range(n + 1)]
        
        # Initialize: 0 items, 0 quality
        for j in range(w + 1):
            dp[0][j] = (0, 0)  # (quality, days)
        
        self.execution_steps.append(f"Initialized DP table: {n+1} x {w+1}")
        
        # Fill DP table - O(n*W)
        for i in range(1, n + 1):
            detour = detours[i - 1]
            cost_cents = int(detour['cost'] * 100)
            days = detour['days']
            quality = detour['quality_rating']
            
            for j in range(w + 1):
                # Option 1: Don't take this detour
                dp[i][j] = dp[i - 1][j]
                
                # Option 2: Take this detour (if we have budget)
                if j >= cost_cents:
                    prev_quality, prev_days = dp[i - 1][j - cost_cents]
                    
                    # Can only take if days don't exceed limit
                    if prev_days + days <= max_days:
                        new_quality = prev_quality + quality
                        
                        # Update if better quality
                        if dp[i][j] is None or new_quality > dp[i][j][0]:
                            dp[i][j] = (new_quality, prev_days + days)
            
            if i % 5 == 0:
                self.execution_steps.append(f"Processed {i}/{n} detours")
        
        # Backtrack to find selected detours
        selected = []
        j = w
        quality, used_days = dp[n][j] if dp[n][j] else (0, 0)
        
        self.execution_steps.append(f"Backtracking to find selected detours (quality={quality}, days={used_days})")
        
        for i in range(n, 0, -1):
            if dp[i][j] != dp[i - 1][j]:  # This detour was selected
                detour = detours[i - 1]
                selected.append(detour)
                j -= int(detour['cost'] * 100)
                self.execution_steps.append(f"Selected: {detour['name']} (Quality: {detour['quality_rating']}, Cost: ${detour['cost']})")
        
        selected.reverse()
        
        total_cost = sum(d['cost'] for d in selected)
        total_days = sum(d['days'] for d in selected)
        total_quality = sum(d['quality_rating'] for d in selected)
        
        self.execution_steps.append(f"Final: {len(selected)} detours selected, Total quality: {total_quality:.1f}")
        
        return {
            'selected_detours': selected,
            'total_cost': total_cost,
            'total_days': total_days,
            'total_quality': total_quality,
            'execution_steps': self.execution_steps
        }


class DijkstraAlgorithm:
    """
    Dijkstra's Shortest Path: Find optimal route when multiple detours are selected.
    Models trek as a graph where nodes are locations and edges are distance + difficulty.
    
    Problem: Given selected detours, find shortest path visiting all required waypoints.
    Cost = distance + (difficulty_multiplier * elevation_change)
    
    Time Complexity: O((V + E) log V) with min-heap
    Space Complexity: O(V + E) for graph and distances
    """
    
    def __init__(self):
        self.execution_steps = []
    
    def solve(self, start_node: str, end_node: str, graph: Dict[str, List[Tuple[str, float, float]]]) -> Dict:
        """
        Find shortest path from start to end, visiting selected waypoints.
        
        Args:
            start_node: Starting location
            end_node: Ending location
            graph: {node: [(neighbor, distance_km, difficulty_weight), ...]}
        
        Returns:
            {
                path: List[str],
                total_distance: float,
                total_difficulty: float,
                execution_steps: List[str]
            }
        """
        self.execution_steps = []
        nodes = set(graph.keys())
        
        self.execution_steps.append(f"Dijkstra: {len(nodes)} nodes, Start: {start_node}, End: {end_node}")
        
        # Initialize distances and heap - O(V)
        distances = {node: float('inf') for node in nodes}
        distances[start_node] = 0
        
        previous = {node: None for node in nodes}
        heap = [(0, start_node)]  # (distance, node)
        visited = set()
        
        iterations = 0
        
        # Main Dijkstra loop - O((V + E) log V)
        while heap:
            current_dist, current = heapq.heappop(heap)
            iterations += 1
            
            if current in visited:
                continue
            
            visited.add(current)
            self.execution_steps.append(f"Visited: {current} (dist={current_dist:.2f}km)")
            
            if current_dist > distances[current]:
                continue
            
            # relax edges
            if current in graph:
                for neighbor, distance, difficulty in graph[current]:
                    alt_dist = current_dist + distance
                    
                    if alt_dist < distances[neighbor]:
                        distances[neighbor] = alt_dist
                        previous[neighbor] = current
                        heapq.heappush(heap, (alt_dist, neighbor))
                        
                        if iterations % 10 == 0:
                            self.execution_steps.append(f"  Relaxed edge to {neighbor}: {alt_dist:.2f}km")
        
        # Reconstruct path
        path = []
        current = end_node
        while current is not None:
            path.append(current)
            current = previous[current]
        path.reverse()
        
        self.execution_steps.append(f"Path found: {' → '.join(path)}")
        self.execution_steps.append(f"Total iterations: {iterations}")
        
        total_distance = distances.get(end_node, float('inf'))
        
        return {
            'path': path,
            'total_distance': total_distance,
            'execution_steps': self.execution_steps
        }


class BinarySearchAlgorithm:
    """
    Binary Search: Find trek within price range efficiently.
    Requires sorted list of treks by price.
    
    Time Complexity: O(log n) for search, O(n log n) for initial sort
    Space Complexity: O(1)
    """
    
    def __init__(self):
        self.execution_steps = []
    
    def search(self, sorted_treks: List[Dict], target_price: float) -> Dict:
        """
        Find trek closest to target price using binary search.
        
        Args:
            sorted_treks: List of treks sorted by price
            target_price: Target price in USD
        
        Returns:
            {
                found_trek: Dict or None,
                iterations: int,
                execution_steps: List[str]
            }
        """
        self.execution_steps = []
        n = len(sorted_treks)
        
        self.execution_steps.append(f"Binary Search: {n} treks, Target: ${target_price}")
        
        left, right = 0, n - 1
        closest_trek = None
        iterations = 0
        
        while left <= right:
            iterations += 1
            mid = (left + right) // 2
            mid_price = sorted_treks[mid]['price']
            
            self.execution_steps.append(f"Iteration {iterations}: left={left}, mid={mid}, right={right}, mid_price=${mid_price:.2f}")
            
            if mid_price == target_price:
                closest_trek = sorted_treks[mid]
                self.execution_steps.append(f"Exact match found: {closest_trek['name']}")
                break
            elif mid_price < target_price:
                left = mid + 1
            else:
                right = mid - 1
            
            # Track closest
            if closest_trek is None or abs(mid_price - target_price) < abs(closest_trek['price'] - target_price):
                closest_trek = sorted_treks[mid]
        
        self.execution_steps.append(f"Search completed in {iterations} iterations")
        if closest_trek:
            self.execution_steps.append(f"Closest trek: {closest_trek['name']} (${closest_trek['price']:.2f})")
        
        return {
            'found_trek': closest_trek,
            'iterations': iterations,
            'execution_steps': self.execution_steps
        }


class QuickSortAlgorithm:
    """
    Quick Sort: Sort treks by cost, difficulty, or rating.
    Average Time Complexity: O(n log n)
    Worst Case: O(n²) (rare with good pivot selection)
    Space Complexity: O(log n) for recursion stack
    """
    
    def __init__(self):
        self.execution_steps = []
        self.comparisons = 0
    
    def sort(self, items: List[Dict], key: str = 'price', reverse: bool = False) -> Dict:
        """
        Quick sort items by specified key.
        
        Args:
            items: List of dictionaries to sort
            key: Dictionary key to sort by (e.g., 'price', 'rating')
            reverse: If True, sort descending
        
        Returns:
            {
                sorted_items: List[Dict],
                comparisons: int,
                execution_steps: List[str]
            }
        """
        self.execution_steps = []
        self.comparisons = 0
        
        items_copy = items.copy()
        self.execution_steps.append(f"Starting Quick Sort: {len(items_copy)} items by '{key}' (reverse={reverse})")
        
        self._quick_sort_helper(items_copy, 0, len(items_copy) - 1, key)
        
        if reverse:
            items_copy.reverse()
        
        self.execution_steps.append(f"Sorting complete: {self.comparisons} comparisons")
        
        return {
            'sorted_items': items_copy,
            'comparisons': self.comparisons,
            'execution_steps': self.execution_steps
        }
    
    def _quick_sort_helper(self, arr: List, low: int, high: int, key: str):
        if low < high:
            pivot_idx = self._partition(arr, low, high, key)
            self.execution_steps.append(f"Partitioned: pivot at {pivot_idx}, range [{low}, {high}]")
            
            self._quick_sort_helper(arr, low, pivot_idx - 1, key)
            self._quick_sort_helper(arr, pivot_idx + 1, high, key)
    
    def _partition(self, arr: List, low: int, high: int, key: str) -> int:
        pivot = arr[high][key]
        i = low - 1
        
        for j in range(low, high):
            self.comparisons += 1
            if arr[j][key] < pivot:
                i += 1
                arr[i], arr[j] = arr[j], arr[i]
        
        arr[i + 1], arr[high] = arr[high], arr[i + 1]
        return i + 1


class MergeSortAlgorithm:
    """
    Merge Sort: Sort treks with guaranteed O(n log n) performance.
    Stable sort - maintains relative order of equal elements.
    
    Time Complexity: O(n log n) - always
    Space Complexity: O(n) for temporary arrays
    """
    
    def __init__(self):
        self.execution_steps = []
        self.comparisons = 0
    
    def sort(self, items: List[Dict], key: str = 'price', reverse: bool = False) -> Dict:
        """
        Merge sort items by specified key.
        
        Args:
            items: List of dictionaries to sort
            key: Dictionary key to sort by
            reverse: If True, sort descending
        
        Returns:
            {
                sorted_items: List[Dict],
                comparisons: int,
                execution_steps: List[str]
            }
        """
        self.execution_steps = []
        self.comparisons = 0
        
        items_copy = items.copy()
        n = len(items_copy)
        
        self.execution_steps.append(f"Starting Merge Sort: {n} items by '{key}' (reverse={reverse})")
        
        self._merge_sort_helper(items_copy, 0, n - 1, key)
        
        if reverse:
            items_copy.reverse()
        
        self.execution_steps.append(f"Sorting complete: {self.comparisons} comparisons")
        
        return {
            'sorted_items': items_copy,
            'comparisons': self.comparisons,
            'execution_steps': self.execution_steps
        }
    
    def _merge_sort_helper(self, arr: List, left: int, right: int, key: str):
        if left < right:
            mid = (left + right) // 2
            
            self._merge_sort_helper(arr, left, mid, key)
            self._merge_sort_helper(arr, mid + 1, right, key)
            
            self._merge(arr, left, mid, right, key)
    
    def _merge(self, arr: List, left: int, mid: int, right: int, key: str):
        left_arr = arr[left:mid + 1]
        right_arr = arr[mid + 1:right + 1]
        
        i = j = 0
        k = left
        
        while i < len(left_arr) and j < len(right_arr):
            self.comparisons += 1
            if left_arr[i][key] <= right_arr[j][key]:
                arr[k] = left_arr[i]
                i += 1
            else:
                arr[k] = right_arr[j]
                j += 1
            k += 1
        
        while i < len(left_arr):
            arr[k] = left_arr[i]
            i += 1
            k += 1
        
        while j < len(right_arr):
            arr[k] = right_arr[j]
            j += 1
            k += 1
        
        if (right - left) >= 9:  # Log step for large subarrays
            self.execution_steps.append(f"Merged range [{left}, {right}]")


class LinearSearchAlgorithm:
    """
    Linear Search: For comparison with Binary Search.
    Used for dataset that isn't sorted or for exhaustive search.
    
    Time Complexity: O(n)
    Space Complexity: O(1)
    """
    
    def __init__(self):
        self.execution_steps = []
    
    def search(self, items: List[Dict], predicate, key: str = None) -> Dict:
        """
        Linear search through items.
        
        Args:
            items: List of dictionaries
            predicate: Function that returns True for matching item
            key: Optional key to filter by
        
        Returns:
            {
                results: List[Dict],
                iterations: int,
                execution_steps: List[str]
            }
        """
        self.execution_steps = []
        iterations = 0
        results = []
        
        self.execution_steps.append(f"Linear Search: searching {len(items)} items")
        
        for i, item in enumerate(items):
            iterations += 1
            if predicate(item):
                results.append(item)
                self.execution_steps.append(f"Match found at index {i}: {item.get('name', str(item))}")
        
        self.execution_steps.append(f"Search complete: {iterations} iterations, {len(results)} matches found")
        
        return {
            'results': results,
            'iterations': iterations,
            'execution_steps': self.execution_steps
        }
