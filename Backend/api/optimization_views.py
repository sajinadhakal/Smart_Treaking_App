"""
Optimization API Views
Endpoints for DSA-based trek optimization and visualization
Routes:
- /api/optimize-trip/ - Knapsack optimization
- /api/cost-breakdown/ - Dynamic cost estimation
- /api/weather-risk/ - Weather risk assessment
- /api/algorithm-visualizer/ - Algorithm execution visualization
"""

from rest_framework import status, viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
from datetime import datetime, timedelta
import heapq
import math

from api.models import Destination, Detour, TrekItinerary, TrekActivity, CostConfiguration, Guide
from api.serializers import (
    CostBreakdownRequestSerializer, CostBreakdownResponseSerializer,
    WeatherRiskRequestSerializer, WeatherRiskResponseSerializer,
    TripPlannerOptimizeRequestSerializer, TripPlannerOptimizeResponseSerializer,
    AlgorithmVisualizerRequestSerializer, AlgorithmVisualizerResponseSerializer,
    TrekItinerarySerializer, DetourSerializer, CostConfigurationSerializer, GuideSerializer
)
from api.services.logic_engine import analyze_trek
from services.algorithms import (
    KnapsackAlgorithm, DijkstraAlgorithm, BinarySearchAlgorithm,
    QuickSortAlgorithm, MergeSortAlgorithm, LinearSearchAlgorithm
)
from services.cost_estimator import CostEstimator
from services.trip_planner import TripPlannerService
from services.weather_risk_engine import WeatherRiskEngine


