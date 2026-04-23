import React, { useState } from 'react';
import { 
  View, Text, ScrollView, Image, StyleSheet, TouchableOpacity, 
  Dimensions 
} from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import useStore from '../store/useStore';

const { width } = Dimensions.get('window');

const TripDetailsScreen = ({ route, navigation }) => {
  const { trip } = route.params;
  const { savedTrips, toggleSavedTrip } = useStore();
  const [activeTab, setActiveTab] = useState('overview');
  
  const isSaved = savedTrips.includes(trip.id);

  const tabs = [
    { id: 'overview', label: 'Overview', icon: 'info' },
    { id: 'itinerary', label: 'Itinerary', icon: 'list' },
    { id: 'details', label: 'Details', icon: 'description' },
    { id: 'reviews', label: 'Reviews', icon: 'star' },
  ];

  return (
    <View style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Image Carousel */}
        <View style={styles.imageContainer}>
          <Image source={{ uri: trip.image }} style={styles.image} />
          <LinearGradient
            colors={['transparent', 'rgba(0,0,0,0.7)']}
            style={styles.imageGradient}
          />
          
          {/* Back Button */}
          <TouchableOpacity 
            style={styles.backButton}
            onPress={() => navigation.goBack()}
          >
            <MaterialIcons name="arrow-back" size={24} color="#fff" />
          </TouchableOpacity>

          {/* Save Button */}
          <TouchableOpacity 
            style={styles.saveButton}
            onPress={() => toggleSavedTrip(trip.id)}
          >
            <MaterialIcons 
              name={isSaved ? "favorite" : "favorite-border"} 
              size={24} 
              color={isSaved ? "#FF4444" : "#fff"} 
            />
          </TouchableOpacity>

          {/* Title Overlay */}
          <View style={styles.titleOverlay}>
            <Text style={styles.title}>{trip.title}</Text>
            <View style={styles.ratingContainer}>
              <MaterialIcons name="star" size={18} color="#FFD700" />
              <Text style={styles.rating}>{trip.rating}</Text>
              <Text style={styles.reviews}>({trip.reviews} reviews)</Text>
            </View>
          </View>
        </View>

        {/* Quick Info */}
        <View style={styles.quickInfo}>
          <View style={styles.infoItem}>
            <MaterialIcons name="schedule" size={24} color="#2E7D32" />
            <Text style={styles.infoLabel}>{trip.duration} days</Text>
          </View>
          <View style={styles.infoItem}>
            <MaterialIcons name="terrain" size={24} color="#2E7D32" />
            <Text style={styles.infoLabel}>{trip.difficulty}</Text>
          </View>
          <View style={styles.infoItem}>
            <MaterialIcons name="groups" size={24} color="#2E7D32" />
            <Text style={styles.infoLabel}>Max {trip.groupSize}</Text>
          </View>
          <View style={styles.infoItem}>
            <MaterialIcons name="landscape" size={24} color="#2E7D32" />
            <Text style={styles.infoLabel}>{trip.maxAltitude}m</Text>
          </View>
        </View>

        {/* Tabs */}
        <View style={styles.tabs}>
          {tabs.map(tab => (
            <TouchableOpacity
              key={tab.id}
              style={[styles.tab, activeTab === tab.id && styles.tabActive]}
              onPress={() => setActiveTab(tab.id)}
            >
              <MaterialIcons 
                name={tab.icon} 
                size={20} 
                color={activeTab === tab.id ? '#2E7D32' : '#666'} 
              />
              <Text style={[
                styles.tabText,
                activeTab === tab.id && styles.tabTextActive
              ]}>
                {tab.label}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Tab Content */}
        <View style={styles.content}>
          {activeTab === 'overview' && (
            <View>
              <Text style={styles.description}>{trip.shortDescription}</Text>
              
              <View style={styles.section}>
                <Text style={styles.sectionTitle}>Best Season</Text>
                <View style={styles.seasonContainer}>
                  {trip.season.map(s => (
                    <View key={s} style={styles.seasonChip}>
                      <MaterialIcons name="wb-sunny" size={16} color="#FF9800" />
                      <Text style={styles.seasonText}>{s}</Text>
                    </View>
                  ))}
                </View>
              </View>

              <View style={styles.section}>
                <Text style={styles.sectionTitle}>Highlights</Text>
                <View style={styles.highlightsList}>
                  <View style={styles.highlight}>
                    <MaterialIcons name="check-circle" size={20} color="#4CAF50" />
                    <Text style={styles.highlightText}>Stunning mountain views</Text>
                  </View>
                  <View style={styles.highlight}>
                    <MaterialIcons name="check-circle" size={20} color="#4CAF50" />
                    <Text style={styles.highlightText}>Cultural experiences</Text>
                  </View>
                  <View style={styles.highlight}>
                    <MaterialIcons name="check-circle" size={20} color="#4CAF50" />
                    <Text style={styles.highlightText}>Professional guides</Text>
                  </View>
                  <View style={styles.highlight}>
                    <MaterialIcons name="check-circle" size={20} color="#4CAF50" />
                    <Text style={styles.highlightText}>All permits included</Text>
                  </View>
                </View>
              </View>
            </View>
          )}

          {activeTab === 'itinerary' && (
            <View>
              {trip.itinerary.map((day, index) => (
                <View key={index} style={styles.dayCard}>
                  <View style={styles.dayNumber}>
                    <Text style={styles.dayNumberText}>Day {day.day}</Text>
                  </View>
                  <View style={styles.dayContent}>
                    <Text style={styles.dayTitle}>{day.title}</Text>
                    <Text style={styles.dayDescription}>{day.description}</Text>
                  </View>
                </View>
              ))}
            </View>
          )}

          {activeTab === 'details' && (
            <View>
              <View style={styles.section}>
                <Text style={styles.sectionTitle}>Included</Text>
                {trip.inclusions.map((item, index) => (
                  <View key={index} style={styles.listItem}>
                    <MaterialIcons name="check" size={20} color="#4CAF50" />
                    <Text style={styles.listItemText}>{item}</Text>
                  </View>
                ))}
              </View>

              <View style={styles.section}>
                <Text style={styles.sectionTitle}>Not Included</Text>
                {trip.exclusions.map((item, index) => (
                  <View key={index} style={styles.listItem}>
                    <MaterialIcons name="close" size={20} color="#F44336" />
                    <Text style={styles.listItemText}>{item}</Text>
                  </View>
                ))}
              </View>
            </View>
          )}

          {activeTab === 'reviews' && (
            <View>
              <View style={styles.ratingOverview}>
                <View style={styles.ratingScore}>
                  <Text style={styles.ratingNumber}>{trip.rating}</Text>
                  <View style={styles.stars}>
                    {[1, 2, 3, 4, 5].map(star => (
                      <MaterialIcons 
                        key={star}
                        name="star" 
                        size={20} 
                        color={star <= Math.round(trip.rating) ? "#FFD700" : "#ddd"} 
                      />
                    ))}
                  </View>
                  <Text style={styles.reviewCount}>{trip.reviews} reviews</Text>
                </View>
              </View>
              
              <View style={styles.reviewCard}>
                <Text style={styles.reviewAuthor}>Sample Review</Text>
                <View style={styles.reviewHeader}>
                  <View style={styles.stars}>
                    {[1, 2, 3, 4, 5].map(star => (
                      <MaterialIcons key={star} name="star" size={16} color="#FFD700" />
                    ))}
                  </View>
                  <Text style={styles.reviewDate}>1 month ago</Text>
                </View>
                <Text style={styles.reviewText}>
                  Amazing trek! The views were breathtaking and our guide was incredibly 
                  knowledgeable about the local culture and mountains. Highly recommend!
                </Text>
              </View>
            </View>
          )}
        </View>

        <View style={styles.bottomPadding} />
      </ScrollView>

      {/* Bottom Bar */}
      <View style={styles.bottomBar}>
        <View>
          <Text style={styles.priceLabel}>Starting from</Text>
          <Text style={styles.price}>NPR {trip.price.toLocaleString()}</Text>
        </View>
        <TouchableOpacity 
          style={styles.bookButton}
          onPress={() => navigation.navigate('Booking', { trip })}
        >
          <Text style={styles.bookButtonText}>Book Now</Text>
          <MaterialIcons name="arrow-forward" size={20} color="#fff" />
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  imageContainer: {
    width,
    height: 360,
    position: 'relative',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  imageGradient: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: 160,
  },
  backButton: {
    position: 'absolute',
    top: 44,
    left: 16,
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(0,0,0,0.5)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  saveButton: {
    position: 'absolute',
    top: 44,
    right: 16,
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(0,0,0,0.5)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  titleOverlay: {
    position: 'absolute',
    bottom: 20,
    left: 16,
    right: 16,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 8,
  },
  ratingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  rating: {
    fontSize: 16,
    fontWeight: '600',
    color: '#fff',
  },
  reviews: {
    fontSize: 14,
    color: '#E8F5E9',
  },
  quickInfo: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingVertical: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  infoItem: {
    alignItems: 'center',
  },
  infoLabel: {
    fontSize: 13,
    color: '#666',
    marginTop: 6,
    fontWeight: '500',
  },
  tabs: {
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  tab: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    gap: 6,
    borderBottomWidth: 2,
    borderBottomColor: 'transparent',
  },
  tabActive: {
    borderBottomColor: '#2E7D32',
  },
  tabText: {
    fontSize: 14,
    color: '#666',
  },
  tabTextActive: {
    color: '#2E7D32',
    fontWeight: '600',
  },
  content: {
    padding: 16,
  },
  description: {
    fontSize: 16,
    color: '#1a1a1a',
    lineHeight: 24,
    marginBottom: 24,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1a1a1a',
    marginBottom: 12,
  },
  seasonContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  seasonChip: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFF3E0',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 16,
    gap: 6,
  },
  seasonText: {
    fontSize: 14,
    color: '#E65100',
    fontWeight: '500',
  },
  highlightsList: {
    gap: 12,
  },
  highlight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  highlightText: {
    fontSize: 15,
    color: '#1a1a1a',
  },
  dayCard: {
    flexDirection: 'row',
    marginBottom: 20,
    gap: 16,
  },
  dayNumber: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#E8F5E9',
    alignItems: 'center',
    justifyContent: 'center',
  },
  dayNumberText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#2E7D32',
  },
  dayContent: {
    flex: 1,
  },
  dayTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1a1a1a',
    marginBottom: 6,
  },
  dayDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  listItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 12,
    marginBottom: 12,
  },
  listItemText: {
    flex: 1,
    fontSize: 15,
    color: '#1a1a1a',
  },
  ratingOverview: {
    backgroundColor: '#f9f9f9',
    borderRadius: 16,
    padding: 24,
    alignItems: 'center',
    marginBottom: 24,
  },
  ratingScore: {
    alignItems: 'center',
  },
  ratingNumber: {
    fontSize: 48,
    fontWeight: 'bold',
    color: '#2E7D32',
    marginBottom: 8,
  },
  stars: {
    flexDirection: 'row',
    gap: 4,
    marginBottom: 8,
  },
  reviewCount: {
    fontSize: 14,
    color: '#666',
  },
  reviewCard: {
    backgroundColor: '#f9f9f9',
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
  },
  reviewAuthor: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1a1a1a',
    marginBottom: 8,
  },
  reviewHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  reviewDate: {
    fontSize: 13,
    color: '#999',
  },
  reviewText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  bottomPadding: {
    height: 100,
  },
  bottomBar: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#fff',
    paddingHorizontal: 16,
    paddingVertical: 16,
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
  },
  priceLabel: {
    fontSize: 12,
    color: '#666',
  },
  price: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2E7D32',
  },
  bookButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2E7D32',
    paddingHorizontal: 32,
    paddingVertical: 14,
    borderRadius: 12,
    gap: 8,
  },
  bookButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#fff',
  },
});

export default TripDetailsScreen;
