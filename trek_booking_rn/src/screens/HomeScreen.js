import React, { useEffect } from 'react';
import { View, Text, ScrollView, StyleSheet, TouchableOpacity, Image } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import useStore from '../store/useStore';
import TripCard from '../components/TripCard';
import { mockTrips, categories } from '../data/mockData';

const HomeScreen = ({ navigation }) => {
  const { setTrips, filteredTrips, user, educationalMode } = useStore();

  useEffect(() => {
    // Load trips
    setTrips(mockTrips);
  }, []);

  const featuredTrips = mockTrips.filter(trip => trip.popularityScore >= 80);
  const trendingTrips = mockTrips.filter(trip => trip.rating >= 4.7);

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Hero Section */}
      <LinearGradient
        colors={['#1E3A2C', '#2E7D32', '#4CAF50']}
        style={styles.hero}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      >
        <View style={styles.heroContent}>
          <Text style={styles.greeting}>
            {user ? `Namaste, ${user.name.split(' ')[0]}!` : 'Welcome Explorer!'}
          </Text>
          <Text style={styles.heroTitle}>Discover Nepal's{'\n'}Hidden Gems</Text>
          <Text style={styles.heroSubtitle}>
            From the peaks of Everest to the valleys of Langtang
          </Text>
          
          <TouchableOpacity 
            style={styles.exploreButton}
            onPress={() => navigation.navigate('TripList')}
          >
            <Text style={styles.exploreButtonText}>Explore All Treks</Text>
            <MaterialIcons name="arrow-forward" size={20} color="#1E3A2C" />
          </TouchableOpacity>

          {educationalMode && (
            <View style={styles.eduBadge}>
              <MaterialIcons name="school" size={16} color="#FFD700" />
              <Text style={styles.eduBadgeText}>Educational Mode Active</Text>
            </View>
          )}
        </View>
        
        <Image 
          source={{ uri: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400' }}
          style={styles.heroImage}
        />
      </LinearGradient>

      {/* Categories */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Explore by Category</Text>
        <ScrollView 
          horizontal 
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.categoriesContainer}
        >
          {categories.map(category => (
            <TouchableOpacity
              key={category.id}
              style={styles.categoryCard}
              onPress={() => {
                navigation.navigate('TripList', { category: category.name });
              }}
            >
              <View style={styles.categoryIcon}>
                <MaterialIcons name={category.icon} size={32} color="#2E7D32" />
              </View>
              <Text style={styles.categoryName}>{category.name}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      {/* Featured Treks */}
      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Featured Treks</Text>
          <TouchableOpacity onPress={() => navigation.navigate('TripList')}>
            <Text style={styles.seeAll}>See All</Text>
          </TouchableOpacity>
        </View>
        
        <ScrollView 
          horizontal 
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.featuredContainer}
        >
          {featuredTrips.map(trip => (
            <TripCard
              key={trip.id}
              trip={trip}
              variant="featured"
              onPress={() => navigation.navigate('TripDetails', { trip })}
            />
          ))}
        </ScrollView>
      </View>

      {/* Quick Stats */}
      <View style={styles.statsContainer}>
        <View style={styles.statCard}>
          <MaterialIcons name="landscape" size={32} color="#2E7D32" />
          <Text style={styles.statNumber}>{mockTrips.length}+</Text>
          <Text style={styles.statLabel}>Destinations</Text>
        </View>
        <View style={styles.statCard}>
          <MaterialIcons name="star" size={32} color="#FFD700" />
          <Text style={styles.statNumber}>4.8</Text>
          <Text style={styles.statLabel}>Avg Rating</Text>
        </View>
        <View style={styles.statCard}>
          <MaterialIcons name="people" size={32} color="#2E7D32" />
          <Text style={styles.statNumber}>10K+</Text>
          <Text style={styles.statLabel}>Happy Trekkers</Text>
        </View>
      </View>

      {/* Trending Now */}
      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Trending Now</Text>
          <MaterialIcons name="trending-up" size={24} color="#FF9800" />
        </View>
        
        {trendingTrips.slice(0, 3).map(trip => (
          <TripCard
            key={trip.id}
            trip={trip}
            onPress={() => navigation.navigate('TripDetails', { trip })}
          />
        ))}
      </View>

      {/* AI Trip Planner CTA */}
      <LinearGradient
        colors={['#4CAF50', '#2E7D32']}
        style={styles.aiCTA}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 0 }}
      >
        <View style={styles.aiCTAContent}>
          <MaterialIcons name="auto-awesome" size={48} color="#fff" />
          <View style={styles.aiCTAText}>
            <Text style={styles.aiCTATitle}>Not sure where to go?</Text>
            <Text style={styles.aiCTASubtitle}>
              Let our AI Trip Planner recommend the perfect trek for you
            </Text>
          </View>
        </View>
        <TouchableOpacity 
          style={styles.aiCTAButton}
          onPress={() => navigation.navigate('AIPlanner')}
        >
          <Text style={styles.aiCTAButtonText}>Plan My Trip</Text>
          <MaterialIcons name="arrow-forward" size={20} color="#2E7D32" />
        </TouchableOpacity>
      </LinearGradient>

      {/* Educational Section */}
      {educationalMode && (
        <View style={styles.eduSection}>
          <Text style={styles.sectionTitle}>Algorithm Features</Text>
          <Text style={styles.eduDescription}>
            This app demonstrates various computer science algorithms:
          </Text>
          
          <TouchableOpacity 
            style={styles.eduCard}
            onPress={() => navigation.navigate('EducationalPanel')}
          >
            <MaterialIcons name="search" size={28} color="#2196F3" />
            <View style={styles.eduCardContent}>
              <Text style={styles.eduCardTitle}>Binary Search</Text>
              <Text style={styles.eduCardDesc}>Fast trip search with O(log n) complexity</Text>
            </View>
            <MaterialIcons name="chevron-right" size={24} color="#666" />
          </TouchableOpacity>

          <TouchableOpacity 
            style={styles.eduCard}
            onPress={() => navigation.navigate('EducationalPanel')}
          >
            <MaterialIcons name="sort" size={28} color="#FF9800" />
            <View style={styles.eduCardContent}>
              <Text style={styles.eduCardTitle}>Quick Sort</Text>
              <Text style={styles.eduCardDesc}>Efficient sorting algorithm</Text>
            </View>
            <MaterialIcons name="chevron-right" size={24} color="#666" />
          </TouchableOpacity>

          <TouchableOpacity 
            style={styles.eduCard}
            onPress={() => navigation.navigate('EducationalPanel')}
          >
            <MaterialIcons name="route" size={28} color="#9C27B0" />
            <View style={styles.eduCardContent}>
              <Text style={styles.eduCardTitle}>Graph Algorithms</Text>
              <Text style={styles.eduCardDesc}>BFS, DFS, Dijkstra for route finding</Text>
            </View>
            <MaterialIcons name="chevron-right" size={24} color="#666" />
          </TouchableOpacity>
        </View>
      )}

      <View style={styles.bottomPadding} />
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9f9f9',
  },
  hero: {
    height: 320,
    padding: 24,
    justifyContent: 'space-between',
  },
  heroContent: {
    zIndex: 1,
  },
  greeting: {
    fontSize: 16,
    color: '#E8F5E9',
    marginBottom: 8,
  },
  heroTitle: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 12,
    lineHeight: 42,
  },
  heroSubtitle: {
    fontSize: 16,
    color: '#E8F5E9',
    marginBottom: 24,
  },
  exploreButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    paddingHorizontal: 24,
    paddingVertical: 14,
    borderRadius: 12,
    alignSelf: 'flex-start',
    gap: 8,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  exploreButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1E3A2C',
  },
  heroImage: {
    position: 'absolute',
    right: -20,
    bottom: 20,
    width: 180,
    height: 180,
    borderRadius: 90,
    opacity: 0.3,
  },
  eduBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
    alignSelf: 'flex-start',
    marginTop: 12,
    gap: 6,
  },
  eduBadgeText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '600',
  },
  section: {
    marginTop: 24,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#1a1a1a',
    paddingHorizontal: 16,
    marginBottom: 16,
  },
  seeAll: {
    fontSize: 14,
    color: '#2E7D32',
    fontWeight: '600',
  },
  categoriesContainer: {
    paddingHorizontal: 16,
    gap: 12,
  },
  categoryCard: {
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 16,
    padding: 20,
    width: 120,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  categoryIcon: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: '#E8F5E9',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  categoryName: {
    fontSize: 13,
    fontWeight: '600',
    color: '#1a1a1a',
    textAlign: 'center',
  },
  featuredContainer: {
    paddingHorizontal: 16,
  },
  statsContainer: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    gap: 12,
    marginTop: 24,
  },
  statCard: {
    flex: 1,
    backgroundColor: '#fff',
    borderRadius: 16,
    padding: 20,
    alignItems: 'center',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  statNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2E7D32',
    marginTop: 8,
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
  },
  aiCTA: {
    margin: 16,
    borderRadius: 20,
    padding: 24,
    marginTop: 32,
  },
  aiCTAContent: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
    gap: 16,
  },
  aiCTAText: {
    flex: 1,
  },
  aiCTATitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 6,
  },
  aiCTASubtitle: {
    fontSize: 14,
    color: '#E8F5E9',
    lineHeight: 20,
  },
  aiCTAButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    paddingHorizontal: 20,
    paddingVertical: 14,
    borderRadius: 12,
    alignSelf: 'flex-start',
    gap: 8,
  },
  aiCTAButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2E7D32',
  },
  eduSection: {
    padding: 16,
    marginTop: 24,
  },
  eduDescription: {
    fontSize: 14,
    color: '#666',
    marginBottom: 16,
    paddingHorizontal: 16,
  },
  eduCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  eduCardContent: {
    flex: 1,
    marginLeft: 16,
  },
  eduCardTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1a1a1a',
    marginBottom: 4,
  },
  eduCardDesc: {
    fontSize: 13,
    color: '#666',
  },
  bottomPadding: {
    height: 32,
  },
});

export default HomeScreen;
