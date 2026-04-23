import React, { useState } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import useStore from '../store/useStore';

const FilterBar = () => {
  const { filters, setFilter, applyFilters, resetFilters } = useStore();
  const [showAdvanced, setShowAdvanced] = useState(false);

  const difficulties = ['All', 'Easy', 'Moderate', 'Challenging', 'Advanced'];
  const regions = ['All', 'Everest', 'Annapurna', 'Langtang', 'Manaslu', 'Mustang', 'Kathmandu Valley'];
  const categories = ['All', 'Trekking', 'Cultural', 'Peak Climbing', 'Adventure'];
  const seasons = ['All', 'Spring', 'Summer', 'Autumn', 'Winter'];

  const handleFilterChange = (key, value) => {
    setFilter(key, value);
  };

  const handleApplyFilters = () => {
    applyFilters();
  };

  return (
    <View style={styles.container}>
      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <MaterialIcons name="search" size={24} color="#666" />
        <TextInput
          style={styles.searchInput}
          placeholder="Search destinations..."
          value={filters.searchQuery}
          onChangeText={(text) => handleFilterChange('searchQuery', text)}
          onSubmitEditing={handleApplyFilters}
        />
        {filters.searchQuery ? (
          <TouchableOpacity onPress={() => {
            handleFilterChange('searchQuery', '');
            handleApplyFilters();
          }}>
            <MaterialIcons name="close" size={20} color="#666" />
          </TouchableOpacity>
        ) : null}
      </View>

      {/* Quick Filters */}
      <ScrollView 
        horizontal 
        showsHorizontalScrollIndicator={false}
        style={styles.quickFilters}
        contentContainerStyle={styles.quickFiltersContent}
      >
        <TouchableOpacity 
          style={[styles.quickFilterChip, showAdvanced && styles.quickFilterChipActive]}
          onPress={() => setShowAdvanced(!showAdvanced)}
        >
          <MaterialIcons 
            name={showAdvanced ? "filter-list-off" : "filter-list"} 
            size={18} 
            color={showAdvanced ? "#fff" : "#2E7D32"} 
          />
          <Text style={[styles.quickFilterText, showAdvanced && styles.quickFilterTextActive]}>
            {showAdvanced ? 'Hide' : 'Filters'}
          </Text>
        </TouchableOpacity>

        {difficulties.map(diff => (
          <TouchableOpacity
            key={diff}
            style={[
              styles.quickFilterChip,
              filters.difficulty === diff && styles.quickFilterChipActive
            ]}
            onPress={() => {
              handleFilterChange('difficulty', diff);
              handleApplyFilters();
            }}
          >
            <Text style={[
              styles.quickFilterText,
              filters.difficulty === diff && styles.quickFilterTextActive
            ]}>
              {diff}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* Advanced Filters */}
      {showAdvanced && (
        <View style={styles.advancedFilters}>
          {/* Region Filter */}
          <View style={styles.filterSection}>
            <Text style={styles.filterLabel}>Region</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false}>
              {regions.map(region => (
                <TouchableOpacity
                  key={region}
                  style={[
                    styles.filterOption,
                    filters.region === region && styles.filterOptionActive
                  ]}
                  onPress={() => handleFilterChange('region', region)}
                >
                  <Text style={[
                    styles.filterOptionText,
                    filters.region === region && styles.filterOptionTextActive
                  ]}>
                    {region}
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>

          {/* Category Filter */}
          <View style={styles.filterSection}>
            <Text style={styles.filterLabel}>Category</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false}>
              {categories.map(cat => (
                <TouchableOpacity
                  key={cat}
                  style={[
                    styles.filterOption,
                    filters.category === cat && styles.filterOptionActive
                  ]}
                  onPress={() => handleFilterChange('category', cat)}
                >
                  <Text style={[
                    styles.filterOptionText,
                    filters.category === cat && styles.filterOptionTextActive
                  ]}>
                    {cat}
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>

          {/* Season Filter */}
          <View style={styles.filterSection}>
            <Text style={styles.filterLabel}>Season</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false}>
              {seasons.map(season => (
                <TouchableOpacity
                  key={season}
                  style={[
                    styles.filterOption,
                    filters.season === season && styles.filterOptionActive
                  ]}
                  onPress={() => handleFilterChange('season', season)}
                >
                  <Text style={[
                    styles.filterOptionText,
                    filters.season === season && styles.filterOptionTextActive
                  ]}>
                    {season}
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>

          {/* Price Range */}
          <View style={styles.filterSection}>
            <Text style={styles.filterLabel}>
              Price Range: NPR {filters.minPrice} - {filters.maxPrice}
            </Text>
            <View style={styles.rangeInputs}>
              <TextInput
                style={styles.rangeInput}
                placeholder="Min"
                keyboardType="numeric"
                value={filters.minPrice.toString()}
                onChangeText={(text) => handleFilterChange('minPrice', parseInt(text) || 0)}
              />
              <Text style={styles.rangeSeparator}>to</Text>
              <TextInput
                style={styles.rangeInput}
                placeholder="Max"
                keyboardType="numeric"
                value={filters.maxPrice.toString()}
                onChangeText={(text) => handleFilterChange('maxPrice', parseInt(text) || 5000)}
              />
            </View>
          </View>

          {/* Duration Range */}
          <View style={styles.filterSection}>
            <Text style={styles.filterLabel}>
              Duration: {filters.minDuration} - {filters.maxDuration} days
            </Text>
            <View style={styles.rangeInputs}>
              <TextInput
                style={styles.rangeInput}
                placeholder="Min days"
                keyboardType="numeric"
                value={filters.minDuration.toString()}
                onChangeText={(text) => handleFilterChange('minDuration', parseInt(text) || 0)}
              />
              <Text style={styles.rangeSeparator}>to</Text>
              <TextInput
                style={styles.rangeInput}
                placeholder="Max days"
                keyboardType="numeric"
                value={filters.maxDuration.toString()}
                onChangeText={(text) => handleFilterChange('maxDuration', parseInt(text) || 30)}
              />
            </View>
          </View>

          {/* Action Buttons */}
          <View style={styles.actionButtons}>
            <TouchableOpacity 
              style={styles.resetButton}
              onPress={() => {
                resetFilters();
                handleApplyFilters();
              }}
            >
              <MaterialIcons name="refresh" size={20} color="#666" />
              <Text style={styles.resetButtonText}>Reset</Text>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={styles.applyButton}
              onPress={handleApplyFilters}
            >
              <MaterialIcons name="check" size={20} color="#fff" />
              <Text style={styles.applyButtonText}>Apply Filters</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#fff',
    paddingTop: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    marginHorizontal: 16,
    marginBottom: 12,
  },
  searchInput: {
    flex: 1,
    marginLeft: 12,
    fontSize: 16,
    color: '#1a1a1a',
  },
  quickFilters: {
    marginBottom: 12,
  },
  quickFiltersContent: {
    paddingHorizontal: 16,
    gap: 8,
  },
  quickFilterChip: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: '#E8F5E9',
    marginRight: 8,
    gap: 6,
  },
  quickFilterChipActive: {
    backgroundColor: '#2E7D32',
  },
  quickFilterText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2E7D32',
  },
  quickFilterTextActive: {
    color: '#fff',
  },
  advancedFilters: {
    padding: 16,
    backgroundColor: '#f9f9f9',
  },
  filterSection: {
    marginBottom: 20,
  },
  filterLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1a1a1a',
    marginBottom: 12,
  },
  filterOption: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 16,
    backgroundColor: '#fff',
    marginRight: 8,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  filterOptionActive: {
    backgroundColor: '#2E7D32',
    borderColor: '#2E7D32',
  },
  filterOptionText: {
    fontSize: 13,
    color: '#666',
  },
  filterOptionTextActive: {
    color: '#fff',
    fontWeight: '600',
  },
  rangeInputs: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  rangeInput: {
    flex: 1,
    backgroundColor: '#fff',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderWidth: 1,
    borderColor: '#e0e0e0',
    fontSize: 14,
  },
  rangeSeparator: {
    color: '#666',
    fontSize: 14,
  },
  actionButtons: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 8,
  },
  resetButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 14,
    borderRadius: 12,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#e0e0e0',
    gap: 8,
  },
  resetButtonText: {
    fontSize: 15,
    fontWeight: '600',
    color: '#666',
  },
  applyButton: {
    flex: 2,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 14,
    borderRadius: 12,
    backgroundColor: '#2E7D32',
    gap: 8,
  },
  applyButtonText: {
    fontSize: 15,
    fontWeight: '600',
    color: '#fff',
  },
});

export default FilterBar;
