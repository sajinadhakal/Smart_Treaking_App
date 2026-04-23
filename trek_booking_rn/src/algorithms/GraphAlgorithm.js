/**
 * Graph Algorithm Implementation for Trek Routes
 * Includes BFS, DFS, and Dijkstra's Algorithm
 * Use Case: Route exploration, finding shortest trek paths
 */

export class GraphAlgorithm {
  constructor() {
    this.steps = [];
    this.visitedNodes = [];
  }

  // Build graph from trip coordinates
  buildGraph(trips) {
    const graph = {};
    const nodes = new Set();

    // Extract all unique locations
    trips.forEach(trip => {
      trip.coordinates.forEach(coord => {
        nodes.add(coord.name);
      });
    });

    // Initialize adjacency list
    nodes.forEach(node => {
      graph[node] = [];
    });

    // Create edges based on sequential coordinates in each trip
    trips.forEach(trip => {
      for (let i = 0; i < trip.coordinates.length - 1; i++) {
        const from = trip.coordinates[i].name;
        const to = trip.coordinates[i + 1].name;
        const distance = this.calculateDistance(
          trip.coordinates[i],
          trip.coordinates[i + 1]
        );

        // Add bidirectional edges
        if (!graph[from].find(e => e.to === to)) {
          graph[from].push({ to, distance: Math.round(distance) });
        }
        if (!graph[to].find(e => e.to === from)) {
          graph[to].push({ to: from, distance: Math.round(distance) });
        }
      }
    });

    return graph;
  }

  // Haversine formula for distance calculation
  calculateDistance(coord1, coord2) {
    const R = 6371; // Earth's radius in km
    const dLat = this.toRad(coord2.lat - coord1.lat);
    const dLon = this.toRad(coord2.lng - coord1.lng);
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRad(coord1.lat)) * 
              Math.cos(this.toRad(coord2.lat)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  toRad(degrees) {
    return degrees * (Math.PI / 180);
  }

  /**
   * Breadth-First Search (BFS)
   * Time Complexity: O(V + E)
   */
  bfs(graph, start, end) {
    this.steps = [];
    this.visitedNodes = [];
    
    const queue = [{ node: start, path: [start] }];
    const visited = new Set([start]);

    this.steps.push({
      type: 'start',
      message: `Starting BFS from ${start} to ${end}`,
      current: start,
      queue: [start]
    });

    while (queue.length > 0) {
      const { node, path } = queue.shift();
      this.visitedNodes.push(node);

      this.steps.push({
        type: 'visit',
        message: `Visiting node: ${node}`,
        current: node,
        path: [...path],
        queue: queue.map(q => q.node)
      });

      if (node === end) {
        this.steps.push({
          type: 'found',
          message: `Destination ${end} found!`,
          path,
          totalNodes: this.visitedNodes.length
        });

        return {
          found: true,
          path,
          steps: this.steps,
          visitedCount: this.visitedNodes.length,
          complexity: 'O(V + E)'
        };
      }

      if (graph[node]) {
        graph[node].forEach(neighbor => {
          if (!visited.has(neighbor.to)) {
            visited.add(neighbor.to);
            queue.push({
              node: neighbor.to,
              path: [...path, neighbor.to]
            });

            this.steps.push({
              type: 'enqueue',
              message: `Added ${neighbor.to} to queue`,
              neighbor: neighbor.to,
              queue: queue.map(q => q.node)
            });
          }
        });
      }
    }

    return {
      found: false,
      path: null,
      steps: this.steps,
      visitedCount: this.visitedNodes.length,
      complexity: 'O(V + E)'
    };
  }

  /**
   * Depth-First Search (DFS)
   * Time Complexity: O(V + E)
   */
  dfs(graph, start, end, visited = new Set(), path = []) {
    if (this.steps.length === 0) {
      this.steps = [];
      this.visitedNodes = [];
      this.steps.push({
        type: 'start',
        message: `Starting DFS from ${start} to ${end}`,
        current: start
      });
    }

    visited.add(start);
    path.push(start);
    this.visitedNodes.push(start);

    this.steps.push({
      type: 'visit',
      message: `Visiting node: ${start}`,
      current: start,
      path: [...path],
      visited: Array.from(visited)
    });

    if (start === end) {
      this.steps.push({
        type: 'found',
        message: `Destination ${end} found!`,
        path,
        totalNodes: this.visitedNodes.length
      });

      return {
        found: true,
        path: [...path],
        steps: this.steps,
        visitedCount: this.visitedNodes.length,
        complexity: 'O(V + E)'
      };
    }

    if (graph[start]) {
      for (const neighbor of graph[start]) {
        if (!visited.has(neighbor.to)) {
          this.steps.push({
            type: 'explore',
            message: `Exploring neighbor: ${neighbor.to}`,
            neighbor: neighbor.to
          });

          const result = this.dfs(graph, neighbor.to, end, visited, path);
          if (result.found) {
            return result;
          }
        }
      }
    }

    path.pop();
    this.steps.push({
      type: 'backtrack',
      message: `Backtracking from ${start}`,
      current: start,
      path: [...path]
    });

    return {
      found: false,
      path: null,
      steps: this.steps,
      visitedCount: this.visitedNodes.length,
      complexity: 'O(V + E)'
    };
  }

  /**
   * Dijkstra's Shortest Path Algorithm
   * Time Complexity: O((V + E) log V)
   */
  dijkstra(graph, start, end) {
    this.steps = [];
    const distances = {};
    const previous = {};
    const unvisited = new Set();

    // Initialize
    Object.keys(graph).forEach(node => {
      distances[node] = Infinity;
      previous[node] = null;
      unvisited.add(node);
    });
    distances[start] = 0;

    this.steps.push({
      type: 'start',
      message: `Starting Dijkstra from ${start} to ${end}`,
      distances: { ...distances }
    });

    while (unvisited.size > 0) {
      // Find unvisited node with minimum distance
      let current = null;
      let minDistance = Infinity;
      
      unvisited.forEach(node => {
        if (distances[node] < minDistance) {
          minDistance = distances[node];
          current = node;
        }
      });

      if (current === null || distances[current] === Infinity) break;

      this.steps.push({
        type: 'visit',
        message: `Visiting ${current} with distance ${distances[current]}`,
        current,
        distance: distances[current],
        unvisited: Array.from(unvisited)
      });

      if (current === end) {
        // Reconstruct path
        const path = [];
        let temp = end;
        while (temp !== null) {
          path.unshift(temp);
          temp = previous[temp];
        }

        this.steps.push({
          type: 'found',
          message: `Shortest path found! Distance: ${distances[end]} km`,
          path,
          distance: distances[end]
        });

        return {
          found: true,
          path,
          distance: distances[end],
          steps: this.steps,
          complexity: 'O((V + E) log V)'
        };
      }

      unvisited.delete(current);

      // Update distances to neighbors
      if (graph[current]) {
        graph[current].forEach(neighbor => {
          if (unvisited.has(neighbor.to)) {
            const newDistance = distances[current] + neighbor.distance;
            
            if (newDistance < distances[neighbor.to]) {
              distances[neighbor.to] = newDistance;
              previous[neighbor.to] = current;

              this.steps.push({
                type: 'update',
                message: `Updated distance to ${neighbor.to}: ${newDistance} km`,
                neighbor: neighbor.to,
                newDistance,
                via: current
              });
            }
          }
        });
      }
    }

    return {
      found: false,
      path: null,
      distance: Infinity,
      steps: this.steps,
      complexity: 'O((V + E) log V)'
    };
  }
}

export default GraphAlgorithm;
