"""
Algorithm API Views
Exposes algorithm services through REST endpoints
For TU BCA 6th Semester Project
"""

import re
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status

from .models import Destination, TrekDestination
from .serializers import TripPlannerRequestSerializer
from services.searching import SearchingService
from services.sorting import SortingService
from services.graph import GraphService
from services.greedy import GreedyService
from services.dp import DynamicProgrammingService
from services.recommendations import RecommendationService
from services.trip_planner import TripPlannerService


@api_view(['GET'])
@permission_classes([AllowAny])
def algorithm_search(request):
    """
    Search Algorithm Endpoint
    GET /api/algorithms/search/?type=linear|binary&query=everest&key=name
    """
    search_type = request.GET.get('type', 'linear')
    query = request.GET.get('query', '')
    key = request.GET.get('key', 'name')
    
    if not query:
        return Response({'error': 'Query parameter required'}, status=400)
    
    destinations = list(Destination.objects.values())
    
    if search_type == 'binary':
        result = SearchingService.binary_search(destinations, query, key)
    else:
        result = SearchingService.linear_search(destinations, query, key)
    
    return Response(result)


@api_view(['GET'])
@permission_classes([AllowAny])
def algorithm_sort(request):
    """
    Sorting Algorithm Endpoint
    GET /api/algorithms/sort/?type=merge|quick&by=price&order=asc|desc
    """
    sort_type = request.GET.get('type', 'merge')
    sort_by = request.GET.get('by', 'price')
    order = request.GET.get('order', 'asc')
    
    destinations = list(Destination.objects.values())
    reverse = (order == 'desc')
    
    if sort_type == 'quick':
        result = SortingService.quick_sort(destinations, sort_by, reverse)
    else:
        result = SortingService.merge_sort(destinations, sort_by, reverse)
    
    return Response(result)


@api_view(['GET'])
@permission_classes([AllowAny])
def algorithm_graph_bfs(request):
    """
    BFS Algorithm
    GET /api/routes/bfs/?start=Kathmandu&end=Everest
    """
    start = request.GET.get('start', '')
    end = request.GET.get('end', None)
    
    if not start:
        return Response({'error': 'Start parameter required'}, status=400)
    
    destinations = list(Destination.objects.values())
    graph = GraphService.build_graph_from_destinations(destinations)
    result = GraphService.bfs(graph, start, end)
    
    return Response(result)


@api_view(['GET'])
@permission_classes([AllowAny])
def algorithm_graph_dfs(request):
    """
    DFS Algorithm
    GET /api/routes/dfs/?start=Kathmandu&end=Everest
    """
    start = request.GET.get('start', '')
    end = request.GET.get('end', None)
    
    if not start:
        return Response({'error': 'Start parameter required'}, status=400)
    
    destinations = list(Destination.objects.values())
    graph = GraphService.build_graph_from_destinations(destinations)
    result = GraphService.dfs(graph, start, end)
    
    return Response(result)


@api_view(['GET'])
@permission_classes([AllowAny])
def algorithm_graph_dijkstra(request):
    """
    Dijkstra's Shortest Path
    GET /api/routes/shortest-path/?start=Kathmandu&end=Everest
    """
    start = request.GET.get('start', '')
    end = request.GET.get('end', '')
    
    if not start or not end:
        return Response({'error': 'Both start and end required'}, status=400)
    
    destinations = list(Destination.objects.values())
    graph = GraphService.build_graph_from_destinations(destinations)
    result = GraphService.dijkstra(graph, start, end)
    
    return Response(result)


@api_view(['GET'])
@permission_classes([AllowAny])
def algorithm_greedy_budget(request):
    """
    Greedy Budget Optimizer
    GET /api/algorithms/greedy/budget/?budget=150000&strategy=maximize_trips|maximize_value
    """
    try:
        budget = float(request.GET.get('budget', 0))
    except ValueError:
        return Response({'error': 'Invalid budget'}, status=400)
    
    if budget <= 0:
        return Response({'error': 'Budget must be positive'}, status=400)
    
    strategy = request.GET.get('strategy', 'maximize_trips')
    destinations = list(Destination.objects.values())
    
    if strategy == 'maximize_value':
        result = GreedyService.maximize_value_in_budget(destinations, budget)
    else:
        result = GreedyService.maximize_trips_in_budget(destinations, budget)
    
    return Response(result)


