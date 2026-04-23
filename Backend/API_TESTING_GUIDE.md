# Quick API Testing Guide

Test your Django backend algorithm endpoints quickly!

## 🚀 Setup

```bash
cd Backend
python manage.py migrate
python manage.py createsuperuser
python manage.py seed_data  # Load sample trek data
python manage.py runserver
```

Backend runs at: `http://localhost:8000`

## 📍 Algorithm Endpoints

### 1. Search Algorithms

**Linear Search:**
```
http://localhost:8000/api/algorithms/search/?type=linear&query=everest
```

**Binary Search:**
```
http://localhost:8000/api/algorithms/search/?type=binary&query=annapurna
```

### 2. Sorting Algorithms

**Merge Sort (by price, ascending):**
```
http://localhost:8000/api/algorithms/sort/?type=merge&by=price&order=asc
```

**Quick Sort (by rating, descending):**
```
http://localhost:8000/api/algorithms/sort/?type=quick&by=average_rating&order=desc
```

**Quick Sort (by duration):**
```
http://localhost:8000/api/algorithms/sort/?type=quick&by=duration_days&order=asc
```

### 3. Graph Algorithms

**BFS Traversal:**
```
http://localhost:8000/api/routes/bfs/?start=Mount Everest Base Camp
```

**DFS Traversal:**
```
http://localhost:8000/api/routes/dfs/?start=Annapurna Circuit
```

**Dijkstra Shortest Path:**
```
http://localhost:8000/api/routes/shortest-path/?start=Mount Everest Base Camp&end=Langtang Valley Trek
```

### 4. Greedy Algorithms

**Maximize Trips in Budget:**
```
http://localhost:8000/api/algorithms/greedy/budget/?budget=200000&strategy=maximize_trips
```

**Maximize Value in Budget:**
```
http://localhost:8000/api/algorithms/greedy/budget/?budget=200000&strategy=maximize_value
```

### 5. Dynamic Programming

**0/1 Knapsack Trip Planner:**
```
http://localhost:8000/api/algorithms/dp/plan/?budget=150000&days=12&strategy=knapsack
```

**Maximize Destinations in Days:**
```
http://localhost:8000/api/algorithms/dp/plan/?budget=250000&days=15&strategy=maximize_destinations
```

### 6. Recommendations

**Rule-Based (using curl):**
```bash
curl -X POST http://localhost:8000/api/recommendations/ \
  -H "Content-Type: application/json" \
  -d '{
    "type": "rule_based",
    "preferences": {
      "budget": 150000,
      "max_days": 12,
      "difficulty": "MODERATE",
      "preferred_season": "Spring",
      "min_rating": 4.0
    }
  }'
```

**Content-Based (using curl):**
```bash
curl -X POST http://localhost:8000/api/recommendations/ \
  -H "Content-Type: application/json" \
  -d '{
    "type": "content_based",
    "liked_destination_id": 1
  }'
```

### 7. Algorithm Information

**Get info about any algorithm:**
```
http://localhost:8000/api/algorithms/info/?name=binary_search
http://localhost:8000/api/algorithms/info/?name=dijkstra
http://localhost:8000/api/algorithms/info/?name=dp_knapsack
```

**List all available algorithms:**
```
http://localhost:8000/api/algorithms/info/
```

## 🧪 Testing with Browser

1. Open your browser
2. Visit any GET endpoint above
3. Django REST Framework will show a nice browsable API interface
4. For POST requests, use the API form or curl

## 📱 Testing with Flutter App

Update your Flutter app's `api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000';  // Android emulator
  // static const String baseUrl = 'http://localhost:8000';  // iOS simulator
  // static const String baseUrl = 'http://192.168.1.x:8000';  // Physical device
}
```

## ✅ Expected Results

All algorithm endpoints return JSON with:
- `algorithm`: Algorithm name
- `result`: Actual output (sorted data, path, selected trips, etc.)
- `steps`: Array of execution steps (for visualization)
- `time_complexity`: Big-O notation
- `space_complexity`: Big-O notation
- `execution_time_ms`: Actual runtime
- `pseudocode`: Algorithm pseudocode (some endpoints)

## 🎯 For Viva Demonstration

1. **Search Demo**:
   - Show linear vs binary search comparison
   - Point out the difference in comparisons

2. **Sort Demo**:
   - Sort by price, then by rating
   - Show step-by-step execution

3. **Graph Demo**:
   - Show BFS vs DFS paths
   - Demonstrate Dijkstra finding shortest distance

4. **Greedy vs DP Demo**:
   - Run greedy with budget 150000
   - Run DP with same budget
   - Compare results (DP is optimal)

5. **Recommendations Demo**:
   - Show rule-based scoring
   - Show content-based similarity

## 🔧 Troubleshooting

**CORS errors?**
- Check `CORS_ALLOW_ALL_ORIGINS = True` in settings.py

**No data?**
- Run `python manage.py seed_data`

**Import errors?**
- Make sure `services/` folder has `__init__.py`

## 📊 Sample Destinations

After running `seed_data`, you'll have:
1. Mount Everest Base Camp (NPR 125,000, 12 days)
2. Annapurna Circuit (NPR 100,000, 15 days)
3. Langtang Valley Trek (NPR 65,000, 8 days)
4. Manaslu Circuit (NPR 108,000, 14 days)
5. Poon Hill Trek (NPR 33,000, 4 days)
6. Upper Mustang Trek (NPR 133,000, 10 days)

Use these names in your queries!

## 🎓 TU BCA Project Checklist

- [ ] Backend running successfully
- [ ] All algorithm endpoints tested
- [ ] Screenshots taken for report
- [ ] Complexity analysis understood
- [ ] Viva questions prepared
- [ ] Postman collection exported
- [ ] README.md updated

Good luck with your project! 🚀
