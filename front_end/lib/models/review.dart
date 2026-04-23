class Review {
  final int id;
  final int userId;
  final int destination;
  final String destinationName;
  final String userName;
  final int rating;
  final String comment;
  final String? image;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.destination,
    required this.destinationName,
    required this.userName,
    required this.rating,
    required this.comment,
    this.image,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final created = json['created_at']?.toString();
    if (created != null && created.isNotEmpty) {
      parsedDate = DateTime.tryParse(created);
    }

    return Review(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user']?['id'] as num?)?.toInt() ?? 0,
      destination: (json['destination'] as num?)?.toInt() ?? 0,
      destinationName: json['destination_name']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      image: json['image']?.toString(),
      createdAt: parsedDate,
    );
  }
}