@api_view(['GET'])
@permission_classes([AllowAny])
def algorithm_dp_plan(request):
    """
    DP Trip Planner
    GET /api/algorithms/dp/plan/?budget=150000&days=12&strategy=knapsack|maximize_destinations
    """
    try:
        budget = float(request.GET.get('budget', 0))
        max_days = request.GET.get('days', None)
        if max_days:
            max_days = int(max_days)
    except ValueError:
        return Response({'error': 'Invalid parameters'}, status=400)
    
    if budget <= 0:
        return Response({'error': 'Budget must be positive'}, status=400)
    
    strategy = request.GET.get('strategy', 'knapsack')
    destinations = list(Destination.objects.values())
    
    if strategy == 'maximize_destinations' and max_days:
        result = DynamicProgrammingService.maximize_destinations_in_days(
            destinations, max_days, budget
        )
    else:
        result = DynamicProgrammingService.knapsack_trip_planner(
            destinations, budget, max_days
        )
    
    return Response(result)


@api_view(['POST'])
@permission_classes([AllowAny])
def algorithm_recommendations(request):
    """
    Recommendation Engine
    POST /api/recommendations/
    Body (rule-based):
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
    
    Body (content-based):
    {
        "type": "content_based",
        "liked_destination_id": 1
    }
    """
    rec_type = request.data.get('type', 'rule_based')
    destinations = list(Destination.objects.values())
    
    if rec_type == 'content_based':
        liked_id = request.data.get('liked_destination_id')
        if not liked_id:
            return Response({'error': 'liked_destination_id required'}, status=400)
        result = RecommendationService.content_based_filtering(destinations, int(liked_id))
    else:
        preferences = request.data.get('preferences', {})
        result = RecommendationService.rule_based_recommendations(destinations, preferences)
    
    return Response(result)


