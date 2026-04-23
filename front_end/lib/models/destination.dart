class Destination {
  final int id;
  final String name;
  final String description;
  final String location;
  final int altitude;
  final int maxAltitude;
  final int durationDays;
  final String difficulty;
  final String difficultyLevel;
  final double price;
  final double basePriceNpr;
  final bool isRestrictedArea;
  final String? image;
  final bool featured;
  final String? bestSeason;
  final int groupSizeMax;
  final double latitude;
  final double longitude;
  final double? averageRating;
  final int? totalReviews;
  final DateTime? createdAt;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.altitude,
    required this.maxAltitude,
    required this.durationDays,
    required this.difficulty,
    required this.difficultyLevel,
    required this.price,
    required this.basePriceNpr,
    required this.isRestrictedArea,
    this.image,
    this.featured = false,
    this.bestSeason,
    this.groupSizeMax = 15,
    required this.latitude,
    required this.longitude,
    this.averageRating,
    this.totalReviews,
    this.createdAt,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    final parsedPrice = double.tryParse((json['price'] ?? 0).toString()) ?? 0;
    final parsedLatitude = double.tryParse((json['latitude'] ?? 0).toString()) ?? 0;
    final parsedLongitude = double.tryParse((json['longitude'] ?? 0).toString()) ?? 0;
    final createdRaw = json['created_at']?.toString();

    return Destination(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      altitude: (json['altitude'] as num?)?.toInt() ?? 0,
      maxAltitude: (json['max_altitude'] as num?)?.toInt() ?? (json['altitude'] as num?)?.toInt() ?? 0,
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty']?.toString() ?? 'MODERATE',
      difficultyLevel: json['difficulty_level']?.toString() ?? json['difficulty']?.toString() ?? 'MODERATE',
      price: parsedPrice,
      basePriceNpr: double.tryParse((json['base_price_npr'] ?? 0).toString()) ?? 0,
      isRestrictedArea: json['is_restricted_area'] == true,
      image: json['image']?.toString(),
      featured: json['featured'] ?? false,
      bestSeason: json['best_season']?.toString(),
      groupSizeMax: (json['group_size_max'] as num?)?.toInt() ?? 15,
      latitude: parsedLatitude,
      longitude: parsedLongitude,
      averageRating: json['average_rating'] != null 
          ? double.parse(json['average_rating'].toString()) 
          : null,
      totalReviews: (json['total_reviews'] as num?)?.toInt(),
      createdAt: (createdRaw != null && createdRaw.isNotEmpty) ? DateTime.tryParse(createdRaw) : null,
    );
  }
}
