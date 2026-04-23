/**
 * Dynamic Programming Algorithm for Trip Planning Optimization
 * Time Complexity: O(n * capacity)
 * Use Case: Maximize trip experiences within time/budget constraints
 */

export class DynamicProgrammingAlgorithm {
  constructor() {
    this.steps = [];
    this.dpTable = [];
  }

  /**
   * 0/1 Knapsack for Trip Selection
   * Maximize rating value within budget constraint
   */
  knapsackTripSelection(trips, budget) {
    this.steps = [];
    this.dpTable = [];

    const n = trips.length;
    const W = Math.floor(budget);
    
    // Initialize DP table
    const dp = Array(n + 1).fill(null).map(() => Array(W + 1).fill(0));
    
    this.steps.push({
      type: 'start',
      message: `Initializing DP table: ${n} trips, budget NPR ${W}`,
      dimensions: `${n + 1} x ${W + 1}`
    });

    // Build DP table
    for (let i = 1; i <= n; i++) {
      const trip = trips[i - 1];
      const price = Math.floor(trip.price);
      const value = Math.floor(trip.rating * 100);

      for (let w = 0; w <= W; w++) {
        if (price <= w) {
          const include = value + dp[i - 1][w - price];
          const exclude = dp[i - 1][w];
          dp[i][w] = Math.max(include, exclude);

          if (include > exclude) {
            this.steps.push({
              type: 'include',
              message: `Row ${i}: Including ${trip.title} at budget ${w}`,
              trip: trip.title,
              value,
              price,
              totalValue: dp[i][w]
            });
          }
        } else {
          dp[i][w] = dp[i - 1][w];
        }
      }
    }

    this.dpTable = dp;

    // Backtrack to find selected trips
    const selectedTrips = [];
    let w = W;
    
    for (let i = n; i > 0; i--) {
      if (dp[i][w] !== dp[i - 1][w]) {
        const trip = trips[i - 1];
        selectedTrips.unshift(trip);
        w -= Math.floor(trip.price);

        this.steps.push({
          type: 'backtrack',
          message: `Selected: ${trip.title}`,
          trip: trip.title,
          remainingBudget: w
        });
      }
    }

    const totalValue = dp[n][W];
    const totalSpent = selectedTrips.reduce((sum, trip) => sum + trip.price, 0);

    this.steps.push({
      type: 'complete',
      message: `Optimal selection found`,
      selectedTrips: selectedTrips.map(t => ({ title: t.title, price: t.price })),
      totalValue,
      totalSpent,
      efficiency: ((totalValue / totalSpent) * 100).toFixed(2) + '%'
    });

    return {
      selectedTrips,
      totalValue,
      totalSpent,
      remainingBudget: budget - totalSpent,
      dpTable: dp,
      steps: this.steps,
      complexity: 'O(n * W)'
    };
  }

  /**
   * Trip Planning with Time Constraints
   * Maximize experiences within available days
   */
  maxExperienceInDays(trips, maxDays, budget) {
    this.steps = [];

    const n = trips.length;
    const D = maxDays;
    
    // DP table: dp[i][d][b] = max value using first i trips, d days, b budget
    // Simplified to 2D for demo
    const dp = Array(n + 1).fill(null).map(() => Array(D + 1).fill(0));

    this.steps.push({
      type: 'start',
      message: `Planning trips: ${maxDays} days available, Budget: NPR ${budget}`,
      trips: n,
      days: maxDays
    });

    for (let i = 1; i <= n; i++) {
      const trip = trips[i - 1];
      
      // Skip if trip exceeds budget
      if (trip.price > budget) continue;

      for (let d = 0; d <= D; d++) {
        if (trip.duration <= d) {
          const include = (trip.rating * 100) + dp[i - 1][d - trip.duration];
          const exclude = dp[i - 1][d];
          dp[i][d] = Math.max(include, exclude);

          if (include > exclude) {
            this.steps.push({
              type: 'select',
              message: `Can fit ${trip.title} in ${d} days`,
              trip: trip.title,
              duration: trip.duration,
              value: trip.rating * 100
            });
          }
        } else {
          dp[i][d] = dp[i - 1][d];
        }
      }
    }

    // Backtrack
    const selectedTrips = [];
    let d = D;
    
    for (let i = n; i > 0; i--) {
      if (dp[i][d] !== dp[i - 1][d]) {
        const trip = trips[i - 1];
        if (trip.price <= budget) {
          selectedTrips.unshift(trip);
          d -= trip.duration;
          budget -= trip.price;
        }
      }
    }

    const totalValue = dp[n][D];
    const totalDays = selectedTrips.reduce((sum, trip) => sum + trip.duration, 0);
    const totalCost = selectedTrips.reduce((sum, trip) => sum + trip.price, 0);

    this.steps.push({
      type: 'complete',
      message: `Optimal itinerary created`,
      selectedTrips: selectedTrips.map(t => ({
        title: t.title,
        duration: t.duration,
        price: t.price
      })),
      totalDays,
      totalCost,
      totalValue,
      daysRemaining: maxDays - totalDays
    });

    return {
      selectedTrips,
      totalValue,
      totalDays,
      totalCost,
      daysRemaining: maxDays - totalDays,
      budgetRemaining: budget,
      steps: this.steps,
      complexity: 'O(n * D)'
    };
  }

  /**
   * Get DP table for visualization
   */
  getDPTable() {
    return this.dpTable;
  }
}

export default DynamicProgrammingAlgorithm;
