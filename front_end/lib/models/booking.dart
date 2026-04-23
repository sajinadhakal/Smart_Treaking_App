class Booking {
  final int? id;
  final int destination;
  final String? destinationName;
  final DateTime startDate;
  final int numberOfPeople;
  final String status;
  final String specialRequirements;
  final String contactPhone;
  final DateTime? createdAt;

  Booking({
    this.id,
    required this.destination,
    this.destinationName,
    required this.startDate,
    required this.numberOfPeople,
    this.status = 'PENDING',
    this.specialRequirements = '',
    required this.contactPhone,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      destination: json['destination'],
      destinationName: json['destination_name'],
      startDate: DateTime.parse(json['start_date']),
      numberOfPeople: json['number_of_people'],
      status: json['status'],
      specialRequirements: json['special_requirements'] ?? '',
      contactPhone: json['contact_phone'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'start_date': startDate.toIso8601String().split('T')[0],
      'number_of_people': numberOfPeople,
      'special_requirements': specialRequirements,
      'contact_phone': contactPhone,
    };
  }
}
