from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from . import views
from . import algorithm_views
from . import optimization_views

router = DefaultRouter()
router.register(r'destinations', views.DestinationViewSet, basename='destination')
router.register(r'bookings', views.BookingViewSet, basename='booking')
router.register(r'reviews', views.ReviewViewSet, basename='review')
router.register(r'notifications', views.NotificationViewSet, basename='notification')
router.register(r'detours', optimization_views.DetourViewSet, basename='detour')
router.register(r'itineraries', optimization_views.TrekItineraryViewSet, basename='itinerary')
router.register(r'guides', optimization_views.GuideViewSet, basename='guide')
router.register(r'cost-configurations', optimization_views.CostConfigurationViewSet, basename='cost-configuration')

urlpatterns = [
    # Authentication endpoints
    path('auth/register/', views.register_user, name='register'),
    path('auth/login/', views.login_user, name='login'),
    path('auth/logout/', views.logout_user, name='logout'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('auth/profile/', views.get_user_profile, name='profile'),
    path('auth/forgot-password/', views.ForgotPasswordAPIView.as_view(), name='forgot-password'),
    path('auth/verify-otp/', views.VerifyOTPAPIView.as_view(), name='verify-otp'),
    path('auth/reset-password/', views.ResetPasswordAPIView.as_view(), name='reset-password'),
    path('auth/change-password/', views.ChangePasswordAPIView.as_view(), name='change-password'),
    
    # Algorithm endpoints (TU BCA Project)
    path('algorithms/search/', algorithm_views.algorithm_search, name='algorithm-search'),
    path('algorithms/sort/', algorithm_views.algorithm_sort, name='algorithm-sort'),
    path('algorithms/greedy/budget/', algorithm_views.algorithm_greedy_budget, name='algorithm-greedy-budget'),
    path('algorithms/dp/plan/', algorithm_views.algorithm_dp_plan, name='algorithm-dp-plan'),
    path('algorithms/trip-planner/', algorithm_views.TripPlannerAPIView.as_view(), name='trip-planner-api'),
    path('algorithms/info/', algorithm_views.algorithm_info, name='algorithm-info'),
    
    # Graph/Route algorithms
    path('routes/bfs/', algorithm_views.algorithm_graph_bfs, name='route-bfs'),
    path('routes/dfs/', algorithm_views.algorithm_graph_dfs, name='route-dfs'),
    path('routes/shortest-path/', algorithm_views.algorithm_graph_dijkstra, name='route-dijkstra'),
    
    # Recommendations
    path('recommendations/', algorithm_views.algorithm_recommendations, name='recommendations'),

    # Advanced optimization endpoints
    path('cost-breakdown/', optimization_views.cost_breakdown_view, name='cost-breakdown'),
    path('cost-breakdown/all-treks/', optimization_views.all_treks_cost_breakdown_view, name='cost-breakdown-all-treks'),
    path('weather-risk/', optimization_views.weather_risk_view, name='weather-risk'),
    path('weather/risk/', optimization_views.weather_risk_view, name='weather-risk-v2'),
    path('optimize-trip/', optimization_views.optimize_trip_view, name='optimize-trip'),
    path('itinerary/create/', optimization_views.create_itinerary_view, name='itinerary-create'),
    path('itinerary/optimize/', optimization_views.optimize_trip_view, name='itinerary-optimize'),
    path('algorithm-visualizer/', optimization_views.algorithm_visualizer_view, name='algorithm-visualizer'),
    
    # Router URLs
    path('', include(router.urls)),
]

