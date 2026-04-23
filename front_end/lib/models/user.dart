class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String fullNameValue;
  final String address;
  final String contactNumber;
  final String gender;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.fullNameValue = '',
    this.address = '',
    this.contactNumber = '',
    this.gender = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullNameValue: json['full_name'] ?? '',
      address: json['address'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      gender: json['gender'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullNameValue,
      'address': address,
      'contact_number': contactNumber,
      'gender': gender,
    };
  }

  String get fullName {
    if (fullNameValue.trim().isNotEmpty) return fullNameValue.trim();
    if (firstName.isEmpty && lastName.isEmpty) return username;
    return '$firstName $lastName'.trim();
  }
}
