import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Animated } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

const AlgorithmVisualizer = ({ algorithmResult, algorithm }) => {
  const [currentStep, setCurrentStep] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const fadeAnim = new Animated.Value(1);

  useEffect(() => {
    setCurrentStep(0);
    setIsPlaying(false);
  }, [algorithmResult]);

  useEffect(() => {
    if (isPlaying && algorithmResult && currentStep < algorithmResult.steps.length - 1) {
      const timer = setTimeout(() => {
        Animated.sequence([
          Animated.timing(fadeAnim, {
            toValue: 0.5,
            duration: 150,
            useNativeDriver: true,
          }),
          Animated.timing(fadeAnim, {
            toValue: 1,
            duration: 150,
            useNativeDriver: true,
          }),
        ]).start();

        setCurrentStep(prev => prev + 1);
      }, 1000);

      return () => clearTimeout(timer);
    } else if (isPlaying && currentStep >= algorithmResult.steps.length - 1) {
      setIsPlaying(false);
    }
  }, [isPlaying, currentStep]);

  if (!algorithmResult) {
    return (
      <View style={styles.emptyState}>
        <MaterialIcons name="science" size={64} color="#ccc" />
        <Text style={styles.emptyText}>No algorithm result to display</Text>
        <Text style={styles.emptySubtext}>
          Use the sorting or search features to see algorithm visualization
        </Text>
      </View>
    );
  }

  const step = algorithmResult.steps[currentStep];

  const getStepIcon = (type) => {
    switch (type) {
      case 'start': return 'play-circle-filled';
      case 'compare': return 'compare-arrows';
      case 'swap': return 'swap-horiz';
      case 'found': return 'check-circle';
      case 'not-found': return 'cancel';
      case 'visit': return 'place';
      case 'enqueue': return 'add-circle';
      case 'select': return 'touch-app';
      case 'skip': return 'skip-next';
      case 'complete': return 'done-all';
      default: return 'info';
    }
  };

  const getStepColor = (type) => {
    switch (type) {
      case 'found': return '#4CAF50';
      case 'not-found': return '#F44336';
      case 'compare': return '#2196F3';
      case 'swap': return '#FF9800';
      case 'select': return '#9C27B0';
      default: return '#666';
    }
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <View>
          <Text style={styles.title}>{algorithm} Visualization</Text>
          <Text style={styles.complexity}>
            Time Complexity: <Text style={styles.complexityValue}>{algorithmResult.complexity}</Text>
          </Text>
        </View>
        <MaterialIcons name="science" size={32} color="#2E7D32" />
      </View>

      {/* Stats */}
      <View style={styles.stats}>
        {algorithmResult.comparisons !== undefined && (
          <View style={styles.stat}>
            <Text style={styles.statLabel}>Comparisons</Text>
            <Text style={styles.statValue}>{algorithmResult.comparisons}</Text>
          </View>
        )}
        {algorithmResult.swaps !== undefined && (
          <View style={styles.stat}>
            <Text style={styles.statLabel}>Swaps</Text>
            <Text style={styles.statValue}>{algorithmResult.swaps}</Text>
          </View>
        )}
        {algorithmResult.visitedCount !== undefined && (
          <View style={styles.stat}>
            <Text style={styles.statLabel}>Nodes Visited</Text>
            <Text style={styles.statValue}>{algorithmResult.visitedCount}</Text>
          </View>
        )}
      </View>

      {/* Step Display */}
      <Animated.View style={[styles.stepContainer, { opacity: fadeAnim }]}>
        <View style={styles.stepHeader}>
          <View style={[styles.stepIcon, { backgroundColor: getStepColor(step.type) + '20' }]}>
            <MaterialIcons name={getStepIcon(step.type)} size={24} color={getStepColor(step.type)} />
          </View>
          <View style={styles.stepInfo}>
            <Text style={styles.stepType}>{step.type.toUpperCase()}</Text>
            <Text style={styles.stepMessage}>{step.message}</Text>
          </View>
        </View>

        {/* Step Details */}
        {Object.keys(step).filter(key => !['type', 'message'].includes(key)).length > 0 && (
          <ScrollView style={styles.stepDetails} nestedScrollEnabled>
            {Object.entries(step)
              .filter(([key]) => !['type', 'message'].includes(key))
              .map(([key, value]) => (
                <View key={key} style={styles.detailRow}>
                  <Text style={styles.detailKey}>{key}:</Text>
                  <Text style={styles.detailValue} numberOfLines={3}>
                    {typeof value === 'object' ? JSON.stringify(value, null, 2) : String(value)}
                  </Text>
                </View>
              ))}
          </ScrollView>
        )}
      </Animated.View>

      {/* Progress Bar */}
      <View style={styles.progressContainer}>
        <View style={styles.progressBar}>
          <View 
            style={[
              styles.progressFill, 
              { width: `${((currentStep + 1) / algorithmResult.steps.length) * 100}%` }
            ]} 
          />
        </View>
        <Text style={styles.progressText}>
          Step {currentStep + 1} of {algorithmResult.steps.length}
        </Text>
      </View>

      {/* Controls */}
      <View style={styles.controls}>
        <TouchableOpacity
          style={[styles.controlButton, currentStep === 0 && styles.controlButtonDisabled]}
          onPress={() => {
            setIsPlaying(false);
            setCurrentStep(0);
          }}
          disabled={currentStep === 0}
        >
          <MaterialIcons name="skip-previous" size={24} color={currentStep === 0 ? '#ccc' : '#2E7D32'} />
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.controlButton, currentStep === 0 && styles.controlButtonDisabled]}
          onPress={() => {
            setIsPlaying(false);
            setCurrentStep(Math.max(0, currentStep - 1));
          }}
          disabled={currentStep === 0}
        >
          <MaterialIcons name="chevron-left" size={24} color={currentStep === 0 ? '#ccc' : '#2E7D32'} />
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.playButton, isPlaying && styles.playButtonActive]}
          onPress={() => setIsPlaying(!isPlaying)}
        >
          <MaterialIcons 
            name={isPlaying ? "pause" : "play-arrow"} 
            size={32} 
            color="#fff" 
          />
        </TouchableOpacity>

        <TouchableOpacity
          style={[
            styles.controlButton,
            currentStep >= algorithmResult.steps.length - 1 && styles.controlButtonDisabled
          ]}
          onPress={() => {
            setIsPlaying(false);
            setCurrentStep(Math.min(algorithmResult.steps.length - 1, currentStep + 1));
          }}
          disabled={currentStep >= algorithmResult.steps.length - 1}
        >
          <MaterialIcons 
            name="chevron-right" 
            size={24} 
            color={currentStep >= algorithmResult.steps.length - 1 ? '#ccc' : '#2E7D32'} 
          />
        </TouchableOpacity>

        <TouchableOpacity
          style={[
            styles.controlButton,
            currentStep >= algorithmResult.steps.length - 1 && styles.controlButtonDisabled
          ]}
          onPress={() => {
            setIsPlaying(false);
            setCurrentStep(algorithmResult.steps.length - 1);
          }}
          disabled={currentStep >= algorithmResult.steps.length - 1}
        >
          <MaterialIcons 
            name="skip-next" 
            size={24} 
            color={currentStep >= algorithmResult.steps.length - 1 ? '#ccc' : '#2E7D32'} 
          />
        </TouchableOpacity>
      </View>

      {/* Educational Info */}
      <View style={styles.infoBox}>
        <MaterialIcons name="school" size={20} color="#2E7D32" />
        <Text style={styles.infoText}>
          {getAlgorithmInfo(algorithm)}
        </Text>
      </View>
    </View>
  );
};

