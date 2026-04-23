"""
Graph Algorithms Service

Implements BFS, DFS, and Dijkstra's Algorithm for trek route finding.
For TU BCA 6th Semester - Data Structures & Algorithms
"""

import time
from typing import List, Dict, Any, Set
from collections import deque
import heapq
import math


class GraphService:
    """Service class for graph algorithms"""
    
    @staticmethod
    def build_graph_from_destinations(destinations: List[Dict]) -> Dict[str, List[tuple]]:
        """
        Build adjacency list graph from destinations using coordinates
        
        Args:
            destinations: List of destination dictionaries with lat/lng
        
        Returns:
            Adjacency list representation of graph
        """
        graph = {}
        
        for dest in destinations:
            name = dest.get('name')
            graph[name] = []
            
            # Connect to nearby destinations (within ~300km)
            for other in destinations:
                if dest['id'] != other['id']:
                    distance = GraphService.haversine_distance(
                        dest.get('latitude', 0),
                        dest.get('longitude', 0),
                        other.get('latitude', 0),
                        other.get('longitude', 0)
                    )
                    
                    if distance < 300:  # Within 300km
                        graph[name].append((other.get('name'), distance))
        
        return graph
    
    @staticmethod
    def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """
        Calculate distance between two points using Haversine formula
        
        Returns:
            Distance in kilometers
        """
        R = 6371  # Earth radius in km
        
        lat1_rad = math.radians(lat1)
        lat2_rad = math.radians(lat2)
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        
        a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon/2)**2
        c = 2 * math.asin(math.sqrt(a))
        
        return R * c
    
    @staticmethod
    def bfs(graph: Dict[str, List[tuple]], start: str, end: str = None) -> Dict[str, Any]:
        """
        Breadth-First Search Algorithm
        Time Complexity: O(V + E)
        Space Complexity: O(V)
        
        Args:
            graph: Adjacency list representation
            start: Starting node
            end: Target node (optional, if None returns full traversal)
        
        Returns:
            Dictionary with path, steps, and metadata
        """
        start_time = time.time()
        steps = []
        visited = set()
        queue = deque([(start, [start])])
        visited.add(start)
        nodes_explored = 0
        
        steps.append({
            'step': 1,
            'action': 'start',
            'node': start,
            'queue': [start],
            'visited': [start]
        })
        
        result_path = None
        
        while queue:
            node, path = queue.popleft()
            nodes_explored += 1
            
            steps.append({
                'step': len(steps) + 1,
                'action': 'visit',
                'node': node,
                'path': path,
                'queue_size': len(queue)
            })
            
            if end and node == end:
                result_path = path
                steps.append({
                    'step': len(steps) + 1,
                    'action': 'found',
                    'node': end,
                    'path': path
                })
                break
            
            neighbors = graph.get(node, [])
            for neighbor, _ in neighbors:
                if neighbor not in visited:
                    visited.add(neighbor)
                    new_path = path + [neighbor]
                    queue.append((neighbor, new_path))
                    
                    steps.append({
                        'step': len(steps) + 1,
                        'action': 'enqueue',
                        'from': node,
                        'to': neighbor,
                        'new_path': new_path
                    })
        
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': 'Breadth-First Search (BFS)',
            'start': start,
            'end': end,
            'path': result_path,
            'found': result_path is not None,
            'steps': steps,
            'nodes_explored': nodes_explored,
            'total_nodes': len(graph),
            'time_complexity': 'O(V + E)',
            'space_complexity': 'O(V)',
            'execution_time_ms': round(execution_time, 4),
            'description': 'Level-order traversal, shortest path in unweighted graph',
            'pseudocode': [
                'create queue Q',
                'mark start as visited',
                'Q.enqueue(start)',
                'while Q is not empty:',
                '    node = Q.dequeue()',
                '    if node == target:',
                '        return path',
                '    for each neighbor of node:',
                '        if neighbor not visited:',
                '            mark neighbor as visited',
                '            Q.enqueue(neighbor)'
            ]
        }
    
    @staticmethod
    def dfs(graph: Dict[str, List[tuple]], start: str, end: str = None) -> Dict[str, Any]:
        """
        Depth-First Search Algorithm
        Time Complexity: O(V + E)
        Space Complexity: O(V)
        
        Args:
            graph: Adjacency list representation
            start: Starting node
            end: Target node (optional)
        
        Returns:
            Dictionary with path, steps, and metadata
        """
        start_time = time.time()
        steps = []
        visited = set()
        nodes_explored = 0
        result_path = None
        
        def dfs_recursive(node: str, path: List[str], depth: int = 0) -> bool:
            nonlocal nodes_explored, result_path, steps
            
            visited.add(node)
            nodes_explored += 1
            
            steps.append({
                'step': len(steps) + 1,
                'action': 'visit',
                'node': node,
                'path': path,
                'depth': depth
            })
            
            if end and node == end:
                result_path = path
                steps.append({
                    'step': len(steps) + 1,
                    'action': 'found',
                    'node': end,
                    'path': path
                })
                return True
            
            neighbors = graph.get(node, [])
            for neighbor, _ in neighbors:
                if neighbor not in visited:
                    steps.append({
                        'step': len(steps) + 1,
                        'action': 'explore',
                        'from': node,
                        'to': neighbor,
                        'depth': depth + 1
                    })
                    
                    if dfs_recursive(neighbor, path + [neighbor], depth + 1):
                        return True
            
            steps.append({
                'step': len(steps) + 1,
                'action': 'backtrack',
                'node': node,
                'depth': depth
            })
            
            return False
        
        dfs_recursive(start, [start])
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': 'Depth-First Search (DFS)',
            'start': start,
            'end': end,
            'path': result_path,
            'found': result_path is not None,
            'steps': steps,
            'nodes_explored': nodes_explored,
            'total_nodes': len(graph),
            'time_complexity': 'O(V + E)',
            'space_complexity': 'O(V)',
            'execution_time_ms': round(execution_time, 4),
            'description': 'Go deep first, uses backtracking',
            'pseudocode': [
                'function DFS(node, visited, path):',
                '    mark node as visited',
                '    add node to path',
                '    if node == target:',
                '        return path',
                '    for each neighbor of node:',
                '        if neighbor not visited:',
                '            DFS(neighbor, visited, path)',
                '    backtrack'
            ]
        }
    
    @staticmethod
    def dijkstra(graph: Dict[str, List[tuple]], start: str, end: str) -> Dict[str, Any]:
        """
        Dijkstra's Shortest Path Algorithm
        Time Complexity: O((V + E) log V)
        Space Complexity: O(V)
        
        Args:
            graph: Adjacency list with weighted edges
            start: Starting node
            end: Target node
        
        Returns:
            Dictionary with shortest path, distance, steps, and metadata
        """
        start_time = time.time()
        steps = []
        
        # Initialize distances and priority queue
        distances = {node: float('infinity') for node in graph}
        distances[start] = 0
        previous = {node: None for node in graph}
        pq = [(0, start)]  # (distance, node)
        visited = set()
        
        steps.append({
            'step': 1,
            'action': 'initialize',
            'start': start,
            'distances': {k: v for k, v in distances.items() if v != float('infinity')}
        })
        
        while pq:
            current_dist, current_node = heapq.heappop(pq)
            
            if current_node in visited:
                continue
            
            visited.add(current_node)
            
            steps.append({
                'step': len(steps) + 1,
                'action': 'visit',
                'node': current_node,
                'distance': current_dist,
                'visited_count': len(visited)
            })
            
            if current_node == end:
                break
            
            neighbors = graph.get(current_node, [])
            for neighbor, weight in neighbors:
                if neighbor not in visited:
                    new_dist = current_dist + weight
                    
                    if new_dist < distances[neighbor]:
                        distances[neighbor] = new_dist
                        previous[neighbor] = current_node
                        heapq.heappush(pq, (new_dist, neighbor))
                        
                        steps.append({
                            'step': len(steps) + 1,
                            'action': 'relax_edge',
                            'from': current_node,
                            'to': neighbor,
                            'old_distance': distances[neighbor] if neighbor in distances else 'infinity',
                            'new_distance': new_dist
                        })
        
        # Reconstruct path
        path = []
        current = end
        while current is not None:
            path.insert(0, current)
            current = previous[current]
        
        if path[0] != start:
            path = None  # No path found
        
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': "Dijkstra's Shortest Path",
            'start': start,
            'end': end,
            'path': path,
            'found': path is not None,
            'total_distance_km': round(distances.get(end, 0), 2) if path else None,
            'steps': steps,
            'nodes_explored': len(visited),
            'total_nodes': len(graph),
            'time_complexity': 'O((V + E) log V)',
            'space_complexity': 'O(V)',
            'execution_time_ms': round(execution_time, 4),
            'description': 'Finds shortest weighted path using greedy approach',
            'pseudocode': [
                'initialize distances to infinity',
                'set distance[start] = 0',
                'create priority queue with start',
                'while queue not empty:',
                '    node = extract minimum',
                '    for each neighbor:',
                '        alt = dist[node] + weight(node, neighbor)',
                '        if alt < dist[neighbor]:',
                '            dist[neighbor] = alt',
                '            previous[neighbor] = node',
                '            add neighbor to queue',
                'reconstruct path from previous[]'
            ]
        }
