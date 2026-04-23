class MockDestination {
  final int id;
  final String name;
  final String description;
  final double difficulty;
  final double altitude;
  final int duration;
  final double rating;
  final String region;

  MockDestination({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.altitude,
    required this.duration,
    required this.rating,
    required this.region,
  });
}

final List<MockDestination> mockDestinations = [
  MockDestination(
    id: 1,
    name: 'Mount Everest',
    description: 'The highest mountain in the world',
    difficulty: 5.0,
    altitude: 8848,
    duration: 60,
    rating: 4.8,
    region: 'Nepal',
  ),
  MockDestination(
    id: 2,
    name: 'Kilimanjaro',
    description: 'Highest peak in Africa',
    difficulty: 3.5,
    altitude: 5895,
    duration: 7,
    rating: 4.6,
    region: 'Tanzania',
  ),
  MockDestination(
    id: 3,
    name: 'Mont Blanc',
    description: 'Highest peak in the Alps',
    difficulty: 2.5,
    altitude: 4808,
    duration: 2,
    rating: 4.5,
    region: 'France',
  ),
  MockDestination(
    id: 4,
    name: 'K2',
    description: 'Second highest mountain in the world',
    difficulty: 5.0,
    altitude: 8611,
    duration: 80,
    rating: 4.9,
    region: 'Pakistan',
  ),
];
