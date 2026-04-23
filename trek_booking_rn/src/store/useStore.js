import { create } from 'zustand';

const useStore = create((set, get) => ({
  // User state
  user: null,
  isAuthenticated: false,
  
  setUser: (user) => set({ user, isAuthenticated: !!user }),
  logout: () => set({ user: null, isAuthenticated: false }),

  // Trips state
  trips: [],
  filteredTrips: [],
  selectedTrip: null,
  
  setTrips: (trips) => set({ trips, filteredTrips: trips }),
  setSelectedTrip: (trip) => set({ selectedTrip: trip }),
  
  // Filters
  filters: {
    searchQuery: '',
    difficulty: 'All',
    region: 'All',
    minPrice: 0,
    maxPrice: 5000,
    minDuration: 0,
    maxDuration: 30,
    category: 'All',
    season: 'All'
  },

  setFilter: (key, value) => set((state) => ({
    filters: { ...state.filters, [key]: value }
  })),

  resetFilters: () => set({
    filters: {
      searchQuery: '',
      difficulty: 'All',
      region: 'All',
      minPrice: 0,
      maxPrice: 5000,
      minDuration: 0,
      maxDuration: 30,
      category: 'All',
      season: 'All'
    }
  }),

  applyFilters: () => {
    const { trips, filters } = get();
    
    let filtered = trips.filter(trip => {
      // Search query
      if (filters.searchQuery) {
        const query = filters.searchQuery.toLowerCase();
        const matchesSearch = 
          trip.title.toLowerCase().includes(query) ||
          trip.region.toLowerCase().includes(query) ||
          trip.shortDescription.toLowerCase().includes(query);
        if (!matchesSearch) return false;
      }

      // Difficulty
      if (filters.difficulty !== 'All' && trip.difficulty !== filters.difficulty) {
        return false;
      }

      // Region
      if (filters.region !== 'All' && trip.region !== filters.region) {
        return false;
      }

      // Price range
      if (trip.price < filters.minPrice || trip.price > filters.maxPrice) {
        return false;
      }

      // Duration range
      if (trip.duration < filters.minDuration || trip.duration > filters.maxDuration) {
        return false;
      }

      // Category
      if (filters.category !== 'All' && trip.category !== filters.category) {
        return false;
      }

      // Season
      if (filters.season !== 'All' && !trip.season.includes(filters.season)) {
        return false;
      }

      return true;
    });

    set({ filteredTrips: filtered });
  },

  // Sorting
  sortBy: 'popularity',
  setSortBy: (sortBy) => {
    set({ sortBy });
    const { filteredTrips } = get();
    
    const sorted = [...filteredTrips].sort((a, b) => {
      switch (sortBy) {
        case 'price-low':
          return a.price - b.price;
        case 'price-high':
          return b.price - a.price;
        case 'duration-short':
          return a.duration - b.duration;
        case 'duration-long':
          return b.duration - a.duration;
        case 'rating':
          return b.rating - a.rating;
        case 'popularity':
          return b.popularityScore - a.popularityScore;
        default:
          return 0;
      }
    });

    set({ filteredTrips: sorted });
  },

  // Saved trips
  savedTrips: [],
  toggleSavedTrip: (tripId) => set((state) => {
    const isSaved = state.savedTrips.includes(tripId);
    return {
      savedTrips: isSaved
        ? state.savedTrips.filter(id => id !== tripId)
        : [...state.savedTrips, tripId]
    };
  }),

  // Bookings
  bookings: [],
  addBooking: (booking) => set((state) => ({
    bookings: [...state.bookings, { ...booking, id: Date.now().toString() }]
  })),

  // Algorithm visualization
  algorithmResult: null,
  setAlgorithmResult: (result) => set({ algorithmResult: result }),
  clearAlgorithmResult: () => set({ algorithmResult: null }),

  // Educational mode
  educationalMode: false,
  toggleEducationalMode: () => set((state) => ({
    educationalMode: !state.educationalMode
  })),

  // Loading states
  isLoading: false,
  setLoading: (isLoading) => set({ isLoading }),
}));

export default useStore;
