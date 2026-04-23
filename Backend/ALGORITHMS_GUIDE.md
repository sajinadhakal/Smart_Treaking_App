# Algorithm Implementations Guide

**For TU BCA 6th Semester Final Year Project**

This document explains all algorithm implementations in the Nepal Trekking Backend API.

## 📚 Table of Contents

1. [Searching Algorithms](#1-searching-algorithms)
2. [Sorting Algorithms](#2-sorting-algorithms)
3. [Graph Algorithms](#3-graph-algorithms)
4. [Greedy Algorithms](#4-greedy-algorithms)
5. [Dynamic Programming](#5-dynamic-programming)
6. [Recommendation System](#6-recommendation-system)
7. [API Usage Examples](#7-api-usage-examples)
8. [Viva Questions & Answers](#8-viva-questions--answers)

---

## 1. Searching Algorithms

### 1.1 Linear Search

**Time Complexity:** O(n)  
**Space Complexity:** O(1)

**Implementation:** `services/searching.py`

**Description:**  
Searches sequentially through the list until the target is found.

**Use Case:**  
- Unsorted data
- Small datasets
- When data changes frequently

**API Endpoint:**  
```
GET /api/algorithms/search/?type=linear&query=everest
```

**Example Response:**
```json
{
  "algorithm": "Linear Search",
  "result": {...},
  "found": true,
  "comparisons": 3,
  "time_complexity": "O(n)",
  "execution_time_ms": 0.5432
}
```

### 1.2 Binary Search

**Time Complexity:** O(log n)  
**Space Complexity:** O(1)

**Implementation:** `services/searching.py`

**Description:**  
Divides the search space in half each iteration (requires sorted data).

**Use Case:**  
- Sorted data
- Large datasets
- Frequent searches

**API Endpoint:**  
```
GET /api/algorithms/search/?type=binary&query=everest
```

**Comparison:**  
For 1000 items:
- Linear Search: ~500 comparisons average
- Binary Search: ~10 comparisons

---

## 2. Sorting Algorithms

### 2.1 Merge Sort

**Time Complexity:** O(n log n) - consistent  
**Space Complexity:** O(n)

**Implementation:** `services/sorting.py`

**Description:**  
Divide-and-conquer algorithm that divides array into halves, sorts them, and merges.

**Advantages:**
- Stable sorting
- Guaranteed O(n log n)
- Good for linked lists

**API Endpoint:**  
```
GET /api/algorithms/sort/?type=merge&by=price&order=asc
```

### 2.2 Quick Sort

**Time Complexity:** O(n log n) average, O(n²) worst  
**Space Complexity:** O(log n)

**Implementation:** `services/sorting.py`

**Description:**  
In-place sorting using pivot selection and partitioning.

**Advantages:**
- Fast in practice
- Low memory usage
- Good cache performance

**API Endpoint:**  
```
GET /api/algorithms/sort/?type=quick&by=price&order=desc
```

---

## 3. Graph Algorithms

### 3.1 Graph Representation

Trekking routes are represented as a **weighted adjacency list**:

```python
{
  "Mount Everest Base Camp": [
    ("Annapurna Circuit", 285.4),  # (destination, distance_km)
    ("Langtang Valley", 120.3)
  ],
  "Annapurna Circuit": [...]
}
```

Distances are calculated using the **Haversine formula** (great-circle distance).

### 3.2 BFS (Breadth-First Search)

**Time Complexity:** O(V + E)  
**Space Complexity:** O(V)

**Implementation:** `services/graph.py`

**Description:**  
Level-order traversal using a queue. Finds shortest path in unweighted graphs.

**Use Case:**  
- Finding shortest route (by number of stops)
- Exploring nearby destinations
- Level-wise exploration

**API Endpoint:**  
```
GET /api/routes/bfs/?start=Kathmandu&end=Everest Base Camp
```

### 3.3 DFS (Depth-First Search)

**Time Complexity:** O(V + E)  
**Space Complexity:** O(V)

**Implementation:** `services/graph.py`

**Description:**  
Explores as far as possible along each branch before backtracking.

**Use Case:**  
- Path finding
- Cycle detection
- Maze solving

**API Endpoint:**  
```
GET /api/routes/dfs/?start=Kathmandu&end=Everest Base Camp
```

### 3.4 Dijkstra's Shortest Path

**Time Complexity:** O((V + E) log V)  
**Space Complexity:** O(V)

**Implementation:** `services/graph.py`

**Description:**  
Finds shortest weighted path using a priority queue (min-heap).

**Use Case:**  
- GPS navigation
- Finding shortest distance route
- Network routing

**API Endpoint:**  
```
GET /api/routes/shortest-path/?start=Kathmandu&end=Everest Base Camp
```

**Example Response:**
```json
{
  "algorithm": "Dijkstra's Shortest Path",
  "path": ["Kathmandu", "Langtang Valley", "Mount Everest Base Camp"],
  "total_distance_km": 405.7,
  "time_complexity": "O((V + E) log V)"
}
```

---

## 4. Greedy Algorithms

### 4.1 Maximize Trips in Budget

**Time Complexity:** O(n log n)  
**Space Complexity:** O(n)

**Strategy:** Select cheapest trips first

**Implementation:** `services/greedy.py`

**Use Case:**  
- Budget-conscious travelers
- Maximize experiences

**API Endpoint:**  
```
GET /api/algorithms/greedy/budget/?budget=150000&strategy=maximize_trips
```

### 4.2 Maximize Value in Budget

**Time Complexity:** O(n log n)  
**Space Complexity:** O(n)

**Strategy:** Select highest value/cost ratio first

**Value Calculation:** `rating × days / price`

**Implementation:** `services/greedy.py`

**API Endpoint:**  
```
GET /api/algorithms/greedy/budget/?budget=150000&strategy=maximize_value
```

**Note:** This is an approximation algorithm. For optimal solution, use Dynamic Programming.

---

## 5. Dynamic Programming

### 5.1 0/1 Knapsack Trip Planner

**Time Complexity:** O(n × W) where W = budget  
**Space Complexity:** O(n × W)

**Implementation:** `services/dp.py`

**Description:**  
Finds the optimal combination of trips that maximizes value (rating × days) within budget and time constraints.

**DP Table:**
```
dp[i][w] = maximum value using first i items with budget w
```

**Recurrence Relation:**
```
dp[i][w] = max(
    dp[i-1][w],              // exclude item i
    dp[i-1][w-price[i]] + value[i]  // include item i
)
```

**Use Case:**  
- Optimal trip planning
- Resource allocation
- Portfolio optimization

**API Endpoint:**  
```
GET /api/algorithms/dp/plan/?budget=150000&days=12&strategy=knapsack
```

**Example Response:**
```json
{
  "algorithm": "0/1 Knapsack Dynamic Programming",
  "budget": 150000,
  "total_cost": 133000,
  "total_days": 12,
  "total_value": 52.8,
  "selected_trips": [...],
  "is_optimal": true
}
```

### 5.2 Maximize Destinations in Days

**Time Complexity:** O(n × D) where D = max_days  
**Space Complexity:** O(D)

**Implementation:** `services/dp.py`

**Description:**  
Maximizes the number of destinations that fit within available days.

**API Endpoint:**  
```
GET /api/algorithms/dp/plan/?budget=200000&days=15&strategy=maximize_destinations
```

---

## 6. Recommendation System

### 6.1 Rule-Based Recommendations

**Time Complexity:** O(n)  
**Space Complexity:** O(n)

**Implementation:** `services/recommendations.py`

**Scoring Rules:**
1. Budget filter (hard constraint)
2. Days filter (hard constraint)
3. Minimum rating filter
4. Difficulty match: +30 points
5. Season match: +20 points
6. Rating bonus: 0-25 points
7. Featured destination: +15 points
8. Budget efficiency: 0-20 points
9. Duration match: +10 points

**API Endpoint:**  
```http
POST /api/recommendations/
Content-Type: application/json

{
  "type": "rule_based",
  "preferences": {
    "budget": 150000,
    "max_days": 12,
    "difficulty": "MODERATE",
    "preferred_season": "Spring",
    "min_rating": 4.0
  }
}
```

### 6.2 Content-Based Filtering

**Time Complexity:** O(n)  
**Space Complexity:** O(n)

**Similarity Factors:**
- Same difficulty: +30
- Similar duration: 0-20
- Similar price: 0-25
- Same region: +15
- Similar rating: +10

**API Endpoint:**  
```http
POST /api/recommendations/
Content-Type: application/json

{
  "type": "content_based",
  "liked_destination_id": 1
}
```

---

## 7. API Usage Examples

### 7.1 Search for "Everest"

```bash
curl "http://localhost:8000/api/algorithms/search/?type=binary&query=everest"
```

### 7.2 Sort by Price (Descending)

```bash
curl "http://localhost:8000/api/algorithms/sort/?type=quick&by=price&order=desc"
```

### 7.3 Find Shortest Path

```bash
curl "http://localhost:8000/api/routes/shortest-path/?start=Kathmandu&end=Mount%20Everest%20Base%20Camp"
```

### 7.4 Budget Optimization

```bash
curl "http://localhost:8000/api/algorithms/greedy/budget/?budget=150000&strategy=maximize_trips"
```

### 7.5 Optimal Trip Planning

```bash
curl "http://localhost:8000/api/algorithms/dp/plan/?budget=150000&days=12&strategy=knapsack"
```

### 7.6 Get Algorithm Info

```bash
curl "http://localhost:8000/api/algorithms/info/?name=dijkstra"
```

---

## 8. Viva Questions & Answers

### Q1: Why did you choose Linear Search and Binary Search?

**Answer:**  
- **Linear Search**: O(n) time, works on unsorted data. Used when data changes frequently or for small datasets.
- **Binary Search**: O(log n) time, requires sorted data. Much faster for large datasets - for 1000 items, linear takes ~500 comparisons vs binary takes ~10.

### Q2: What is the advantage of Merge Sort over Quick Sort?

**Answer:**  
- **Merge Sort**: Guaranteed O(n log n) time in all cases, stable (preserves order of equal elements)
- **Quick Sort**: O(n²) worst case, but faster in practice due to better cache performance and in-place sorting (O(log n) space vs O(n))

### Q3: When would you use BFS vs DFS?

**Answer:**  
- **BFS**: Shortest path in unweighted graph, level-wise exploration, finding nearest neighbors
- **DFS**: Path finding, cycle detection, topological sorting, less memory for deep graphs

### Q4: How does Dijkstra's algorithm work?

**Answer:**  
Uses a priority queue (min-heap) to always explore the node with minimum distance first. For each node, we "relax" edges - if we find a shorter path to a neighbor, we update its distance and add it to the queue. Time complexity: O((V+E) log V).

### Q5: What is the difference between Greedy and Dynamic Programming?

**Answer:**  
- **Greedy**: Makes locally optimal choice at each step. Fast (O(n log n)) but not always optimal. Example: selecting cheapest trips first.
- **DP**: Considers all possibilities using memoization. Guaranteed optimal but slower (O(n×W)). Example: 0/1 knapsack for trip planning.

### Q6: Explain the 0/1 Knapsack problem in your project.

**Answer:**  
We want to maximize total value (rating × days) of selected trips within budget and time constraints. Each trip can be selected or not (0/1). We build a DP table where dp[i][w] = max value using first i trips with budget w. We backtrack to find which trips were selected.

### Q7: How do you calculate similarity in content-based filtering?

**Answer:**  
We compare attributes between destinations:
- Same difficulty: +30 points
- Similar duration (±3 days): 0-20 points
- Similar price (±30%): 0-25 points
- Same region: +15 points
- Similar rating (±0.5): +10 points

Then sort by total similarity score.

### Q8: What is the time complexity of your recommendation system?

**Answer:**  
O(n) - we iterate through all n destinations once, calculate scores based on rules (constant time per destination), then sort top results. Since we limit output to 10, sorting is effectively constant time.

### Q9: How do you represent the graph of trek routes?

**Answer:**  
Weighted adjacency list where each destination is a node and edges represent connections with distances calculated using Haversine formula (great-circle distance). We only connect destinations within 300km for realistic trekking routes.

### Q10: Why use a priority queue in Dijkstra's algorithm?

**Answer:**  
Priority queue (min-heap) ensures we always process the node with minimum distance first. This guarantees we find the shortest path. Without it, we'd need to scan all nodes (O(V²)). With heap, it's O((V+E) log V).

---

## 📊 Complexity Summary

| Algorithm | Time Complexity | Space Complexity | Optimal? |
|-----------|----------------|------------------|----------|
| Linear Search | O(n) | O(1) | N/A |
| Binary Search | O(log n) | O(1) | N/A |
| Merge Sort | O(n log n) | O(n) | Yes |
| Quick Sort | O(n log n) avg | O(log n) | N/A |
| BFS | O(V + E) | O(V) | Yes (unweighted) |
| DFS | O(V + E) | O(V) | No |
| Dijkstra | O((V+E) log V) | O(V) | Yes (non-negative) |
| Greedy | O(n log n) | O(n) | No |
| DP Knapsack | O(n × W) | O(n × W) | Yes |
| Recommendations | O(n) | O(n) | N/A |

---

## 🎓 For TU BCA Evaluation

**This project demonstrates:**

✅ **Searching**: Linear & Binary Search with step tracking  
✅ **Sorting**: Merge Sort & Quick Sort with comparisons  
✅ **Graph Algorithms**: BFS, DFS, Dijkstra with real-world data  
✅ **Greedy**: Budget optimization with multiple strategies  
✅ **Dynamic Programming**: 0/1 Knapsack for optimal planning  
✅ **AI/ML**: Rule-based and content-based recommendations  
✅ **Real-world Application**: Complete trekking booking system  
✅ **Educational Features**: Step logs, complexity analysis, pseudocode  

**All algorithms return:**
- Result data
- Step-by-step execution log
- Time & space complexity
- Execution time in milliseconds
- Pseudocode (via `/api/algorithms/info/`)

Perfect for demonstration, viva defense, and project report! 🚀
