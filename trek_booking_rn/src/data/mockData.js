// Mock data for trips with comprehensive information
export const mockTrips = [
  {
    id: '1',
    title: 'Everest Base Camp Trek',
    region: 'Everest',
    duration: 14,
    difficulty: 'Moderate',
    price: 1299,
    rating: 4.9,
    reviews: 342,
    image: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
    shortDescription: 'Journey to the base of the world\'s highest peak',
    maxAltitude: 5364,
    season: ['Spring', 'Autumn'],
    groupSize: 12,
    inclusions: ['Accommodation', 'Meals', 'Guide', 'Permits'],
    exclusions: ['International flights', 'Travel insurance', 'Personal expenses'],
    itinerary: [
      { day: 1, title: 'Arrival in Kathmandu', description: 'Transfer to hotel, trek briefing' },
      { day: 2, title: 'Fly to Lukla, trek to Phakding', description: 'Scenic mountain flight, easy trek along Dudh Koshi river' },
      { day: 3, title: 'Trek to Namche Bazaar', description: 'Cross suspension bridges, climb to Sherpa capital' },
      { day: 4, title: 'Acclimatization day', description: 'Rest day with optional hike to Everest View Hotel' },
      { day: 5, title: 'Trek to Tengboche', description: 'Visit famous monastery with Everest views' },
      { day: 14, title: 'Fly back to Kathmandu', description: 'Mountain flight, trip conclusion' }
    ],
    coordinates: [
      { lat: 27.7172, lng: 85.3240, name: 'Kathmandu' },
      { lat: 27.6870, lng: 86.7310, name: 'Lukla' },
      { lat: 27.8046, lng: 86.7134, name: 'Namche' },
      { lat: 27.9015, lng: 86.8288, name: 'EBC' }
    ],
    popularityScore: 95,
    category: 'Trekking'
  },
  {
    id: '2',
    title: 'Annapurna Circuit Trek',
    region: 'Annapurna',
    duration: 18,
    difficulty: 'Challenging',
    price: 1499,
    rating: 4.8,
    reviews: 287,
    image: 'https://images.unsplash.com/photo-1558368637-4e95e6e00c66?w=800',
    shortDescription: 'Classic circuit trek with diverse landscapes',
    maxAltitude: 5416,
    season: ['Spring', 'Autumn'],
    groupSize: 10,
    inclusions: ['Accommodation', 'Meals', 'Guide', 'Permits', 'Porter'],
    exclusions: ['International flights', 'Travel insurance', 'Tips'],
    itinerary: [
      { day: 1, title: 'Kathmandu to Besisahar', description: 'Drive to trek starting point' },
      { day: 10, title: 'Cross Thorong La Pass', description: 'Highest point of the trek at 5416m' },
      { day: 18, title: 'Return to Kathmandu', description: 'Trip ends' }
    ],
    coordinates: [
      { lat: 28.1475, lng: 84.4342, name: 'Besisahar' },
      { lat: 28.7965, lng: 83.9318, name: 'Manang' },
      { lat: 28.6644, lng: 83.7284, name: 'Muktinath' }
    ],
    popularityScore: 88,
    category: 'Trekking'
  },
  {
    id: '3',
    title: 'Langtang Valley Trek',
    region: 'Langtang',
    duration: 10,
    difficulty: 'Easy',
    price: 799,
    rating: 4.7,
    reviews: 156,
    image: 'https://images.unsplash.com/photo-1519904981063-b0cf448d479e?w=800',
    shortDescription: 'Beautiful valley trek close to Kathmandu',
    maxAltitude: 4984,
    season: ['Spring', 'Autumn', 'Winter'],
    groupSize: 15,
    inclusions: ['Accommodation', 'Meals', 'Guide', 'Permits'],
    exclusions: ['International flights', 'Travel insurance'],
    itinerary: [
      { day: 1, title: 'Drive to Syabrubesi', description: 'Scenic drive from Kathmandu' },
      { day: 5, title: 'Reach Kyanjin Gompa', description: 'Explore monastery and cheese factory' },
      { day: 10, title: 'Return to Kathmandu', description: 'End of trek' }
    ],
    coordinates: [
      { lat: 28.1628, lng: 85.2870, name: 'Syabrubesi' },
      { lat: 28.2043, lng: 85.5674, name: 'Kyanjin Gompa' }
    ],
    popularityScore: 72,
    category: 'Trekking'
  },
  {
    id: '4',
    title: 'Manaslu Circuit Trek',
    region: 'Manaslu',
    duration: 16,
    difficulty: 'Challenging',
    price: 1399,
    rating: 4.9,
    reviews: 98,
    image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    shortDescription: 'Off-the-beaten-path circuit around 8th highest peak',
    maxAltitude: 5160,
    season: ['Spring', 'Autumn'],
    groupSize: 8,
    inclusions: ['Accommodation', 'Meals', 'Guide', 'Permits', 'Porter', 'Restricted area permit'],
    exclusions: ['International flights', 'Travel insurance', 'Tips'],
    itinerary: [
      { day: 1, title: 'Drive to Soti Khola', description: 'Start of trek' },
      { day: 9, title: 'Cross Larkya La Pass', description: 'Highest point at 5160m' },
      { day: 16, title: 'Return to Kathmandu', description: 'Trek conclusion' }
    ],
    coordinates: [
      { lat: 28.2930, lng: 84.7104, name: 'Soti Khola' },
      { lat: 28.6416, lng: 84.5636, name: 'Larkya La' }
    ],
    popularityScore: 65,
    category: 'Trekking'
  },
  {
    id: '5',
    title: 'Upper Mustang Trek',
    region: 'Mustang',
    duration: 12,
    difficulty: 'Moderate',
    price: 1599,
    rating: 4.8,
    reviews: 124,
    image: 'https://images.unsplash.com/photo-1585409677983-0f6c41ca9c3b?w=800',
    shortDescription: 'Explore the hidden kingdom of Lo',
    maxAltitude: 3840,
    season: ['Spring', 'Autumn', 'Summer'],
    groupSize: 10,
    inclusions: ['Accommodation', 'Meals', 'Guide', 'Permits', 'Restricted area permit'],
    exclusions: ['International flights', 'Travel insurance'],
    itinerary: [
      { day: 1, title: 'Fly to Jomsom', description: 'Mountain flight' },
      { day: 6, title: 'Explore Lo Manthang', description: 'Ancient walled city' },
      { day: 12, title: 'Return to Kathmandu', description: 'End of trek' }
    ],
    coordinates: [
      { lat: 28.7806, lng: 83.7229, name: 'Jomsom' },
      { lat: 29.1803, lng: 83.9837, name: 'Lo Manthang' }
    ],
    popularityScore: 58,
    category: 'Cultural'
  },
  {
    id: '6',
    title: 'Gokyo Lakes Trek',
    region: 'Everest',
    duration: 12,
    difficulty: 'Moderate',
    price: 1199,
    rating: 4.9,
    reviews: 203,
    image: 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=800',
    shortDescription: 'Stunning turquoise lakes with Everest views',
    maxAltitude: 5357,
    season: ['Spring', 'Autumn'],
    groupSize: 12,
    inclusions: ['Accommodation', 'Meals', 'Guide', 'Permits'],
    exclusions: ['International flights', 'Travel insurance'],
    itinerary: [
      { day: 1, title: 'Fly to Lukla', description: 'Start trek' },
      { day: 7, title: 'Reach Gokyo Lakes', description: 'Explore pristine lakes' },
      { day: 12, title: 'Return to Kathmandu', description: 'Trek ends' }
    ],
    coordinates: [
      { lat: 27.6870, lng: 86.7310, name: 'Lukla' },
      { lat: 27.9611, lng: 86.6880, name: 'Gokyo' }
    ],
    popularityScore: 82,
    category: 'Trekking'
  },
  {
    id: '7',
    title: 'Island Peak Climbing',
    region: 'Everest',
    duration: 16,
    difficulty: 'Advanced',
    price: 2299,
    rating: 4.7,
    reviews: 76,
    image: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
    shortDescription: 'Summit a Himalayan peak at 6189m',
    maxAltitude: 6189,
    season: ['Spring', 'Autumn'],
    groupSize: 6,
    inclusions: ['Accommodation', 'Meals', 'Guide', 'Climbing guide', 'Permits', 'Gear'],
    exclusions: ['International flights', 'Travel insurance', 'Personal climbing gear'],
    itinerary: [
      { day: 1, title: 'Fly to Lukla', description: 'Trek begins' },
      { day: 12, title: 'Summit Island Peak', description: 'Summit day' },
      { day: 16, title: 'Return to Kathmandu', description: 'End expedition' }
    ],
    coordinates: [
      { lat: 27.6870, lng: 86.7310, name: 'Lukla' },
      { lat: 27.9372, lng: 86.9319, name: 'Island Peak Base Camp' }
    ],
    popularityScore: 48,
    category: 'Peak Climbing'
  },
  {
    id: '8',
    title: 'Kathmandu Cultural Tour',
    region: 'Kathmandu Valley',
    duration: 3,
    difficulty: 'Easy',
    price: 299,
    rating: 4.6,
    reviews: 412,
    image: 'https://images.unsplash.com/photo-1558008258-3256797b43f3?w=800',
    shortDescription: 'Explore UNESCO World Heritage sites',
    maxAltitude: 1400,
    season: ['All year'],
    groupSize: 20,
    inclusions: ['Accommodation', 'Meals', 'Guide', 'Entry fees', 'Transportation'],
    exclusions: ['International flights', 'Travel insurance'],
    itinerary: [
      { day: 1, title: 'Swayambhunath and Kathmandu Durbar Square', description: 'Explore ancient temples' },
      { day: 2, title: 'Pashupatinath and Boudhanath', description: 'Visit sacred sites' },
      { day: 3, title: 'Bhaktapur and Patan', description: 'Discover medieval cities' }
    ],
    coordinates: [
      { lat: 27.7172, lng: 85.3240, name: 'Kathmandu' }
    ],
    popularityScore: 90,
    category: 'Cultural'
  }
];

