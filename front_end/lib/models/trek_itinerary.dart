class Detour {
  final int id;
  final String name;
  final String description;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final double distanceKm;
  final double extraCostUsd;
  final int extraDays;
  final double qualityRating;
  final String difficulty;
  final bool isOptional;

  Detour({
    required this.id,
    required this.name,
    required this.description,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.distanceKm,
    required this.extraCostUsd,
    required this.extraDays,
    required this.qualityRating,
    required this.difficulty,
    required this.isOptional,
  });

  factory Detour.fromJson(Map<String, dynamic> json) {
    return Detour(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      startLatitude: double.tryParse((json['start_latitude'] ?? 0).toString()) ?? 0,
      startLongitude: double.tryParse((json['start_longitude'] ?? 0).toString()) ?? 0,
      endLatitude: double.tryParse((json['end_latitude'] ?? 0).toString()) ?? 0,
      endLongitude: double.tryParse((json['end_longitude'] ?? 0).toString()) ?? 0,
      distanceKm: double.tryParse((json['distance_km'] ?? 0).toString()) ?? 0,
      extraCostUsd: double.parse(json['extra_cost_usd'].toString()),
      extraDays: (json['extra_days'] as num?)?.toInt() ?? 0,
      qualityRating: double.parse(json['quality_rating'].toString()),
      difficulty: json['difficulty']?.toString() ?? 'MODERATE',
      isOptional: json['is_optional'] ?? true,
    );
  }
}

class TrekActivity {
  final int id;
  final int dayNumber;
  final String name;
  final String description;
  final String activityType;
  final String difficulty;
  final double estimatedTimeHours;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final int? altitudeM;

  TrekActivity({
    required this.id,
    required this.dayNumber,
    required this.name,
    required this.description,
    required this.activityType,
    required this.difficulty,
    required this.estimatedTimeHours,
    this.locationName,
    this.latitude,
    this.longitude,
    this.altitudeM,
  });

  factory TrekActivity.fromJson(Map<String, dynamic> json) {
    final estimatedHoursRaw = json['estimated_hours'] ?? json['estimated_time_hours'] ?? 8.0;
    final altitudeRaw = json['altitude'] ?? json['altitude_m'];

    return TrekActivity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      dayNumber: (json['day_number'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      activityType: json['activity_type']?.toString() ?? 'TREK',
      difficulty: json['difficulty']?.toString() ?? 'MODERATE',
      estimatedTimeHours: double.tryParse(estimatedHoursRaw.toString()) ?? 8.0,
      locationName: json['location_name']?.toString() ?? json['name']?.toString(),
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      altitudeM: (altitudeRaw as num?)?.toInt(),
    );
  }
}

class GuideProfile {
  final int id;
  final String name;
  final String licenseNumber;
  final int experienceYears;
  final String specialization;
  final double dailyRate;

  GuideProfile({
    required this.id,
    required this.name,
    required this.licenseNumber,
    required this.experienceYears,
    required this.specialization,
    required this.dailyRate,
  });

  factory GuideProfile.fromJson(Map<String, dynamic> json) {
    return GuideProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      licenseNumber: json['license_number']?.toString() ?? '',
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      specialization: json['specialization']?.toString() ?? '',
      dailyRate: double.tryParse((json['daily_rate'] ?? 0).toString()) ?? 0,
    );
  }
}

class TrekItinerary {
  final int id;
  final int destinationId;
  final String destinationName;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCost;
  final int totalDistanceKm;
  final int totalElevationGainM;
  final List<TrekActivity> activities;
  final List<Detour> selectedDetours;
  final Map<String, dynamic> costBreakdown;
  final String status;
  final List<String> executionSteps;
  final bool isSafeAcclimatization;
  final bool isSafe;
  final List<String> safetyWarnings;
  final double suggestedCashNpr;
  final double cashRecommendationNpr;
  final GuideProfile? selectedGuide;

  TrekItinerary({
    required this.id,
    required this.destinationId,
    required this.destinationName,
    required this.startDate,
    required this.endDate,
    required this.totalCost,
    required this.totalDistanceKm,
    required this.totalElevationGainM,
    required this.activities,
    required this.selectedDetours,
    required this.costBreakdown,
    required this.status,
    required this.executionSteps,
    required this.isSafeAcclimatization,
    required this.isSafe,
    required this.safetyWarnings,
    required this.suggestedCashNpr,
    required this.cashRecommendationNpr,
    this.selectedGuide,
  });

  factory TrekItinerary.fromJson(Map<String, dynamic> json) {
    final destinationRaw = json['destination_id'] ?? json['destination'];
    final selectedDetoursRaw = json['selected_detours_data'] ?? json['selected_detours'] ?? [];
    final costBreakdown = <String, dynamic>{
      'base': double.tryParse((json['base_cost'] ?? 0).toString()) ?? 0,
      'permit': double.tryParse((json['permit_cost'] ?? 0).toString()) ?? 0,
      'guide': double.tryParse((json['guide_cost'] ?? 0).toString()) ?? 0,
      'porter': double.tryParse((json['porter_cost'] ?? 0).toString()) ?? 0,
      'detour': double.tryParse((json['detour_cost'] ?? 0).toString()) ?? 0,
    };

    return TrekItinerary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      destinationId: (destinationRaw as num?)?.toInt() ?? 0,
      destinationName: json['destination_name']?.toString() ?? '',
      startDate: DateTime.parse(json['start_date'].toString()),
      endDate: DateTime.parse(json['end_date'].toString()),
      totalCost: double.parse(json['total_cost'].toString()),
      totalDistanceKm: (json['total_distance_km'] as num?)?.toInt() ?? 0,
      totalElevationGainM: (json['total_elevation_gain_m'] as num?)?.toInt() ?? 0,
      activities: (json['activities'] as List? ?? [])
          .map((a) => TrekActivity.fromJson(a as Map<String, dynamic>))
          .toList(),
      selectedDetours: (selectedDetoursRaw as List)
          .map((d) => Detour.fromJson(d as Map<String, dynamic>))
          .toList(),
      costBreakdown: json['cost_breakdown'] ?? costBreakdown,
      status: json['status']?.toString() ?? 'DRAFT',
      executionSteps: List<String>.from(json['execution_steps'] as List? ?? []),
      isSafeAcclimatization: json['is_safe_acclimatization'] as bool? ?? true,
      isSafe: json['is_safe'] as bool? ?? (json['is_safe_acclimatization'] as bool? ?? true),
      safetyWarnings: List<String>.from(json['safety_warnings'] as List? ?? []),
      suggestedCashNpr: double.tryParse((json['suggested_cash_npr'] ?? 0).toString()) ?? 0,
      cashRecommendationNpr: double.tryParse((json['cash_recommendation_npr'] ?? json['suggested_cash_npr'] ?? 0).toString()) ?? 0,
      selectedGuide: json['selected_guide_data'] != null
          ? GuideProfile.fromJson(json['selected_guide_data'] as Map<String, dynamic>)
          : null,
    );
  }

  int get durationDays {
    return endDate.difference(startDate).inDays + 1;
  }
}
