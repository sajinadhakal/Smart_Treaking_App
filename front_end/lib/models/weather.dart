class Weather {
  final int id;
  final double temperature;
  final String weatherCondition;
  final String description;
  final int humidity;
  final double windSpeed;
  final bool hasRainWarning;
  final bool hasSnowWarning;
  final bool hasAltitudeWarning;
  final String riskLevel;
  final DateTime cachedAt;

  Weather({
    required this.id,
    required this.temperature,
    required this.weatherCondition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.hasRainWarning,
    required this.hasSnowWarning,
    required this.hasAltitudeWarning,
    required this.riskLevel,
    required this.cachedAt,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id'],
      temperature: double.parse(json['temperature'].toString()),
      weatherCondition: json['weather_condition'],
      description: json['description'],
      humidity: json['humidity'],
      windSpeed: double.parse(json['wind_speed'].toString()),
      hasRainWarning: json['has_rain_warning'] ?? false,
      hasSnowWarning: json['has_snow_warning'] ?? false,
      hasAltitudeWarning: json['has_altitude_warning'] ?? false,
      riskLevel: json['risk_level'],
      cachedAt: DateTime.parse(json['cached_at']),
    );
  }

  String get warningMessage {
    List<String> warnings = [];
    if (hasRainWarning) warnings.add('Heavy rain expected');
    if (hasSnowWarning) warnings.add('Snowfall warning');
    if (hasAltitudeWarning) warnings.add('High altitude - risk of AMS');
    
    return warnings.isEmpty ? 'No warnings' : warnings.join(', ');
  }
}
