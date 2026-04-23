import React, { useState } from 'react';
import { 
  View, Text, ScrollView, StyleSheet, TouchableOpacity 
} from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import BinarySearchAlgorithm from '../algorithms/BinarySearch';
import QuickSortAlgorithm from '../algorithms/QuickSort';
import GraphAlgorithm from '../algorithms/GraphAlgorithm';
import GreedyAlgorithm from '../algorithms/GreedyAlgorithm';
import DynamicProgrammingAlgorithm from '../algorithms/DynamicProgramming';
import AlgorithmVisualizer from '../components/AlgorithmVisualizer';
import useStore from '../store/useStore';
import { mockTrips } from '../data/mockData';

const EducationalPanelScreen = () => {
  const [activeAlgorithm, setActiveAlgorithm] = useState(null);
  const { setAlgorithmResult, algorithmResult } = useStore();

  const algorithms = [
    {
      id: 'binary-search',
      name: 'Binary Search',
      icon: 'search',
      color: '#2196F3',
      description: 'Search for trips by ID with O(log n) complexity',
      complexity: 'O(log n)',
      action: () => {
        const searcher = new BinarySearchAlgorithm();
        const result = searcher.search(mockTrips, '3', 'id');
        setAlgorithmResult(result);
        setActiveAlgorithm('binary-search');
      }
    },
    {
      id: 'quick-sort',
      name: 'Quick Sort',
      icon: 'sort',
      color: '#FF9800',
      description: 'Sort trips by price using Quick Sort algorithm',
      complexity: 'O(n log n)',
      action: () => {
        const sorter = new QuickSortAlgorithm();
        const result = sorter.sort(mockTrips, 'price', 'asc');
        setAlgorithmResult(result);
        setActiveAlgorithm('quick-sort');
      }
    },
    {
      id: 'bfs',
      name: 'Breadth-First Search',
      icon: 'account-tree',
      color: '#4CAF50',
      description: 'Find routes between locations using BFS',
      complexity: 'O(V + E)',
      action: () => {
        const graphAlgo = new GraphAlgorithm();
        const graph = graphAlgo.buildGraph(mockTrips);
        const result = graphAlgo.bfs(graph, 'Kathmandu', 'Namche');
        setAlgorithmResult(result);
        setActiveAlgorithm('bfs');
      }
    },
    {
      id: 'dfs',
      name: 'Depth-First Search',
      icon: 'device-hub',
      color: '#9C27B0',
      description: 'Explore trek routes using DFS algorithm',
      complexity: 'O(V + E)',
      action: () => {
        const graphAlgo = new GraphAlgorithm();
        const graph = graphAlgo.buildGraph(mockTrips);
        const result = graphAlgo.dfs(graph, 'Kathmandu', 'Namche');
        setAlgorithmResult(result);
        setActiveAlgorithm('dfs');
      }
    },
    {
      id: 'dijkstra',
      name: 'Dijkstra\'s Algorithm',
      icon: 'route',
      color: '#F44336',
      description: 'Find shortest path between trek locations',
      complexity: 'O((V + E) log V)',
      action: () => {
        const graphAlgo = new GraphAlgorithm();
        const graph = graphAlgo.buildGraph(mockTrips);
        const result = graphAlgo.dijkstra(graph, 'Kathmandu', 'EBC');
        setAlgorithmResult(result);
        setActiveAlgorithm('dijkstra');
      }
    },
    {
      id: 'greedy',
      name: 'Greedy Algorithm',
      icon: 'trending-up',
      color: '#00BCD4',
      description: 'Select maximum treks within budget',
      complexity: 'O(n log n)',
      action: () => {
        const greedy = new GreedyAlgorithm();
        const result = greedy.maxTripsInBudget(mockTrips, 3000);
        setAlgorithmResult(result);
        setActiveAlgorithm('greedy');
      }
    },
    {
      id: 'dp',
      name: 'Dynamic Programming',
      icon: 'memory',
      color: '#3F51B5',
      description: 'Optimize trip selection using 0/1 Knapsack',
      complexity: 'O(n * W)',
      action: () => {
        const dp = new DynamicProgrammingAlgorithm();
        const result = dp.knapsackTripSelection(mockTrips, 3000);
        setAlgorithmResult(result);
        setActiveAlgorithm('dp');
      }
    },
  ];

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      {/* Header */}
      <View style={styles.header}>
        <MaterialIcons name="school" size={48} color="#2E7D32" />
        <Text style={styles.headerTitle}>Educational Panel</Text>
        <Text style={styles.headerSubtitle}>
          Learn computer science algorithms through real-world applications
        </Text>
      </View>

      {/* Info Banner */}
      <View style={styles.infoBanner}>
        <MaterialIcons name="info" size={24} color="#2196F3" />
        <Text style={styles.infoText}>
          Tap on any algorithm to see step-by-step visualization and complexity analysis
        </Text>
      </View>

      {/* Algorithm Cards */}
      <View style={styles.algorithmsContainer}>
        {algorithms.map(algo => (
          <TouchableOpacity
            key={algo.id}
            style={[
              styles.algoCard,
              activeAlgorithm === algo.id && styles.algoCardActive
            ]}
            onPress={algo.action}
            activeOpacity={0.9}
          >
            <View style={[styles.algoIcon, { backgroundColor: algo.color + '20' }]}>
              <MaterialIcons name={algo.icon} size={32} color={algo.color} />
            </View>
            
            <View style={styles.algoContent}>
              <Text style={styles.algoName}>{algo.name}</Text>
              <Text style={styles.algoDescription}>{algo.description}</Text>
              
              <View style={styles.algoFooter}>
                <View style={[styles.complexityBadge, { backgroundColor: algo.color + '20' }]}>
                  <Text style={[styles.complexityText, { color: algo.color }]}>
                    {algo.complexity}
                  </Text>
                </View>
                
                <MaterialIcons name="play-circle-filled" size={24} color={algo.color} />
              </View>
            </View>
          </TouchableOpacity>
        ))}
      </View>

      {/* Visualizer */}
      {algorithmResult && activeAlgorithm && (
        <View style={styles.visualizerContainer}>
          <AlgorithmVisualizer
            algorithmResult={algorithmResult}
            algorithm={algorithms.find(a => a.id === activeAlgorithm)?.name}
          />
        </View>
      )}

      {/* Learning Resources */}
      <View style={styles.resourcesSection}>
        <Text style={styles.sectionTitle}>Learning Resources</Text>
        
        <View style={styles.resourceCard}>
          <MaterialIcons name="lightbulb" size={24} color="#FFD700" />
          <View style={styles.resourceContent}>
            <Text style={styles.resourceTitle}>Understanding Time Complexity</Text>
            <Text style={styles.resourceText}>
              O(log n) is much faster than O(n) for large datasets. Binary search is logarithmic!
            </Text>
          </View>
        </View>

        <View style={styles.resourceCard}>
          <MaterialIcons name="timeline" size={24} color="#4CAF50" />
          <View style={styles.resourceContent}>
            <Text style={styles.resourceTitle}>Graph Algorithms</Text>
            <Text style={styles.resourceText}>
              BFS and DFS explore graphs differently. BFS uses queue, DFS uses stack (recursion).
            </Text>
          </View>
        </View>

        <View style={styles.resourceCard}>
          <MaterialIcons name="analytics" size={24} color="#FF9800" />
          <View style={styles.resourceContent}>
            <Text style={styles.resourceTitle}>Optimization Algorithms</Text>
            <Text style={styles.resourceText}>
              Greedy makes local optimal choices. DP finds global optimal solution.
            </Text>
          </View>
        </View>
      </View>

      {/* Academic Note */}
      <View style={styles.academicNote}>
        <Text style={styles.academicTitle}>For TU BCA Project</Text>
        <Text style={styles.academicText}>
          This application demonstrates practical implementation of Data Structures & Algorithms 
          in a real-world travel booking system. Each algorithm solves a specific problem:
        </Text>
        <View style={styles.bulletList}>
          <Text style={styles.bullet}>• Binary Search: Fast trip lookup</Text>
          <Text style={styles.bullet}>• Quick Sort: Efficient trip ordering</Text>
          <Text style={styles.bullet}>• Graph Algorithms: Route finding</Text>
          <Text style={styles.bullet}>• Greedy: Budget optimization</Text>
          <Text style={styles.bullet}>• DP: Trip planning optimization</Text>
        </View>
      </View>

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
    backgroundColor: '#fff',
    padding: 24,
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1a1a1a',
    marginTop: 16,
    marginBottom: 8,
  },
  headerSubtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    lineHeight: 22,
  },
  infoBanner: {
    flexDirection: 'row',
    backgroundColor: '#E3F2FD',
    padding: 16,
    margin: 16,
    borderRadius: 12,
    gap: 12,
  },
  infoText: {
    flex: 1,
    fontSize: 14,
    color: '#1565C0',
    lineHeight: 20,
  },
  algorithmsContainer: {
    padding: 16,
  },
  algoCard: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  algoCardActive: {
    elevation: 8,
    shadowOpacity: 0.2,
    shadowRadius: 8,
    borderWidth: 2,
    borderColor: '#2E7D32',
  },
  algoIcon: {
    width: 64,
    height: 64,
    borderRadius: 32,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 16,
  },
  algoContent: {
    flex: 1,
  },
  algoName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1a1a1a',
    marginBottom: 6,
  },
  algoDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
    marginBottom: 12,
  },
  algoFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  complexityBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 12,
  },
  complexityText: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: 'monospace',
  },
  visualizerContainer: {
    marginBottom: 16,
  },
  resourcesSection: {
    padding: 16,
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#1a1a1a',
    marginBottom: 16,
  },
  resourceCard: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    gap: 16,
  },
  resourceContent: {
    flex: 1,
  },
  resourceTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1a1a1a',
    marginBottom: 6,
  },
  resourceText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  academicNote: {
    backgroundColor: '#E8F5E9',
    padding: 20,
    margin: 16,
    borderRadius: 16,
    borderLeftWidth: 4,
    borderLeftColor: '#2E7D32',
  },
  academicTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1E3A2C',
    marginBottom: 12,
  },
  academicText: {
    fontSize: 14,
    color: '#1a1a1a',
    lineHeight: 22,
    marginBottom: 12,
  },
  bulletList: {
    gap: 6,
  },
  bullet: {
    fontSize: 14,
    color: '#1a1a1a',
    lineHeight: 20,
  },
  bottomPadding: {
    height: 32,
  },
});

export default EducationalPanelScreen;
