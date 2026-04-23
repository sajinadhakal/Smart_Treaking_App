class CostBreakdown {
  final double basePrice;
  final double permitCost;
  final double guideCost;
  final double porterCost;
  final double detourCost;
  final double totalCost;
  final Map<String, dynamic> costBreakdown;
  final Map<String, dynamic> detailedExpenses; // New: lodging, meals, transport, etc.
  final Map<String, dynamic> perPersonExpenses; // New: per-person breakdown
  final int numberOfPeople;
  final int durationDays;
  final String nationality;
  final List<String> executionSteps;
  final double suggestedCashNpr;

  CostBreakdown({
    required this.basePrice,
    required this.permitCost,
    required this.guideCost,
    required this.porterCost,
    required this.detourCost,
    required this.totalCost,
    required this.costBreakdown,
    required this.detailedExpenses,
    required this.perPersonExpenses,
    required this.numberOfPeople,
    required this.durationDays,
    required this.nationality,
    required this.executionSteps,
    required this.suggestedCashNpr,
  });

  factory CostBreakdown.fromJson(Map<String, dynamic> json) {
    final breakdown = json['cost_breakdown'] as Map<String, dynamic>? ?? {};
    final detailed = json['detailed_expenses'] as Map<String, dynamic>? ?? {};
    final perPerson = json['per_person_expenses'] as Map<String, dynamic>? ?? {};
    final inferredPeople = (json['number_of_people'] as num?)?.toInt() ?? 1;
    final inferredDays = (json['duration_days'] as num?)?.toInt() ?? 1;

    return CostBreakdown(
      basePrice: double.parse(json['base_cost'].toString()),
      permitCost: double.parse(json['permit_cost'].toString()),
      guideCost: double.parse(json['guide_cost'].toString()),
      porterCost: double.parse(json['porter_cost'].toString()),
      detourCost: double.parse(json['detour_cost'].toString()),
      totalCost: double.parse(json['total_cost'].toString()),
      costBreakdown: breakdown,
      detailedExpenses: detailed,
      perPersonExpenses: perPerson,
      numberOfPeople: inferredPeople,
      durationDays: inferredDays,
      nationality: json['nationality']?.toString() ?? 'INTERNATIONAL',
      executionSteps: List<String>.from(json['execution_steps'] as List? ?? []),
      suggestedCashNpr: double.tryParse((json['suggested_cash_npr'] ?? 0).toString()) ?? 0,
    );
  }

  static const double usdToNpr = 133.0;

  double get suggestedCashUsd {
    if (suggestedCashNpr <= 0) return 0;
    return suggestedCashNpr / usdToNpr;
  }

  // Calculate percentage for pie chart
  Map<String, double> getBreakdownPercentages() {
    if (totalCost == 0) return {};
    return {
      'Base': (basePrice / totalCost) * 100,
      'Permit': (permitCost / totalCost) * 100,
      'Guide': (guideCost / totalCost) * 100,
      'Porter': (porterCost / totalCost) * 100,
      'Detour': (detourCost / totalCost) * 100,
    };
  }
}
