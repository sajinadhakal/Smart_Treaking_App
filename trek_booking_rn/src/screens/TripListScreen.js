import React, { useEffect } from 'react';
import { View, FlatList, StyleSheet, TouchableOpacity, Text } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import useStore from '../store/useStore';
import TripCard from '../components/TripCard';
import FilterBar from '../components/FilterBar';

const TripListScreen = ({ navigation, route }) => {
  const { filteredTrips, sortBy, setSortBy, applyFilters } = useStore();
  const [showSortMenu, setShowSortMenu] = React.useState(false);

  useEffect(() => {
    applyFilters();
  }, []);

  const sortOptions = [
    { id: 'popularity', label: 'Most Popular', icon: 'trending-up' },
    { id: 'rating', label: 'Highest Rated', icon: 'star' },
    { id: 'price-low', label: 'Price: Low to High', icon: 'arrow-upward' },
    { id: 'price-high', label: 'Price: High to Low', icon: 'arrow-downward' },
    { id: 'duration-short', label: 'Duration: Shortest', icon: 'schedule' },
    { id: 'duration-long', label: 'Duration: Longest', icon: 'schedule' },
  ];

  const currentSort = sortOptions.find(opt => opt.id === sortBy);

  return (
    <View style={styles.container}>
      <FilterBar />
      
      {/* Sort Bar */}
      <View style={styles.sortBar}>
        <Text style={styles.resultText}>
          {filteredTrips.length} {filteredTrips.length === 1 ? 'trek' : 'treks'} found
        </Text>
        
        <TouchableOpacity 
          style={styles.sortButton}
          onPress={() => setShowSortMenu(!showSortMenu)}
        >
          <MaterialIcons name={currentSort.icon} size={18} color="#2E7D32" />
          <Text style={styles.sortButtonText}>{currentSort.label}</Text>
          <MaterialIcons 
            name={showSortMenu ? "expand-less" : "expand-more"} 
            size={20} 
            color="#666" 
          />
        </TouchableOpacity>
      </View>

      {/* Sort Menu */}
      {showSortMenu && (
        <View style={styles.sortMenu}>
          {sortOptions.map(option => (
            <TouchableOpacity
              key={option.id}
              style={[
                styles.sortOption,
                sortBy === option.id && styles.sortOptionActive
              ]}
              onPress={() => {
                setSortBy(option.id);
                setShowSortMenu(false);
              }}
            >
              <MaterialIcons 
                name={option.icon} 
                size={20} 
                color={sortBy === option.id ? '#2E7D32' : '#666'} 
              />
              <Text style={[
                styles.sortOptionText,
                sortBy === option.id && styles.sortOptionTextActive
              ]}>
                {option.label}
              </Text>
              {sortBy === option.id && (
                <MaterialIcons name="check" size={20} color="#2E7D32" />
              )}
            </TouchableOpacity>
          ))}
        </View>
      )}

      {/* Trip List */}
      <FlatList
        data={filteredTrips}
        renderItem={({ item }) => (
          <TripCard
            trip={item}
            onPress={() => navigation.navigate('TripDetails', { trip: item })}
          />
        )}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.listContent}
        ListEmptyComponent={
          <View style={styles.emptyState}>
            <MaterialIcons name="search-off" size={64} color="#ccc" />
            <Text style={styles.emptyText}>No treks found</Text>
            <Text style={styles.emptySubtext}>Try adjusting your filters</Text>
          </View>
        }
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9f9f9',
  },
  sortBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  resultText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1a1a1a',
  },
  sortButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  sortButtonText: {
    fontSize: 14,
    color: '#2E7D32',
    fontWeight: '500',
  },
  sortMenu: {
    backgroundColor: '#fff',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    marginHorizontal: 16,
    marginTop: 8,
    borderRadius: 12,
    overflow: 'hidden',
  },
  sortOption: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 14,
    gap: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  sortOptionActive: {
    backgroundColor: '#E8F5E9',
  },
  sortOptionText: {
    flex: 1,
    fontSize: 15,
    color: '#666',
  },
  sortOptionTextActive: {
    color: '#2E7D32',
    fontWeight: '600',
  },
  listContent: {
    paddingVertical: 8,
  },
  emptyState: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 80,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#666',
    marginTop: 16,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#999',
    marginTop: 8,
  },
});

export default TripListScreen;
