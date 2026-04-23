import React, { useState } from 'react';
import { 
  View, Text, ScrollView, StyleSheet, TextInput, 
  TouchableOpacity 
} from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import RecommendationAlgorithm from '../algorithms/RecommendationAlgorithm';
import GreedyAlgorithm from '../algorithms/GreedyAlgorithm';
import DynamicProgrammingAlgorithm from '../algorithms/DynamicProgramming';
import useStore from '../store/useStore';
import TripCard from '../components/TripCard';
import AlgorithmVisualizer from '../components/AlgorithmVisualizer';

const AIPlannerScreen = ({ navigation }) => {
  const { trips, educationalMode, setAlgorithmResult } = useStore();
  const [budget, setBudget] = useState('2000');
  const [days, setDays] = useState('14');
  const [difficulty, setDifficulty] = useState('Moderate');
  const [season, setSeason] = useState('Spring');
  const [recommendations, setRecommendations] = useState(null);
  const [showAlgorithm, setShowAlgorithm] = useState(false);
  const [algorithmType, setAlgorithmType] = useState('recommendation');

  const difficulties = ['Easy', 'Moderate', 'Challenging', 'Advanced'];
  const seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];

  const handleGetRecommendations = () => {
    if (algorithmType === 'recommendation') {
      // Rule-based recommendation
      const recommender = new RecommendationAlgorithm();
      const result = recommender.recommendTrips(trips, {
        budget: parseInt(budget),
        daysAvailable: parseInt(days),
        difficulty,
        season,
        preferences: {}
      });
      setRecommendations(result.recommendations);
      if (educationalMode) {
        setAlgorithmResult(result);
      }
    } else if (algorithmType === 'greedy') {
      // Greedy algorithm
      const greedy = new GreedyAlgorithm();
      const result = greedy.optimalTripSelection(trips, parseInt(budget), parseInt(days));
      setRecommendations(result.selectedTrips.map(trip => ({
        trip,
        score: 100,
        reasons: ['Selected by greedy algorithm']
      })));
      if (educationalMode) {
        setAlgorithmResult(result);
      }
    } else if (algorithmType === 'dp') {
      // Dynamic Programming
      const dp = new DynamicProgrammingAlgorithm();
      const result = dp.maxExperienceInDays(trips, parseInt(days), parseInt(budget));
      setRecommendations(result.selectedTrips.map(trip => ({
        trip,
        score: 100,
        reasons: ['Selected by DP algorithm']
      })));
      if (educationalMode) {
        setAlgorithmResult(result);
      }
    }
  };

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Header */}
      <LinearGradient
        colors={['#4CAF50', '#2E7D32']}
        style={styles.header}
      >
        <MaterialIcons name="auto-awesome" size={48} color="#fff" />
        <Text style={styles.headerTitle}>AI Trip Planner</Text>
        <Text style={styles.headerSubtitle}>
          Let our algorithm find the perfect trek for you
        </Text>
      </LinearGradient>

      {/* Algorithm Selector */}
      {educationalMode && (
        <View style={styles.algorithmSelector}>
          <Text style={styles.sectionTitle}>Select Algorithm</Text>
          <View style={styles.algorithmOptions}>
            <TouchableOpacity
              style={[
                styles.algorithmChip,
                algorithmType === 'recommendation' && styles.algorithmChipActive
              ]}
              onPress={() => setAlgorithmType('recommendation')}
            >
              <MaterialIcons 
                name="psychology" 
                size={20} 
                color={algorithmType === 'recommendation' ? '#fff' : '#2E7D32'} 
              />
              <Text style={[
                styles.algorithmChipText,
                algorithmType === 'recommendation' && styles.algorithmChipTextActive
              ]}>
                Rule-Based
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[
                styles.algorithmChip,
                algorithmType === 'greedy' && styles.algorithmChipActive
              ]}
              onPress={() => setAlgorithmType('greedy')}
            >
              <MaterialIcons 
                name="trending-up" 
                size={20} 
                color={algorithmType === 'greedy' ? '#fff' : '#2E7D32'} 
              />
              <Text style={[
                styles.algorithmChipText,
                algorithmType === 'greedy' && styles.algorithmChipTextActive
              ]}>
                Greedy
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={[
                styles.algorithmChip,
                algorithmType === 'dp' && styles.algorithmChipActive
              ]}
              onPress={() => setAlgorithmType('dp')}
            >
              <MaterialIcons 
                name="memory" 
                size={20} 
                color={algorithmType === 'dp' ? '#fff' : '#2E7D32'} 
              />
              <Text style={[
                styles.algorithmChipText,
                algorithmType === 'dp' && styles.algorithmChipTextActive
              ]}>
                Dynamic Programming
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      )}

      {/* Form */}
      <View style={styles.form}>
        <View style={styles.inputGroup}>
          <Text style={styles.label}>Budget (NPR)</Text>
          <View style={styles.inputContainer}>
            <MaterialIcons name="attach-money" size={20} color="#666" />
            <TextInput
              style={styles.input}
              value={budget}
              onChangeText={setBudget}
              keyboardType="numeric"
              placeholder="Enter your budget"
            />
          </View>
        </View>

        <View style={styles.inputGroup}>
          <Text style={styles.label}>Available Days</Text>
          <View style={styles.inputContainer}>
            <MaterialIcons name="schedule" size={20} color="#666" />
            <TextInput
              style={styles.input}
              value={days}
              onChangeText={setDays}
              keyboardType="numeric"
              placeholder="Number of days"
            />
          </View>
        </View>

        <View style={styles.inputGroup}>
          <Text style={styles.label}>Difficulty Level</Text>
          <View style={styles.optionsRow}>
            {difficulties.map(diff => (
              <TouchableOpacity
                key={diff}
                style={[
                  styles.option,
                  difficulty === diff && styles.optionActive
                ]}
                onPress={() => setDifficulty(diff)}
              >
                <Text style={[
                  styles.optionText,
                  difficulty === diff && styles.optionTextActive
                ]}>
                  {diff}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        <View style={styles.inputGroup}>
          <Text style={styles.label}>Preferred Season</Text>
          <View style={styles.optionsRow}>
            {seasons.map(s => (
              <TouchableOpacity
                key={s}
                style={[
                  styles.option,
                  season === s && styles.optionActive
                ]}
                onPress={() => setSeason(s)}
              >
                <Text style={[
                  styles.optionText,
                  season === s && styles.optionTextActive
                ]}>
                  {s}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        <TouchableOpacity 
          style={styles.submitButton}
          onPress={handleGetRecommendations}
        >
          <MaterialIcons name="search" size={24} color="#fff" />
          <Text style={styles.submitButtonText}>Find Perfect Treks</Text>
        </TouchableOpacity>
      </View>

      {/* Algorithm Visualization */}
      {educationalMode && showAlgorithm && recommendations && (
        <AlgorithmVisualizer
          algorithmResult={useStore.getState().algorithmResult}
          algorithm="Recommendation Algorithm"
        />
      )}

      {/* Results */}
      {recommendations && recommendations.length > 0 && (
        <View style={styles.results}>
          <View style={styles.resultsHeader}>
            <Text style={styles.resultsTitle}>
              Top {recommendations.length} Recommendations
            </Text>
            {educationalMode && (
              <TouchableOpacity onPress={() => setShowAlgorithm(!showAlgorithm)}>
                <MaterialIcons 
                  name={showAlgorithm ? "visibility-off" : "visibility"} 
                  size={24} 
                  color="#2E7D32" 
                />
              </TouchableOpacity>
            )}
          </View>

          {recommendations.slice(0, 5).map((item, index) => (
            <View key={item.trip.id} style={styles.recommendationCard}>
              <View style={styles.rankBadge}>
                <Text style={styles.rankText}>#{index + 1}</Text>
                <Text style={styles.scoreText}>{item.score} pts</Text>
              </View>
              
              <TripCard
                trip={item.trip}
                onPress={() => navigation.navigate('TripDetails', { trip: item.trip })}
              />
              
              {item.reasons && item.reasons.length > 0 && (
                <View style={styles.reasonsContainer}>
                  <Text style={styles.reasonsTitle}>Why this trek?</Text>
                  {item.reasons.map((reason, idx) => (
                    <View key={idx} style={styles.reason}>
                      <MaterialIcons name="check-circle" size={16} color="#4CAF50" />
                      <Text style={styles.reasonText}>{reason}</Text>
                    </View>
                  ))}
                </View>
              )}
            </View>
          ))}
        </View>
      )}

      {recommendations && recommendations.length === 0 && (
        <View style={styles.noResults}>
          <MaterialIcons name="search-off" size={64} color="#ccc" />
          <Text style={styles.noResultsText}>No matching treks found</Text>
          <Text style={styles.noResultsSubtext}>
            Try adjusting your budget or duration
          </Text>
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
  header: {
    padding: 32,
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 16,
    marginBottom: 8,
  },
  headerSubtitle: {
    fontSize: 16,
    color: '#E8F5E9',
    textAlign: 'center',
  },
  algorithmSelector: {
    padding: 16,
    backgroundColor: '#fff',
    marginBottom: 8,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1a1a1a',
    marginBottom: 12,
  },
  algorithmOptions: {
    flexDirection: 'row',
    gap: 8,
  },
  algorithmChip: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    paddingHorizontal: 12,
    borderRadius: 12,
    backgroundColor: '#E8F5E9',
    gap: 6,
  },
  algorithmChipActive: {
    backgroundColor: '#2E7D32',
  },
  algorithmChipText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#2E7D32',
  },
  algorithmChipTextActive: {
    color: '#fff',
  },
  form: {
    backgroundColor: '#fff',
    padding: 16,
    marginBottom: 16,
  },
  inputGroup: {
    marginBottom: 24,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1a1a1a',
    marginBottom: 12,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    gap: 12,
  },
  input: {
    flex: 1,
    fontSize: 16,
    color: '#1a1a1a',
  },
  optionsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  option: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
    backgroundColor: '#f5f5f5',
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  optionActive: {
    backgroundColor: '#2E7D32',
    borderColor: '#2E7D32',
  },
  optionText: {
    fontSize: 14,
    color: '#666',
    fontWeight: '500',
  },
  optionTextActive: {
    color: '#fff',
    fontWeight: '600',
  },
  submitButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#2E7D32',
    paddingVertical: 16,
    borderRadius: 12,
    gap: 8,
    marginTop: 8,
  },
  submitButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#fff',
  },
  results: {
    padding: 16,
  },
  resultsHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  resultsTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#1a1a1a',
  },
  recommendationCard: {
    marginBottom: 24,
  },
  rankBadge: {
    position: 'absolute',
    top: 12,
    left: 24,
    backgroundColor: '#2E7D32',
    borderRadius: 20,
    paddingHorizontal: 12,
    paddingVertical: 6,
    zIndex: 100,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  rankText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#fff',
  },
  scoreText: {
    fontSize: 12,
    color: '#E8F5E9',
  },
  reasonsContainer: {
    backgroundColor: '#E8F5E9',
    borderRadius: 12,
    padding: 16,
    marginTop: 12,
    marginHorizontal: 16,
  },
  reasonsTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1a1a1a',
    marginBottom: 8,
  },
  reason: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 6,
  },
  reasonText: {
    fontSize: 13,
    color: '#1a1a1a',
  },
  noResults: {
    alignItems: 'center',
    padding: 40,
  },
  noResultsText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#666',
    marginTop: 16,
  },
  noResultsSubtext: {
    fontSize: 14,
    color: '#999',
    marginTop: 8,
  },
  bottomPadding: {
    height: 32,
  },
});

export default AIPlannerScreen;
