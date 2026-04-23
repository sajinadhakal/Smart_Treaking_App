class TrekRoute {
  final int id;
  final int sequenceOrder;
  final double latitude;
  final double longitude;
  final int altitude;
  final String locationName;
  final String description;

  TrekRoute({
    required this.id,
    required this.sequenceOrder,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.locationName,
    required this.description,
  });

  factory TrekRoute.fromJson(Map<String, dynamic> json) {
    return TrekRoute(
      id: json['id'],
      sequenceOrder: json['sequence_order'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      altitude: json['altitude'],
      locationName: json['location_name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