// Mock user data
export const mockUser = {
  id: 'user123',
  name: 'Rajesh Kumar',
  email: 'rajesh@example.com',
  phone: '+977-9841234567',
  savedTrips: ['1', '2', '6'],
  bookings: [
    {
      id: 'b1',
      tripId: '3',
      status: 'confirmed',
      date: '2026-04-15',
      travelers: 2,
      totalPrice: 1598
    }
  ],
  reviews: [
    {
      tripId: '3',
      rating: 5,
      comment: 'Amazing experience! The guide was very knowledgeable.',
      date: '2025-11-20'
    }
  ]
};

// Mock categories
export const categories = [
  { id: 'trekking', name: 'Trekking', icon: 'terrain' },
  { id: 'cultural', name: 'Cultural Tours', icon: 'account-balance' },
  { id: 'peak-climbing', name: 'Peak Climbing', icon: 'landscape' },
  { id: 'adventure', name: 'Adventure', icon: 'explore' }
];

// FAQ data
export const faqData = [
  {
    question: 'What is the best season for trekking in Nepal?',
    answer: 'Spring (March-May) and Autumn (September-November) are the best seasons for trekking in Nepal, offering clear skies and moderate temperatures.'
  },
  {
    question: 'Do I need travel insurance?',
    answer: 'Yes, comprehensive travel insurance covering helicopter evacuation is mandatory for all treks above 3000m.'
  },
  {
    question: 'What fitness level is required?',
    answer: 'It depends on the trek. Easy treks require basic fitness, while challenging treks need good cardiovascular fitness and acclimatization.'
  },
  {
    question: 'Can I trek solo?',
    answer: 'While possible, we recommend joining a group or hiring a guide for safety, navigation, and cultural insights.'
  },
  {
    question: 'What about altitude sickness?',
    answer: 'Proper acclimatization, staying hydrated, and ascending gradually are key. Our itineraries include acclimatization days for high-altitude treks.'
  }
];
