class WeatherRiskFactor {
  final String name;
  final double score;
  final String severity;

  WeatherRiskFactor({
    required this.name,
    required this.score,
    required this.severity,
  });

  factory WeatherRiskFactor.fromJson(Map<String, dynamic> json) {
    final parsedScore = double.tryParse((json['score'] ?? 0).toString()) ?? 0;
    return WeatherRiskFactor(
      name: json['name']?.toString() ?? '',
      score: parsedScore,
      severity: json['severity']?.toString() ?? 'LOW',
    );
  }
}

class WeatherRisk {
  final String riskLevel;
  final int totalScore;
  final List<WeatherRiskFactor> factors;
  final List<String> recommendations;
  final Map<String, dynamic>? weatherData;
  final List<String> executionSteps;

  WeatherRisk({
    required this.riskLevel,
    required this.totalScore,
    required this.factors,
    required this.recommendations,
    this.weatherData,
    required this.executionSteps,
  });

  static List<WeatherRiskFactor> _parseFactors(dynamic rawFactors) {
    if (rawFactors is List) {
      return rawFactors
          .whereType<Map>()
          .map((f) => WeatherRiskFactor.fromJson(Map<String, dynamic>.from(f)))
          .toList();
    }

    if (rawFactors is Map<String, dynamic>) {
      final dynamic riskScores = rawFactors['risk_scores'];
      if (riskScores is Map<String, dynamic>) {
        return riskScores.entries
            .map(
              (entry) => WeatherRiskFactor(
                name: entry.key,
                score: double.tryParse(entry.value.toString()) ?? 0,
                severity: _severityFromScore(double.tryParse(entry.value.toString()) ?? 0),
              ),
            )
            .toList();
      }

      // Fallback: convert flat factor map into factor list.
      return rawFactors.entries
          .where((entry) => entry.value is num)
          .map(
            (entry) => WeatherRiskFactor(
              name: entry.key,
              score: (entry.value as num).toDouble(),
              severity: _severityFromScore((entry.value as num).toDouble()),
            ),
          )
          .toList();
    }

    return [];
  }

  static String _severityFromScore(double score) {
    if (score >= 8) return 'HIGH';
    if (score >= 4) return 'MEDIUM';
    return 'LOW';
  }

  static List<String> _parseRecommendations(dynamic rawRecommendations) {
    if (rawRecommendations is List) {
      return rawRecommendations.map((item) => item.toString()).toList();
    }
    if (rawRecommendations is String) {
      return [rawRecommendations];
    }
    if (rawRecommendations is Map<String, dynamic>) {
      return rawRecommendations.values.map((item) => item.toString()).toList();
    }
    return [];
  }

  static List<String> _parseExecutionSteps(dynamic rawExecutionSteps) {
    if (rawExecutionSteps is List) {
      return rawExecutionSteps.map((item) => item.toString()).toList();
    }
    return [];
  }

  factory WeatherRisk.fromJson(Map<String, dynamic> json) {
    return WeatherRisk(
      riskLevel: json['risk_level']?.toString() ?? 'MEDIUM',
      totalScore: (json['total_score'] as num?)?.toInt() ?? 0,
      factors: _parseFactors(json['factors']),
      recommendations: _parseRecommendations(json['recommendations']),
      weatherData: json['weather_data'] as Map<String, dynamic>?,
      executionSteps: _parseExecutionSteps(json['execution_steps']),
    );
  }

  // Return color based on risk level
  int getRiskColor() {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        return 0xFF4CAF50; // Green
      case 'MEDIUM':
        return 0xFFFFA726; // Orange
      case 'HIGH':
        return 0xFFEF5350; // Red
      default:
        return 0xFF9E9E9E; // Gray
    }
  }
}