const getAlgorithmInfo = (algorithm) => {
  switch (algorithm) {
    case 'Binary Search':
      return 'Binary Search divides the sorted array in half repeatedly, comparing the target with the middle element. Much faster than linear search for large datasets.';
    case 'Quick Sort':
      return 'Quick Sort selects a pivot and partitions the array around it, recursively sorting sub-arrays. One of the fastest sorting algorithms in practice.';
    case 'BFS':
      return 'Breadth-First Search explores all neighbors at the current depth before moving deeper. Guarantees shortest path in unweighted graphs.';
    case 'DFS':
      return 'Depth-First Search explores as far as possible along each branch before backtracking. Uses less memory than BFS.';
    case 'Dijkstra':
      return 'Dijkstra\'s algorithm finds the shortest path from a source to all vertices in a weighted graph. Always chooses the closest unvisited vertex.';
    default:
      return 'This algorithm demonstrates computer science concepts applied to real-world problem solving.';
  }
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#fff',
    borderRadius: 16,
    padding: 20,
    margin: 16,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1a1a1a',
    marginBottom: 4,
  },
  complexity: {
    fontSize: 14,
    color: '#666',
  },
  complexityValue: {
    fontFamily: 'monospace',
    fontWeight: 'bold',
    color: '#2E7D32',
  },
  stats: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 20,
  },
  stat: {
    alignItems: 'center',
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    marginBottom: 4,
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2E7D32',
  },
  stepContainer: {
    backgroundColor: '#f9f9f9',
    borderRadius: 12,
    padding: 16,
    marginBottom: 20,
  },
  stepHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  stepIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  stepInfo: {
    flex: 1,
  },
  stepType: {
    fontSize: 12,
    fontWeight: '600',
    color: '#666',
    marginBottom: 4,
  },
  stepMessage: {
    fontSize: 16,
    color: '#1a1a1a',
    lineHeight: 22,
  },
  stepDetails: {
    marginTop: 16,
    maxHeight: 150,
  },
  detailRow: {
    flexDirection: 'row',
    paddingVertical: 6,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  detailKey: {
    fontSize: 13,
    fontWeight: '600',
    color: '#666',
    width: 120,
  },
  detailValue: {
    flex: 1,
    fontSize: 13,
    color: '#1a1a1a',
    fontFamily: 'monospace',
  },
  progressContainer: {
    marginBottom: 20,
  },
  progressBar: {
    height: 8,
    backgroundColor: '#e0e0e0',
    borderRadius: 4,
    overflow: 'hidden',
    marginBottom: 8,
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#2E7D32',
  },
  progressText: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
  },
  controls: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 12,
    marginBottom: 20,
  },
  controlButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: '#E8F5E9',
    alignItems: 'center',
    justifyContent: 'center',
  },
  controlButtonDisabled: {
    backgroundColor: '#f5f5f5',
  },
  playButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#2E7D32',
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  playButtonActive: {
    backgroundColor: '#FF9800',
  },
  infoBox: {
    flexDirection: 'row',
    backgroundColor: '#E8F5E9',
    borderRadius: 12,
    padding: 16,
    gap: 12,
  },
  infoText: {
    flex: 1,
    fontSize: 13,
    color: '#1a1a1a',
    lineHeight: 20,
  },
  emptyState: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 40,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#666',
    marginTop: 16,
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
  },
});

export default AlgorithmVisualizer;