def _haversine_km(lat1, lon1, lat2, lon2):
    """Approximate great-circle distance in KM between two lat/lon points."""
    radius_km = 6371.0
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    a = (
        math.sin(d_lat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(d_lon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return radius_km * c


def _create_itinerary_activities(itinerary, destination):
    """Populate itinerary with altitude-aware activity stops for frontend altitude curve."""
    route_points = list(destination.route_points.order_by('sequence_order'))

    if route_points:
        for index, point in enumerate(route_points, start=1):
            TrekActivity.objects.create(
                itinerary=itinerary,
                day_number=index,
                sequence_order=1,
                name=point.location_name or f'Stop {index}',
                description=point.description or '',
                latitude=point.latitude,
                longitude=point.longitude,
                altitude=point.altitude,
                activity_type='END' if index == len(route_points) else ('START' if index == 1 else 'WALK'),
                difficulty=destination.difficulty,
            )
        return

    # Fallback for destinations without route metadata.
    TrekActivity.objects.create(
        itinerary=itinerary,
        day_number=1,
        sequence_order=1,
        name=f'{destination.name} Base Trek',
        description='Base itinerary generated from destination metadata.',
        latitude=destination.latitude,
        longitude=destination.longitude,
        altitude=destination.altitude,
        activity_type='END',
        difficulty=destination.difficulty,
    )


def _resolve_selected_guide(guide_id):
    if not guide_id:
        return None
    try:
        return Guide.objects.get(id=int(guide_id), is_active=True)
    except (Guide.DoesNotExist, TypeError, ValueError):
        return None


def _to_bool(value, default=False):
    """Parse query-string booleans safely."""
    if value is None:
        return default
    if isinstance(value, bool):
        return value
    return str(value).strip().lower() in {'1', 'true', 'yes', 'on'}


def _optimize_detour_path_with_dijkstra(destination, detours):
    """
    Uses Dijkstra on state-space (node, visited_mask) to find the shortest route
    that visits all selected detours and returns to destination.

    Time Complexity: O((2^n) * n^2 * log((2^n) * n)) for n detours.
    Space Complexity: O((2^n) * n).
    """
    if not detours:
        return {
            'ordered_detours': [],
            'total_distance_km': 0.0,
            'execution_steps': ['No detours selected; base route retained.'],
        }

    n = len(detours)
    all_mask = (1 << n) - 1
    execution_steps = [
        f"Dijkstra state-space optimization started for {n} selected detours.",
        f"States: (current_node, visited_mask), target mask={all_mask}."
    ]

    # Pre-compute directed travel costs between nodes.
    start_to = []
    end_to_start = []
    detour_to_end = []
    detour_to_detour = [[0.0 for _ in range(n)] for _ in range(n)]

    for detour in detours:
        to_start = _haversine_km(
            destination.latitude,
            destination.longitude,
            detour.start_latitude,
            detour.start_longitude,
        )
        back_to_base = _haversine_km(
            detour.end_latitude,
            detour.end_longitude,
            destination.latitude,
            destination.longitude,
        )
        start_to.append(to_start + float(detour.distance_km))
        detour_to_end.append(back_to_base)

    for i, from_detour in enumerate(detours):
        for j, to_detour in enumerate(detours):
            if i == j:
                continue
            transition = _haversine_km(
                from_detour.end_latitude,
                from_detour.end_longitude,
                to_detour.start_latitude,
                to_detour.start_longitude,
            ) + float(to_detour.distance_km)
            detour_to_detour[i][j] = transition

    # Dijkstra over state graph. node_index = -1 means base/start position.
    dist = {(-1, 0): 0.0}
    parent = {}
    heap = [(0.0, -1, 0)]
    expanded = 0

    while heap:
        current_cost, node_index, mask = heapq.heappop(heap)
        if current_cost > dist.get((node_index, mask), float('inf')):
            continue

        expanded += 1
        if expanded % 20 == 0:
            execution_steps.append(f"Expanded {expanded} states so far.")

        if mask == all_mask:
            final_cost = current_cost
            if node_index != -1:
                final_cost += detour_to_end[node_index]
            end_state = (node_index, mask, 'END')
            parent[end_state] = (node_index, mask)
            dist[end_state] = final_cost
            execution_steps.append(f"Reached full mask after {expanded} expansions.")
            break

        for nxt in range(n):
            if mask & (1 << nxt):
                continue

            if node_index == -1:
                edge_cost = start_to[nxt]
            else:
                edge_cost = detour_to_detour[node_index][nxt]

            new_mask = mask | (1 << nxt)
            new_state = (nxt, new_mask)
            new_cost = current_cost + edge_cost

            if new_cost < dist.get(new_state, float('inf')):
                dist[new_state] = new_cost
                parent[new_state] = (node_index, mask)
                heapq.heappush(heap, (new_cost, nxt, new_mask))
    else:
        # Fallback: preserve user-selected order if optimization fails unexpectedly.
        fallback_distance = sum(float(d.distance_km) for d in detours)
        execution_steps.append('Optimization fallback used; preserving selected detour order.')
        return {
            'ordered_detours': detours,
            'total_distance_km': fallback_distance,
            'execution_steps': execution_steps,
        }

    # Reconstruct path from END sentinel.
    ordered_indices = []
    cursor = end_state
    while cursor in parent:
        prev = parent[cursor]
        if isinstance(cursor, tuple) and len(cursor) == 2 and cursor[0] != -1:
            ordered_indices.append(cursor[0])
        cursor = prev
    ordered_indices.reverse()

    ordered_detours = [detours[i] for i in ordered_indices]
    optimized_distance = dist.get(end_state, 0.0)
    ordered_names = ', '.join(d.name for d in ordered_detours) if ordered_detours else 'None'
    execution_steps.append(f"Optimized detour order: {ordered_names}")
    execution_steps.append(f"Estimated optimized route distance: {optimized_distance:.2f} km")

    return {
        'ordered_detours': ordered_detours,
        'total_distance_km': optimized_distance,
        'execution_steps': execution_steps,
    }


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_itinerary_view(request):
    """
    Create custom itinerary with optional detours and route recalculation.

    POST /api/itinerary/create/
    {
        "destination_id": 1,
        "duration_days": 12,
        "number_of_people": 2,
        "nationality": "INTERNATIONAL",
        "include_guide": true,
        "include_porter": false,
        "number_of_porters": 0,
        "selected_detour_ids": [1, 2]
    }
    """
    payload = request.data

    required_fields = ['destination_id', 'duration_days', 'number_of_people', 'nationality']
    for field in required_fields:
        if field not in payload:
            return Response({'error': f'{field} is required'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        destination = Destination.objects.get(id=payload.get('destination_id'))
    except Destination.DoesNotExist:
        return Response({'error': 'Destination not found'}, status=status.HTTP_404_NOT_FOUND)

    try:
        duration_days = int(payload.get('duration_days'))
        number_of_people = int(payload.get('number_of_people'))
        number_of_porters = int(payload.get('number_of_porters', 0))
    except (TypeError, ValueError):
        return Response({'error': 'Duration, people, and porter fields must be numeric.'}, status=status.HTTP_400_BAD_REQUEST)

    if duration_days < 2 or duration_days > 5:
        return Response(
            {'error': 'Duration days must be between 2 and 5.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    if number_of_people < 1 or number_of_porters < 0:
        return Response({'error': 'People and porters must be positive values.'}, status=status.HTTP_400_BAD_REQUEST)

    nationality = str(payload.get('nationality', 'INTERNATIONAL')).upper()
    if nationality == 'SAARC':
        nationality = 'NEPALI'
    if nationality not in ['NEPALI', 'INTERNATIONAL']:
        return Response({'error': 'Nationality must be NEPALI or INTERNATIONAL.'}, status=status.HTTP_400_BAD_REQUEST)

    include_guide = bool(payload.get('include_guide', False))
    include_porter = bool(payload.get('include_porter', False))
    selected_guide = _resolve_selected_guide(payload.get('selected_guide_id'))
    selected_detour_ids = payload.get('selected_detour_ids', []) or []

    if destination.is_restricted_area and selected_guide is None:
        return Response(
            {'error': 'Guide selection is mandatory for restricted destinations.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    if selected_guide is not None:
        include_guide = True

    detours = list(Detour.objects.filter(id__in=selected_detour_ids, destination=destination))
    if len(detours) != len(selected_detour_ids):
        return Response({'error': 'One or more selected detours are invalid for this destination.'}, status=status.HTTP_400_BAD_REQUEST)

    # Preserve caller order for deterministic behavior before optimization.
    detour_lookup = {d.id: d for d in detours}
    ordered_request_detours = [detour_lookup[did] for did in selected_detour_ids]

    dependency_errors = []
    selected_detour_id_set = set(selected_detour_ids)
    for detour in ordered_request_detours:
        required_ids = set(detour.required_before_detours.values_list('id', flat=True))
        missing = required_ids - selected_detour_id_set
        if missing:
            dependency_errors.append(
                f"{detour.name} requires detour IDs: {', '.join(str(x) for x in sorted(missing))}"
            )

    if dependency_errors:
        return Response(
            {'error': 'Detour dependency validation failed.', 'details': dependency_errors},
            status=status.HTTP_400_BAD_REQUEST,
        )

    estimator = CostEstimator()
    cost_result = estimator.estimate_cost(
        destination=destination,
        duration_days=duration_days,
        number_of_people=number_of_people,
        nationality=nationality,
        include_guide=include_guide,
        selected_guide=selected_guide,
        include_porter=include_porter,
        number_of_porters=number_of_porters,
        selected_detour_ids=[d.id for d in ordered_request_detours],
    )

    route_steps = []
    optimized_detours = ordered_request_detours
    optimized_distance = float(cost_result.get('total_duration_days', duration_days)) * 6.0
    if ordered_request_detours:
        route_result = _optimize_detour_path_with_dijkstra(destination, ordered_request_detours)
        optimized_detours = route_result['ordered_detours']
        optimized_distance = route_result['total_distance_km']
        route_steps = route_result['execution_steps']

    altitude_sequence = list(
        destination.route_points.order_by('sequence_order').values_list('altitude', flat=True)
    )
    if not altitude_sequence:
        altitude_sequence = [destination.altitude]

    safe_acclimatization = TripPlannerService.is_safe_acclimatization(altitude_sequence)

    start_date = datetime.now().date() + timedelta(days=1)
    end_date = start_date + timedelta(days=cost_result['total_duration_days'] - 1)

    itinerary = TrekItinerary.objects.create(
        user=request.user,
        destination=destination,
        selected_guide=selected_guide,
        start_date=start_date,
        end_date=end_date,
        base_cost=cost_result['base_cost'],
        permit_cost=cost_result['permit_cost'],
        guide_cost=cost_result['guide_cost'],
        porter_cost=cost_result['porter_cost'],
        detour_cost=cost_result['detour_cost'],
        total_cost=cost_result['total_cost'],
        number_of_people=number_of_people,
        include_guide=include_guide,
        include_porter=include_porter,
        number_of_porters=number_of_porters,
        total_duration_days=cost_result['total_duration_days'],
        total_distance_km=optimized_distance,
        algorithm_used='dijkstra+cost_estimator' if detours else 'cost_estimator',
        execution_steps=cost_result['execution_steps'] + route_steps,
        status='DRAFT',
    )

    itinerary.selected_detours.set(optimized_detours)
    _create_itinerary_activities(itinerary, destination)

    activity_stops = [
        {'name': a.name, 'altitude': a.altitude}
        for a in itinerary.activities.order_by('day_number', 'sequence_order')
    ]
    safety_snapshot = analyze_trek(
        route_stops=activity_stops,
        nationality='Foreigner' if nationality == 'INTERNATIONAL' else 'Nepali',
        is_restricted_area=destination.is_restricted_area,
        selected_guide=selected_guide,
    )
    itinerary.calculated_safety_json = safety_snapshot
    itinerary.execution_steps = itinerary.execution_steps + safety_snapshot.get('algorithm_steps', [])
    itinerary.save(update_fields=['calculated_safety_json', 'execution_steps'])

    if not safe_acclimatization:
        itinerary.execution_steps = itinerary.execution_steps + [
            'Safety Alert: Altitude gain exceeds 500m above 3000m. Add acclimatization rest day.'
        ]
        itinerary.save(update_fields=['execution_steps'])

    return Response(
        {
            'message': 'Itinerary created',
            'data': TrekItinerarySerializer(itinerary).data,
        },
        status=status.HTTP_201_CREATED,
    )


@api_view(['POST'])
@permission_classes([AllowAny])
def cost_breakdown_view(request):
    """
    Calculate dynamic trek cost based on various parameters.
    
    POST /api/cost-breakdown/
    {
        "destination_id": 1,
        "duration_days": 12,
        "number_of_people": 3,
        "nationality": "INTERNATIONAL",
        "include_guide": true,
        "include_porter": true,
        "number_of_porters": 2,
        "selected_detour_ids": [1, 3]
    }
    """
    serializer = CostBreakdownRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        destination = Destination.objects.get(id=serializer.validated_data['destination_id'])
    except Destination.DoesNotExist:
        return Response({'error': 'Destination not found'}, status=status.HTTP_404_NOT_FOUND)
    
    # Use Cost Estimator
    estimator = CostEstimator()
    cost_result = estimator.estimate_cost(
        destination=destination,
        duration_days=serializer.validated_data['duration_days'],
        number_of_people=serializer.validated_data['number_of_people'],
        nationality=serializer.validated_data['nationality'],
        include_guide=serializer.validated_data['include_guide'],
        selected_guide=_resolve_selected_guide(serializer.validated_data.get('selected_guide_id')),
        include_porter=serializer.validated_data['include_porter'],
        number_of_porters=serializer.validated_data['number_of_porters'],
        selected_detour_ids=serializer.validated_data.get('selected_detour_ids', [])
    )
    
    response_data = {
        'base_cost': float(cost_result['base_cost']),
        'permit_cost': float(cost_result['permit_cost']),
        'guide_cost': float(cost_result['guide_cost']),
        'porter_cost': float(cost_result['porter_cost']),
        'detour_cost': float(cost_result['detour_cost']),
        'total_cost': float(cost_result['total_cost']),
        'cost_per_person': float(cost_result['cost_per_person']),
        'cost_breakdown': cost_result['cost_breakdown'],
        'detailed_expenses': cost_result.get('detailed_expenses', {}),
        'per_person_expenses': cost_result.get('per_person_expenses', {}),
        'duration_days': serializer.validated_data['duration_days'],
        'number_of_people': serializer.validated_data['number_of_people'],
        'selected_detours': DetourSerializer(cost_result['selected_detours'], many=True).data,
        'total_duration_days': cost_result['total_duration_days'],
        'suggested_cash_npr': TripPlannerService.calculate_cash_required_npr(
            duration_days=cost_result['total_duration_days'],
            number_of_people=serializer.validated_data['number_of_people'],
            base_cost=cost_result['base_cost'],
            permit_cost=cost_result['permit_cost'],
        ),
        'execution_steps': cost_result['execution_steps']
    }
    
    return Response(response_data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([AllowAny])
def all_treks_cost_breakdown_view(request):
    """
    Calculate cost breakdown for all available treks.

    GET /api/cost-breakdown/all-treks/?duration_days=5&number_of_people=2&nationality=NEPALI
    """
    try:
        duration_days = int(request.query_params.get('duration_days', 0) or 0)
    except (TypeError, ValueError):
        duration_days = 0

    try:
        number_of_people = int(request.query_params.get('number_of_people', 1) or 1)
    except (TypeError, ValueError):
        number_of_people = 1

    include_guide = _to_bool(request.query_params.get('include_guide'), default=False)
    include_porter = _to_bool(request.query_params.get('include_porter'), default=False)

    try:
        number_of_porters = int(request.query_params.get('number_of_porters', 0) or 0)
    except (TypeError, ValueError):
        number_of_porters = 0

    nationality = str(request.query_params.get('nationality', 'NEPALI')).upper().strip()
    if nationality == 'SAARC':
        nationality = 'NEPALI'
    if nationality not in ['NEPALI', 'INTERNATIONAL']:
        nationality = 'NEPALI'

    if number_of_people < 1:
        return Response({'error': 'number_of_people must be at least 1'}, status=status.HTTP_400_BAD_REQUEST)

    if number_of_porters < 0:
        return Response({'error': 'number_of_porters cannot be negative'}, status=status.HTTP_400_BAD_REQUEST)

    estimator = CostEstimator()
    destinations = Destination.objects.all().order_by('name')
    results = []

    for destination in destinations:
        actual_days = duration_days if duration_days > 0 else int(destination.duration_days or 1)
        selected_guide = None

        if destination.is_restricted_area:
            selected_guide = Guide.objects.filter(is_active=True).order_by('daily_rate').first()

        effective_include_guide = include_guide or destination.is_restricted_area

        cost_result = estimator.estimate_cost(
            destination=destination,
            duration_days=actual_days,
            number_of_people=number_of_people,
            nationality=nationality,
            include_guide=effective_include_guide,
            selected_guide=selected_guide,
            include_porter=include_porter,
            number_of_porters=number_of_porters,
            selected_detour_ids=[],
        )

        results.append({
            'destination_id': destination.id,
            'destination_name': destination.name,
            'location': destination.location,
            'duration_days': actual_days,
            'number_of_people': number_of_people,
            'nationality': nationality,
            'include_guide': effective_include_guide,
            'include_porter': include_porter,
            'number_of_porters': number_of_porters,
            'detailed_expenses': cost_result.get('detailed_expenses', {}),
            'per_person_expenses': cost_result.get('per_person_expenses', {}),
            'total_cost': float(cost_result['total_cost']),
            'cost_per_person': float(cost_result['cost_per_person']),
            'suggested_cash_npr': TripPlannerService.calculate_cash_required_npr(
                duration_days=cost_result['total_duration_days'],
                number_of_people=number_of_people,
                base_cost=cost_result['base_cost'],
                permit_cost=cost_result['permit_cost'],
            ),
        })

    return Response(
        {
            'count': len(results),
            'params': {
                'duration_days': duration_days if duration_days > 0 else None,
                'number_of_people': number_of_people,
                'nationality': nationality,
                'include_guide': include_guide,
                'include_porter': include_porter,
                'number_of_porters': number_of_porters,
            },
            'results': results,
        },
        status=status.HTTP_200_OK,
    )


@api_view(['POST'])
@permission_classes([AllowAny])
def weather_risk_view(request):
    """
    Assess weather risk for a destination.
    
    POST /api/weather-risk/
    {
        "destination_id": 1,
        "date": "2024-05-15"  // optional
    }
    """
    serializer = WeatherRiskRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        destination = Destination.objects.get(id=serializer.validated_data['destination_id'])
    except Destination.DoesNotExist:
        return Response({'error': 'Destination not found'}, status=status.HTTP_404_NOT_FOUND)

    selected_guide = _resolve_selected_guide(serializer.validated_data.get('selected_guide_id'))
    if destination.is_restricted_area and selected_guide is None:
        return Response({'error': 'Guide selection is mandatory for restricted destinations.'}, status=status.HTTP_400_BAD_REQUEST)
    
    check_date = None
    if 'date' in serializer.validated_data and serializer.validated_data['date']:
        check_date = datetime.combine(serializer.validated_data['date'], datetime.min.time())
    
    try:
        # Use Weather Risk Engine
        risk_engine = WeatherRiskEngine()
        risk_result = risk_engine.assess_risk(destination, check_date)

        response_data = {
            'risk_level': risk_result.get('risk_level', 'MEDIUM'),
            'factors': risk_result.get('factors', {}),
            'recommendations': risk_result.get('recommendations', ['Proceed with caution due to limited weather analysis.']),
            'weather_data': risk_result.get('weather_data', {}),
            'execution_steps': risk_result.get('execution_steps', [])
        }

        return Response(response_data, status=status.HTTP_200_OK)
    except Exception as e:
        return Response(
            {
                'error': 'Failed to assess weather risk.',
                'details': str(e),
                'risk_level': 'MEDIUM',
                'factors': {},
                'recommendations': ['Unable to run full weather analysis. Proceed with caution.'],
                'weather_data': {},
                'execution_steps': []
            },
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def optimize_trip_view(request):
    """
    Optimize trip using 0/1 Knapsack - maximize trek quality within budget/time constraints.
    
    POST /api/optimize-trip/
    {
        "destination_id": 1,
        "max_budget_usd": 5000,
        "max_days": 14,
        "number_of_people": 2,
        "nationality": "INTERNATIONAL",
        "include_guide": true,
        "include_porter": false
    }
    """
    serializer = TripPlannerOptimizeRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        destination = Destination.objects.get(id=serializer.validated_data['destination_id'])
    except Destination.DoesNotExist:
        return Response({'error': 'Destination not found'}, status=status.HTTP_404_NOT_FOUND)
    
    # Get all available detours
    detours = Detour.objects.filter(destination=destination, is_optional=True)
    detour_dicts = [{
        'id': d.id,
        'name': d.name,
        'cost': float(d.extra_cost_usd),
        'days': d.extra_days,
        'quality_rating': d.quality_rating,
        'difficulty': d.difficulty
    } for d in detours]
    
    # Run Knapsack Algorithm
    knapsack = KnapsackAlgorithm()
    knapsack_result = knapsack.solve(
        detours=detour_dicts,
        max_budget=float(serializer.validated_data['max_budget_usd']),
        max_days=serializer.validated_data['max_days']
    )
    
    # Get selected detour IDs
    selected_detour_ids = [d['id'] for d in knapsack_result['selected_detours']]
    
    # Calculate cost breakdown
    estimator = CostEstimator()
    cost_result = estimator.estimate_cost(
        destination=destination,
        duration_days=serializer.validated_data['max_days'],
        number_of_people=serializer.validated_data['number_of_people'],
        nationality=serializer.validated_data['nationality'],
        include_guide=serializer.validated_data['include_guide'],
        selected_guide=selected_guide,
        include_porter=serializer.validated_data['include_porter'],
        number_of_porters=1 if serializer.validated_data['include_porter'] else 0,
        selected_detour_ids=selected_detour_ids
    )
    
    # Create Trek Itinerary
    start_date = datetime.now().date() + timedelta(days=1)
    end_date = start_date + timedelta(days=cost_result['total_duration_days'] - 1)
    
    itinerary = TrekItinerary.objects.create(
        user=request.user,
        destination=destination,
        selected_guide=selected_guide,
        start_date=start_date,
        end_date=end_date,
        base_cost=cost_result['base_cost'],
        permit_cost=cost_result['permit_cost'],
        guide_cost=cost_result['guide_cost'],
        porter_cost=cost_result['porter_cost'],
        detour_cost=cost_result['detour_cost'],
        total_cost=cost_result['total_cost'],
        number_of_people=serializer.validated_data['number_of_people'],
        include_guide=serializer.validated_data['include_guide'],
        include_porter=serializer.validated_data['include_porter'],
        total_duration_days=cost_result['total_duration_days'],
        algorithm_used='knapsack',
        execution_steps=knapsack_result['execution_steps'] + cost_result['execution_steps'],
        status='DRAFT'
    )
    
    # Add selected detours
    for detour_id in selected_detour_ids:
        itinerary.selected_detours.add(detour_id)
    
    # Create activities for each day (simplified - can be expanded)
    current_date = start_date
    for day in range(1, cost_result['total_duration_days'] + 1):
        TrekActivity.objects.create(
            itinerary=itinerary,
            day_number=day,
            sequence_order=1,
            name=f"Day {day} - Trek",
            latitude=destination.latitude,
            longitude=destination.longitude,
            altitude=destination.altitude,
            activity_type='WALK' if day < cost_result['total_duration_days'] else 'END',
            difficulty=destination.difficulty
        )

    activity_stops = [
        {'name': a.name, 'altitude': a.altitude}
        for a in itinerary.activities.order_by('day_number', 'sequence_order')
    ]
    safety_snapshot = analyze_trek(
        route_stops=activity_stops,
        nationality='Foreigner' if serializer.validated_data['nationality'] == 'INTERNATIONAL' else 'Nepali',
        is_restricted_area=destination.is_restricted_area,
        selected_guide=selected_guide,
    )
    itinerary.calculated_safety_json = safety_snapshot
    itinerary.execution_steps = itinerary.execution_steps + safety_snapshot.get('algorithm_steps', [])
    itinerary.save(update_fields=['calculated_safety_json', 'execution_steps'])
    
    # Response
    response_data = {
        'itinerary': TrekItinerarySerializer(itinerary).data,
        'algorithm_used': 'knapsack',
        'optimization_metrics': {
            'selected_detours_count': len(selected_detour_ids),
            'total_quality': knapsack_result['total_quality'],
            'budget_used': float(cost_result['total_cost']),
            'budget_available': float(serializer.validated_data['max_budget_usd']),
            'budget_remaining': float(serializer.validated_data['max_budget_usd'] - cost_result['total_cost'])
        },
        'execution_steps': knapsack_result['execution_steps']
    }
    
    return Response(response_data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([AllowAny])
def algorithm_visualizer_view(request):
    """
    Run algorithm and return step-by-step execution for visualization.
    
    POST /api/algorithm-visualizer/
    {
        "algorithm": "binary_search",  // or querying which algorithm
        "items": [...],
        "search_query": 2500  (for searches)
    }
    """
    serializer = AlgorithmVisualizerRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    algorithm_name = serializer.validated_data['algorithm']
    items = serializer.validated_data['items']
    
    result = {}
    metrics = {}
    
    if algorithm_name == 'binary_search':
        # Binary search requires sorted items
        search_algo = BinarySearchAlgorithm()
        sorted_items = sorted(items, key=lambda x: x.get('price', 0))
        search_result = search_algo.search(sorted_items, target_price=float(serializer.validated_data.get('search_query', 0)))
        result = search_result
        metrics = {'iterations': search_result['iterations']}
    
    elif algorithm_name == 'linear_search':
        search_algo = LinearSearchAlgorithm()
        predicate = lambda x: float(x.get('price', 0)) <= float(serializer.validated_data.get('search_query', 0))
        search_result = search_algo.search(items, predicate)
        result = search_result
        metrics = {'iterations': search_result['iterations']}
    
    elif algorithm_name == 'quicksort':
        sort_algo = QuickSortAlgorithm()
        sort_result = sort_algo.sort(items, key=serializer.validated_data.get('sort_key', 'price'))
        result = sort_result
        metrics = {'comparisons': sort_result['comparisons'], 'time_complexity': 'O(n log n) average, O(n²) worst case'}
    
    elif algorithm_name == 'mergesort':
        sort_algo = MergeSortAlgorithm()
        sort_result = sort_algo.sort(items, key=serializer.validated_data.get('sort_key', 'price'))
        result = sort_result
        metrics = {'comparisons': sort_result['comparisons'], 'time_complexity': 'O(n log n) guaranteed', 'space_complexity': 'O(n)'}
    
    elif algorithm_name == 'dijkstra':
        # Simplified Dijkstra for visualization
        dijkstra_algo = DijkstraAlgorithm()
        # Build simple graph from items representing trek nodes
        graph = {}
        for item in items[:5]:  # Use first 5 items as nodes
            graph[item.get('name', 'node')] = []
        
        result = dijkstra_algo.solve('start', 'end', graph)
        metrics = {'algorithm': 'Dijkstra', 'time_complexity': 'O((V + E) log V)'}
    
    elif algorithm_name == 'knapsack':
        # Simplified Knapsack for visualization
        knapsack = KnapsackAlgorithm()
        result = knapsack.solve(items[:5], max_budget=5000, max_days=10)
        metrics = {'items_considered': len(items[:5]), 'time_complexity': 'O(n * W)'}
    
    else:
        return Response({'error': 'Unknown algorithm'}, status=status.HTTP_400_BAD_REQUEST)
    
    response_data = {
        'algorithm': algorithm_name,
        'result': result,
        'execution_steps': result.get('execution_steps', []),
        'metrics': metrics
    }
    
    return Response(response_data, status=status.HTTP_200_OK)


# ViewSets for CRUD operations

class DetourViewSet(viewsets.ModelViewSet):
    """CRUD for optional detours (read for all, write for authenticated users)."""
    queryset = Detour.objects.all()
    serializer_class = DetourSerializer
    filterset_fields = ['destination', 'difficulty', 'is_optional']
    search_fields = ['name', 'description']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsAuthenticated()]


class CostConfigurationViewSet(viewsets.ModelViewSet):
    """Admin CRUD for destination pricing configuration."""
    queryset = CostConfiguration.objects.select_related('destination').all()
    serializer_class = CostConfigurationSerializer
    permission_classes = [IsAdminUser]
    filterset_fields = ['destination']
    search_fields = ['destination__name']


class GuideViewSet(viewsets.ModelViewSet):
    """Guide directory for itinerary matching and restricted-area compliance."""
    queryset = Guide.objects.filter(is_active=True)
    serializer_class = GuideSerializer
    filterset_fields = ['specialization', 'is_active']
    search_fields = ['name', 'license_number', 'specialization']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsAdminUser()]


class TrekItineraryViewSet(viewsets.ModelViewSet):
    """ViewSet for user's trek itineraries"""
    serializer_class = TrekItinerarySerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return TrekItinerary.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
