import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/cost_breakdown.dart';
import '../models/weather_risk.dart';
import '../models/trek_itinerary.dart';

/// Service for trip planning, cost estimation, and optimization via backend DSA algorithms
class TripPlannerService {
  /// Backward-compatible endpoint used by the existing planner screen.
  Future<Map<String, dynamic>> generateOptimalItinerary({
    required int userBudget,
    required int maxDays,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.tripPlanner),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_budget': userBudget,
        'max_days': maxDays,
      }),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    }

    throw Exception('Failed to generate itinerary: ${response.statusCode}');
  }

  /// Get cost breakdown for a trek with optional services
  /// 
  /// This calls the backend Cost Estimator service which calculates:
  /// - Base price with nationality multiplier (SAARC: 50% discount)
  /// - Permit fees (SAARC vs International rates)
  /// - Guide costs (if included)
  /// - Porter costs (if included)
  /// - Detour costs (optional routes)
  Future<CostBreakdown> getCostBreakdown({
    required int destinationId,
    required int durationDays,
    required int numberOfPeople,
    required String nationality, // 'SAARC' or 'INTERNATIONAL'
    required bool includeGuide,
    int? selectedGuideId,
    required bool includePorter,
    int numberOfPorters = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cost-breakdown/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'destination_id': destinationId,
          'duration_days': durationDays,
          'number_of_people': numberOfPeople,
          'nationality': nationality,
          'include_guide': includeGuide,
          'selected_guide_id': selectedGuideId,
          'include_porter': includePorter,
          'number_of_porters': numberOfPorters,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return CostBreakdown.fromJson(json);
      } else {
        throw Exception('Failed to get cost breakdown: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Cost breakdown error: $e');
    }
  }

  /// Create itinerary with selected detours and dynamic cost estimation.
  Future<TrekItinerary> createItinerary({
    required int destinationId,
    required int durationDays,
    required int numberOfPeople,
    required String nationality,
    required bool includeGuide,
    int? selectedGuideId,
    required bool includePorter,
    int numberOfPorters = 0,
    List<int> selectedDetourIds = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Authentication required for itinerary creation');
    }

    final response = await http.post(
      Uri.parse(ApiConfig.itineraryCreate),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'destination_id': destinationId,
        'duration_days': durationDays,
        'number_of_people': numberOfPeople,
        'nationality': nationality,
        'include_guide': includeGuide,
        'selected_guide_id': selectedGuideId,
        'include_porter': includePorter,
        'number_of_porters': numberOfPorters,
        'selected_detour_ids': selectedDetourIds,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create itinerary: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return TrekItinerary.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Assess weather risk for a destination
  /// 
  /// This calls the backend Weather Risk Engine which evaluates:
  /// - Temperature severity
  /// - Precipitation levels
  /// - Wind speed
  /// - Altitude effects
  /// - Visibility conditions
  /// Returns: Risk level (LOW/MEDIUM/HIGH) with recommendations
  Future<WeatherRisk> getWeatherRisk(int destinationId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.weatherRisk),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'destination_id': destinationId}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WeatherRisk.fromJson(json);
      } else {
        throw Exception('Failed to get weather risk: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Weather risk error: $e');
    }
  }

  /// Optimize trip using Knapsack algorithm
  /// 
  /// This calls the backend Trip Optimizer which:
  /// 1. Runs 0/1 Knapsack DP: O(n×W) where n=detours, W=budget
  /// 2. Selects detours that maximize quality within budget/days
  /// 3. Calculates cost breakdown
  /// 4. Creates TrekItinerary with daily activities
  /// 5. Returns execution_steps showing algorithm decision process
  Future<TrekItinerary> optimizeTrip({
    required int destinationId,
    required double maxBudgetUsd,
    required int maxDays,
    required int numberOfPeople,
    required String nationality,
    required bool includeGuide,
    int? selectedGuideId,
    bool includePorter = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required for trip optimization');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.itineraryOptimize),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'destination_id': destinationId,
          'max_budget_usd': maxBudgetUsd,
          'max_days': maxDays,
          'number_of_people': numberOfPeople,
          'nationality': nationality,
          'include_guide': includeGuide,
          'selected_guide_id': selectedGuideId,
          'include_porter': includePorter,
        }),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return TrekItinerary.fromJson(json['itinerary']);
      } else {
        throw Exception('Trip optimization failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Trip optimization error: $e');
    }
  }

  /// Get algorithm execution steps for visualization
  /// 
  /// This calls the backend Algorithm Visualizer endpoint which:
  /// 1. Runs specified algorithm (binary_search, knapsack, dijkstra, etc.)
  /// 2. Tracks each decision made during execution
  /// 3. Returns execution_steps for UI visualization
  /// 4. Perfect for showing "Show Algorithm Steps" toggle
  Future<Map<String, dynamic>> getAlgorithmSteps({
    required String algorithm, // 'binary_search', 'linear_search', 'quicksort', 'mergesort', 'dijkstra', 'knapsack'
    required List<Map<String, dynamic>> items,
    String? searchQuery,
    String? sortKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/algorithm-visualizer/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'algorithm': algorithm,
          'items': items,
          if (searchQuery != null) 'search_query': searchQuery,
          if (sortKey != null) 'sort_key': sortKey,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get algorithm steps: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Algorithm visualizer error: $e');
    }
  }

  /// Get list of available detours for a destination
  Future<List<Detour>> getDetours(int destinationId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/detours/?destination=$destinationId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List results = json['results'] ?? json;
        return results
            .map((d) => Detour.fromJson(d as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get detours: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Detours fetch error: $e');
    }
  }

  Future<List<GuideProfile>> getGuides() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/guides/'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List results = json['results'] ?? json;
        return results
            .map((g) => GuideProfile.fromJson(g as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get guides: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Guides fetch error: $e');
    }
  }

  /// Get user's itineraries
  Future<List<TrekItinerary>> getItineraries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/itineraries/'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List results = json['results'] ?? json;
        return results
            .map((i) => TrekItinerary.fromJson(i as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get itineraries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Itineraries fetch error: $e');
    }
  }

  /// Get single itinerary by ID
  Future<TrekItinerary> getItineraryDetail(int itineraryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/itineraries/$itineraryId/'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return TrekItinerary.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get itinerary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Itinerary detail error: $e');
    }
  }

  /// Update itinerary (e.g., add/remove detours)
  Future<TrekItinerary> updateItinerary(
    int itineraryId, {
    List<int>? detourIds,
    String? status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      final body = <String, dynamic>{};
      if (detourIds != null) body['selected_detours'] = detourIds;
      if (status != null) body['status'] = status;

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/itineraries/$itineraryId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return TrekItinerary.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update itinerary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Itinerary update error: $e');
    }
  }
}
