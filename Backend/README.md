# Django Backend - Nepal Trekking Booking API

Complete Django REST Framework backend for the Nepal Trekking mobile app with algorithm implementations for TU BCA 6th semester project.

## 🛠 Tech Stack

- **Framework**: Django 4.2
- **API**: Django REST Framework 3.14
- **Database**: SQLite (dev) / PostgreSQL (production)
- **Authentication**: JWT (djangorestframework-simplejwt)
- **API Documentation**: Swagger (drf-yasg)
- **CORS**: django-cors-headers

## 📦 Features

### Core Modules
- ✅ User Authentication (JWT)
- ✅ Destinations/Trips Management
- ✅ Booking System
- ✅ Reviews & Ratings

### Algorithm Implementations (For TU BCA Project)
- ✅ Linear & Binary Search
- ✅ Merge Sort & Quick Sort
- ✅ Graph Algorithms (BFS, DFS, Dijkstra)
- ✅ Greedy Algorithm (Budget Optimizer)
- ✅ Dynamic Programming (Trip Planner)
- ✅ Recommendation Engine (Rule-based)

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd Backend
pip install -r requirements.txt
```

### 2. Run Migrations

```bash
python manage.py migrate
```

### 3. Create Superuser

```bash
python manage.py createsuperuser
```

### 4. Load Sample Data

```bash
python manage.py seed_data
```

### 5. Run Development Server

```bash
python manage.py runserver
```

API will be available at: `http://localhost:8000/api/`

## 📚 API Endpoints

### Authentication
- `POST /api/auth/register/` - Register new user
- `POST /api/auth/login/` - Login (get JWT token)
- `POST /api/auth/token/refresh/` - Refresh JWT token
- `GET /api/auth/me/` - Get current user

### Destinations
- `GET /api/destinations/` - List all destinations (with filters)
- `GET /api/destinations/{id}/` - Get destination details
- `GET /api/destinations/featured/` - Get featured destinations
- `POST /api/destinations/` - Create destination (admin only)
- `PUT /api/destinations/{id}/` - Update destination (admin only)
- `DELETE /api/destinations/{id}/` - Delete destination (admin only)

### Bookings
- `GET /api/bookings/` - List user's bookings
- `POST /api/bookings/` - Create booking
- `GET /api/bookings/{id}/` - Get booking details
- `PATCH /api/bookings/{id}/cancel/` - Cancel booking

### Reviews
- `POST /api/reviews/` - Add review
- `GET /api/destinations/{id}/reviews/` - Get destination reviews

### Routes (Graph Algorithms)
- `GET /api/routes/graph/` - Get route graph
- `GET /api/routes/bfs/` - BFS traversal
- `GET /api/routes/dfs/` - DFS traversal
- `GET /api/routes/shortest-path/` - Dijkstra's shortest path

### Algorithms (Educational)
- `GET /api/algorithms/search/` - Linear/Binary search
- `GET /api/algorithms/sort/` - Merge/Quick sort
- `GET /api/algorithms/greedy/budget/` - Greedy budget optimizer
- `GET /api/algorithms/dp/plan/` - DP trip planner
- `GET /api/algorithms/info/` - Get algorithm info (pseudocode, complexity)

### Recommendations
- `POST /api/recommendations/` - Get personalized recommendations

## 🧪 API Documentation

Swagger UI: `http://localhost:8000/swagger/`  
ReDoc: `http://localhost:8000/redoc/`

## 🗂 Project Structure

```
Backend/
├── manage.py
├── requirements.txt
├── trekking_app/
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── api/
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   ├── urls.py
│   └── management/
│       └── commands/
│           └── seed_data.py
└── services/
    ├── searching.py
    ├── sorting.py
    ├── graph.py
    ├── greedy.py
    ├── dp.py
    └── recommendations.py
```

## 🎓 For TU BCA Project

### Algorithm Demonstrations

All algorithm endpoints return:
- **Result**: Actual output
- **Steps**: Step-by-step execution log
- **Complexity**: Time & space complexity
- **Execution Time**: Actual runtime in ms
- **Pseudocode**: Algorithm pseudocode (optional)

### Viva Questions Covered

1. **Why Django REST Framework?** - Industry standard, built-in serialization, browsable API
2. **JWT vs Session Auth?** - Stateless, scalable, mobile-friendly
3. **Graph representation?** - Adjacency list stored in JSONField
4. **Algorithm time complexity?** - All algorithms include Big-O analysis
5. **Database optimization?** - Indexing on search fields, pagination, select_related/prefetch_related

## 🔧 Environment Variables

Create `.env` file:

```env
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1
DATABASE_URL=sqlite:///db.sqlite3
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

## 📝 Sample Request/Response

### Create Booking

**Request:**
```http
POST /api/bookings/
Authorization: Bearer <token>
Content-Type: application/json

{
  "destination": 1,
  "number_of_people": 2,
  "start_date": "2026-03-15"
}
```

**Response:**
```json
{
  "id": 1,
  "destination": {...},
  "user": {...},
  "number_of_people": 2,
  "start_date": "2026-03-15",
  "total_price": 250000.00,
  "status": "pending",
  "created_at": "2026-02-17T10:30:00Z"
}
```

## 🧠 Algorithm Examples

### Binary Search
```http
GET /api/algorithms/search/?type=binary&query=everest
```

Returns trip matching "everest" with search steps and comparisons.

### Dijkstra Shortest Path
```http
GET /api/routes/shortest-path/?start=Kathmandu&end=Everest
```

Returns shortest route with distance and path visualization.

## 🐛 Troubleshooting

**CORS errors?** - Check `CORS_ALLOWED_ORIGINS` in settings.py

**JWT expired?** - Use `/api/auth/token/refresh/` endpoint

**Database errors?** - Run `python manage.py migrate`

**No data?** - Run `python manage.py seed_data`

## 📚 Additional Resources

- Django Docs: https://docs.djangoproject.com/
- DRF Docs: https://www.django-rest-framework.org/
- JWT Auth: https://django-rest-framework-simplejwt.readthedocs.io/

## 👨‍🎓 Academic Notes

This backend demonstrates:
- RESTful API design principles
- Authentication & Authorization
- Database modeling & relationships
- Algorithm implementation & analysis
- API documentation best practices
- Code organization & clean architecture

Perfect for BCA 6th semester final project at Tribhuvan University.

## 📄 License

Educational project for TU BCA 6th semester.
