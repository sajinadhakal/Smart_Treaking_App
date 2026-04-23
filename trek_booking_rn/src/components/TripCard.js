import React from 'react';
import { View, Text, Image, TouchableOpacity, StyleSheet } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import useStore from '../store/useStore';

const TripCard = ({ trip, onPress, variant = 'default' }) => {
  const { savedTrips, toggleSavedTrip } = useStore();
  const isSaved = savedTrips.includes(trip.id);

  if (variant === 'featured') {
    return (
      <TouchableOpacity style={styles.featuredCard} onPress={onPress} activeOpacity={0.9}>
        <Image source={{ uri: trip.image }} style={styles.featuredImage} />
        <View style={styles.featuredOverlay}>
          <View style={styles.featuredContent}>
            <Text style={styles.featuredTitle} numberOfLines={2}>{trip.title}</Text>
            <View style={styles.featuredMeta}>
              <View style={styles.metaItem}>
                <MaterialIcons name="schedule" size={16} color="#fff" />
                <Text style={styles.metaText}>{trip.duration} days</Text>
              </View>
              <View style={styles.metaItem}>
                <MaterialIcons name="star" size={16} color="#FFD700" />
                <Text style={styles.metaText}>{trip.rating}</Text>
              </View>
            </View>
            <Text style={styles.featuredPrice}>NPR {trip.price.toLocaleString()}</Text>
          </View>
          <TouchableOpacity 
            style={styles.saveButton}
            onPress={(e) => {
              e.stopPropagation();
              toggleSavedTrip(trip.id);
            }}
          >
            <MaterialIcons 
              name={isSaved ? "favorite" : "favorite-border"} 
              size={24} 
              color={isSaved ? "#FF4444" : "#fff"} 
            />
          </TouchableOpacity>
        </View>
      </TouchableOpacity>
    );
  }

  return (
    <TouchableOpacity style={styles.card} onPress={onPress} activeOpacity={0.95}>
      <Image source={{ uri: trip.image }} style={styles.image} />
      <TouchableOpacity 
        style={styles.saveIconButton}
        onPress={(e) => {
          e.stopPropagation();
          toggleSavedTrip(trip.id);
        }}
      >
        <MaterialIcons 
          name={isSaved ? "favorite" : "favorite-border"} 
          size={20} 
          color={isSaved ? "#FF4444" : "#fff"} 
        />
      </TouchableOpacity>
      
      <View style={styles.content}>
        <View style={styles.header}>
          <Text style={styles.title} numberOfLines={2}>{trip.title}</Text>
          <View style={styles.ratingContainer}>
            <MaterialIcons name="star" size={16} color="#FFD700" />
            <Text style={styles.rating}>{trip.rating}</Text>
            <Text style={styles.reviews}>({trip.reviews})</Text>
          </View>
        </View>

        <Text style={styles.description} numberOfLines={2}>
          {trip.shortDescription}
        </Text>

        <View style={styles.details}>
          <View style={styles.detailItem}>
            <MaterialIcons name="place" size={16} color="#666" />
            <Text style={styles.detailText}>{trip.region}</Text>
          </View>
          <View style={styles.detailItem}>
            <MaterialIcons name="schedule" size={16} color="#666" />
            <Text style={styles.detailText}>{trip.duration} days</Text>
          </View>
          <View style={[styles.badge, styles[`badge${trip.difficulty}`]]}>
            <Text style={styles.badgeText}>{trip.difficulty}</Text>
          </View>
        </View>

        <View style={styles.footer}>
          <View>
            <Text style={styles.priceLabel}>Starting from</Text>
            <Text style={styles.price}>NPR {trip.price.toLocaleString()}</Text>
          </View>
          <TouchableOpacity style={styles.bookButton}>
            <Text style={styles.bookButtonText}>View Details</Text>
            <MaterialIcons name="arrow-forward" size={16} color="#fff" />
          </TouchableOpacity>
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#fff',
    borderRadius: 16,
    marginHorizontal: 16,
    marginVertical: 8,
    overflow: 'hidden',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
  },
  image: {
    width: '100%',
    height: 200,
    backgroundColor: '#e0e0e0',
  },
  saveIconButton: {
    position: 'absolute',
    top: 12,
    right: 12,
    backgroundColor: 'rgba(0,0,0,0.5)',
    borderRadius: 20,
    padding: 8,
    zIndex: 10,
  },
  content: {
    padding: 16,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1a1a1a',
    flex: 1,
    marginRight: 8,
  },
  ratingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  rating: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1a1a1a',
  },
  reviews: {
    fontSize: 12,
    color: '#666',
  },
  description: {
    fontSize: 14,
    color: '#666',
    marginBottom: 12,
    lineHeight: 20,
  },
  details: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginBottom: 16,
    flexWrap: 'wrap',
  },
  detailItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  detailText: {
    fontSize: 13,
    color: '#666',
  },
  badge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  badgeEasy: {
    backgroundColor: '#E8F5E9',
  },
  badgeModerate: {
    backgroundColor: '#FFF3E0',
  },
  badgeChallenging: {
    backgroundColor: '#FFEBEE',
  },
  badgeAdvanced: {
    backgroundColor: '#F3E5F5',
  },
  badgeText: {
    fontSize: 11,
    fontWeight: '600',
    color: '#666',
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  priceLabel: {
    fontSize: 12,
    color: '#666',
  },
  price: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2E7D32',
  },
  bookButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2E7D32',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
    gap: 4,
  },
  bookButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  
  // Featured card styles
  featuredCard: {
    width: 300,
    height: 400,
    borderRadius: 20,
    overflow: 'hidden',
    marginRight: 16,
    elevation: 6,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 12,
  },
  featuredImage: {
    width: '100%',
    height: '100%',
    position: 'absolute',
  },
  featuredOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.3)',
    justifyContent: 'flex-end',
    padding: 20,
  },
  featuredContent: {
    marginBottom: 8,
  },
  featuredTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 12,
  },
  featuredMeta: {
    flexDirection: 'row',
    gap: 16,
    marginBottom: 8,
  },
  metaItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  metaText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '500',
  },
  featuredPrice: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#4CAF50',
  },
  saveButton: {
    position: 'absolute',
    top: 16,
    right: 16,
    backgroundColor: 'rgba(0,0,0,0.5)',
    borderRadius: 24,
    padding: 10,
  },
});

export default TripCard;
