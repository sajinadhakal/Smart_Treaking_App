import '../models/user.dart';

class MockUsers {
  static final User testUser = User(
    id: 1,
    username: 'demo',
    email: 'demo@test.com',
    firstName: 'Demo',
    lastName: 'User',
    fullNameValue: 'Demo User',
    address: '123 Demo Street',
    contactNumber: '1234567890',
    gender: 'OTHER',
  );

  static final User testUser2 = User(
    id: 2,
    username: 'sajina',
    email: 'sajina@test.com',
    firstName: 'Sajina',
    lastName: 'Test',
    fullNameValue: 'Sajina Test',
    address: '456 Test Avenue',
    contactNumber: '0987654321',
    gender: 'FEMALE',
  );
}
