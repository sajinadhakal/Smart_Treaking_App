import 'package:flutter/material.dart';
import '../models/cost_breakdown.dart';
import '../models/destination.dart';
import '../models/trek_itinerary.dart';
import '../models/weather_risk.dart';
import '../services/destination_service.dart';
import '../services/trip_planner_service.dart';

class ItineraryProvider extends ChangeNotifier {
  final DestinationService _destinationService = DestinationService();
  final TripPlannerService _tripPlannerService = TripPlannerService();

  bool isLoading = false;
  bool isCreating = false;
  bool devMode = false;
  String? error;
  bool isLoadingMore = false;
  String? _destinationsNextUrl;

  List<Destination> destinations = [];
  Destination? selectedDestination;
  List<Detour> availableDetours = [];
  List<GuideProfile> availableGuides = [];
  int? selectedGuideId;
  Set<int> selectedDetourIds = {};

  CostBreakdown? currentCostBreakdown;
  WeatherRisk? currentWeatherRisk;
  TrekItinerary? currentItinerary;

  List<String> binarySearchSteps = [];
  List<String> quickSortSteps = [];

  List<Destination> _uniqueDestinationsById(List<Destination> source) {
    final map = <int, Destination>{};
    for (final destination in source) {
      map[destination.id] = destination;
    }
    return map.values.toList();
  }

  void _syncSelectedDestination() {
    final selectedId = selectedDestination?.id;
    if (selectedId == null) {
      return;
    }

    final matches = destinations.where((d) => d.id == selectedId).toList();
    if (matches.length == 1) {
      selectedDestination = matches.first;
    } else {
      selectedDestination = null;
    }
  }

  Future<void> bootstrapPlanner() async {
    await loadDestinations();
    if (destinations.isNotEmpty) {
      await selectDestination(destinations.first.id);
    }
  }

  Future<void> loadDestinations({String? search, String? ordering}) async {
    _setLoading(true);
    error = null;

    try {
      final page = await _destinationService.getDestinationsPage(
        search: search,
        ordering: ordering,
        page: 1,
      );
      destinations = _uniqueDestinationsById(page.destinations);
      _destinationsNextUrl = page.next;
      _syncSelectedDestination();
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  bool get hasMoreDestinations => _destinationsNextUrl != null;

  Future<void> loadMoreDestinations() async {
    if (isLoadingMore || _destinationsNextUrl == null) {
      return;
    }

    isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _destinationService.getDestinationsPage(
        pageUrl: _destinationsNextUrl,
      );
      destinations = _uniqueDestinationsById([
        ...destinations,
        ...page.destinations,
      ]);
      _destinationsNextUrl = page.next;
      _syncSelectedDestination();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> selectDestination(int destinationId) async {
    _setLoading(true);
    error = null;

    try {
      final destination = destinations.firstWhere((d) => d.id == destinationId);
      selectedDestination = destination;
      selectedDetourIds.clear();
      selectedGuideId = null;

      availableDetours = await _tripPlannerService.getDetours(destinationId);
      availableGuides = await _tripPlannerService.getGuides();
      currentWeatherRisk =
          await _tripPlannerService.getWeatherRisk(destinationId);
      currentCostBreakdown = null;
      currentItinerary = null;
      binarySearchSteps = [];
      quickSortSteps = [];
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void toggleDetour(int detourId, bool selected) {
    if (selected) {
      selectedDetourIds.add(detourId);
    } else {
      selectedDetourIds.remove(detourId);
    }
    notifyListeners();
  }

  void selectGuide(int? guideId) {
    selectedGuideId = guideId;
    notifyListeners();
  }

  Future<void> calculateCost({
    required int durationDays,
    required int numberOfPeople,
    required String nationality,
    required bool includeGuide,
    required bool includePorter,
    required int numberOfPorters,
  }) async {
    if (selectedDestination == null) return;
    if (selectedDestination!.isRestrictedArea && selectedGuideId == null) {
      error = 'Guide selection is mandatory for restricted destinations.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    error = null;

    try {
      currentCostBreakdown = await _tripPlannerService.getCostBreakdown(
        destinationId: selectedDestination!.id,
        durationDays: durationDays,
        numberOfPeople: numberOfPeople,
        nationality: nationality,
        includeGuide: includeGuide,
        selectedGuideId: selectedGuideId,
        includePorter: includePorter,
        numberOfPorters: numberOfPorters,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> createItinerary({
    required int durationDays,
    required int numberOfPeople,
    required String nationality,
    required bool includeGuide,
    required bool includePorter,
    required int numberOfPorters,
  }) async {
    if (selectedDestination == null) return;
    if (selectedDestination!.isRestrictedArea && selectedGuideId == null) {
      error = 'Guide selection is mandatory for restricted destinations.';
      notifyListeners();
      return;
    }

    isCreating = true;
    error = null;
    notifyListeners();

    try {
      currentItinerary = await _tripPlannerService.createItinerary(
        destinationId: selectedDestination!.id,
        durationDays: durationDays,
        numberOfPeople: numberOfPeople,
        nationality: nationality,
        includeGuide: includeGuide,
        selectedGuideId: selectedGuideId,
        includePorter: includePorter,
        numberOfPorters: numberOfPorters,
        selectedDetourIds: selectedDetourIds.toList(),
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  Future<void> optimizeWithKnapsack({
    required double maxBudgetUsd,
    required int maxDays,
    required int numberOfPeople,
    required String nationality,
    required bool includeGuide,
    required bool includePorter,
  }) async {
    if (selectedDestination == null) return;

    isCreating = true;
    error = null;
    notifyListeners();

    try {
      currentItinerary = await _tripPlannerService.optimizeTrip(
        destinationId: selectedDestination!.id,
        maxBudgetUsd: maxBudgetUsd,
        maxDays: maxDays,
        numberOfPeople: numberOfPeople,
        nationality: nationality,
        includeGuide: includeGuide,
        includePorter: includePorter,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  Future<void> runDevModeAlgorithms() async {
    if (!devMode || selectedDestination == null) return;

    final items = destinations
        .map(
          (d) => {
            'id': d.id,
            'name': d.name,
            'price': d.price,
            'duration_days': d.durationDays,
            'rating': d.averageRating ?? 4.0,
          },
        )
        .toList();

    if (items.isEmpty) {
      return;
    }

    try {
      final binary = await _tripPlannerService.getAlgorithmSteps(
        algorithm: 'binary_search',
        items: items,
        searchQuery: (selectedDestination!.price).toStringAsFixed(0),
      );
      binarySearchSteps =
          List<String>.from(binary['execution_steps'] as List? ?? []);

      final quickSort = await _tripPlannerService.getAlgorithmSteps(
        algorithm: 'quicksort',
        items: items,
        sortKey: 'price',
      );
      quickSortSteps =
          List<String>.from(quickSort['execution_steps'] as List? ?? []);
    } catch (e) {
      error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> setDevMode(bool enabled) async {
    devMode = enabled;
    if (devMode) {
      await runDevModeAlgorithms();
    } else {
      binarySearchSteps = [];
      quickSortSteps = [];
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