@api_view(['GET'])
@permission_classes([AllowAny])
def algorithm_info(request):
    """
    Algorithm Information
    GET /api/algorithms/info/?name=binary_search
    """
    name = request.GET.get('name', '').lower()
    
    algorithms = {
        'linear_search': {
            'name': 'Linear Search',
            'time_complexity': 'O(n)',
            'space_complexity': 'O(1)',
            'description': 'Sequential search checking each element',
            'use_case': 'Unsorted data, small datasets',
            'best_case': 'O(1) - element at first position',
            'worst_case': 'O(n) - element at last position or not found',
        },
        'binary_search': {
            'name': 'Binary Search',
            'time_complexity': 'O(log n)',
            'space_complexity': 'O(1)',
            'description': 'Divides search space in half (requires sorted data)',
            'use_case': 'Sorted data, large datasets',
            'best_case': 'O(1) - element at middle',
            'worst_case': 'O(log n)',
        },
        'merge_sort': {
            'name': 'Merge Sort',
            'time_complexity': 'O(n log n)',
            'space_complexity': 'O(n)',
            'description': 'Divide-and-conquer stable sorting',
            'use_case': 'Large datasets, stability required',
            'advantages': ['Stable', 'Guaranteed O(n log n)', 'Parallelizable'],
        },
        'quick_sort': {
            'name': 'Quick Sort',
            'time_complexity': 'O(n log n) average',
            'space_complexity': 'O(log n)',
            'description': 'In-place sorting with pivot partitioning',
            'use_case': 'General purpose, memory-constrained',
            'worst_case': 'O(n²) with bad pivot selection',
        },
        'bfs': {
            'name': 'Breadth-First Search',
            'time_complexity': 'O(V + E)',
            'space_complexity': 'O(V)',
            'description': 'Level-order traversal, shortest path in unweighted graphs',
            'use_case': 'Shortest path, level-wise exploration',
        },
        'dfs': {
            'name': 'Depth-First Search',
            'time_complexity': 'O(V + E)',
            'space_complexity': 'O(V)',
            'description': 'Depth-first with backtracking',
            'use_case': 'Cycle detection, topological sorting, maze solving',
        },
        'dijkstra': {
            'name': "Dijkstra's Shortest Path",
            'time_complexity': 'O((V + E) log V)',
            'space_complexity': 'O(V)',
            'description': 'Shortest weighted path with priority queue',
            'use_case': 'GPS navigation, network routing',
        },
        'greedy': {
            'name': 'Greedy Algorithm',
            'time_complexity': 'O(n log n)',
            'space_complexity': 'O(n)',
            'description': 'Locally optimal choices',
            'use_case': 'Approximation, fractional knapsack',
        },
        'dp_knapsack': {
            'name': '0/1 Knapsack DP',
            'time_complexity': 'O(n × W)',
            'space_complexity': 'O(n × W)',
            'description': 'Optimal subset selection with constraints',
            'use_case': 'Resource allocation, trip planning',
        },
        'recommendation': {
            'name': 'Recommendation System',
            'time_complexity': 'O(n)',
            'space_complexity': 'O(n)',
            'description': 'Rule-based and content filtering',
            'use_case': 'Personalization, suggestions',
        }
    }
    
    if name in algorithms:
        return Response(algorithms[name])
    
    return Response({
        'available_algorithms': list(algorithms.keys()),
        'message': 'Specify algorithm name in query parameter',
        'example': '/api/algorithms/info/?name=binary_search'
    })


class TripPlannerAPIView(APIView):
    permission_classes = [AllowAny]

    @staticmethod
    def _sanitize_numeric_input(raw_value, field_name):
        """
        Sanitizes numeric user input to avoid malformed payloads.
        Accepts integer/decimal string formats only.
        """
        if raw_value is None:
            raise ValueError(f'{field_name} is required.')

        cleaned = str(raw_value).strip().replace(',', '')
        if not re.fullmatch(r'^\d+(\.\d+)?$', cleaned):
            raise ValueError(f'{field_name} must be numeric.')

        return cleaned

    def post(self, request):
        try:
            cleaned_payload = {
                'user_budget': self._sanitize_numeric_input(request.data.get('user_budget'), 'user_budget'),
                'max_days': self._sanitize_numeric_input(request.data.get('max_days'), 'max_days'),
            }

            serializer = TripPlannerRequestSerializer(data=cleaned_payload)
            if not serializer.is_valid():
                first_error = next(iter(serializer.errors.values()))[0]
                return Response(
                    {'error': str(first_error)},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            user_budget = int(float(serializer.validated_data['user_budget']))
            max_days = int(serializer.validated_data['max_days'])

            if user_budget < 5000:
                return Response(
                    {'error': 'Budget must be at least 5000 NPR.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if max_days < 2 or max_days > 5:
                return Response(
                    {'error': 'Available days must be between 2 and 5.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            treks = list(
                TrekDestination.objects.values(
                    'id', 'name', 'cost', 'duration_days', 'rating', 'difficulty', 'image_url'
                )
            )

            planner_result = TripPlannerService.optimize_itinerary(
                treks=treks,
                user_budget=user_budget,
                max_days=max_days,
            )

            return Response(
                {
                    'message': 'Optimal itinerary generated successfully.',
                    'data': {
                        'selected_treks': planner_result['selected_treks'],
                        'total_cost': planner_result['total_cost'],
                        'total_days': planner_result['total_days'],
                    },
                },
                status=status.HTTP_200_OK,
            )
        except ValueError as value_error:
            return Response({'error': str(value_error)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception:
            return Response(
                {'error': 'Unable to generate itinerary at the moment. Please try again.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
