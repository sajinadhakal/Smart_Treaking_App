/**
 * Greedy Algorithm for Budget-Based Trip Selection
 * Time Complexity: O(n log n)
 * Use Case: Maximize trips within user budget
 */

export class GreedyAlgorithm {
  constructor() {
    this.steps = [];
  }

  /**
   * Select maximum trips within budget using greedy approach
   * Strategy: Sort by price, select cheapest trips first
   */
  maxTripsInBudget(trips, budget) {
    this.steps = [];
    
    this.steps.push({
      type: 'start',
      message: `Finding maximum trips within budget: NPR ${budget}`,
      budget,
      totalTrips: trips.length
    });

    // Sort trips by price (greedy choice)
    const sortedTrips = [...trips].sort((a, b) => a.price - b.price);
    
    this.steps.push({
      type: 'sort',
      message: 'Sorted trips by price (greedy strategy)',
      sortedPrices: sortedTrips.map(t => ({ title: t.title, price: t.price }))
    });

    const selectedTrips = [];
    let remainingBudget = budget;
    let totalValue = 0;

    for (const trip of sortedTrips) {
      if (trip.price <= remainingBudget) {
        selectedTrips.push(trip);
        remainingBudget -= trip.price;
        totalValue += trip.rating * 100; // Value metric

        this.steps.push({
          type: 'select',
          message: `Selected: ${trip.title} (NPR ${trip.price})`,
          trip: { title: trip.title, price: trip.price },
          remainingBudget,
          selectedCount: selectedTrips.length
        });
      } else {
        this.steps.push({
          type: 'skip',
          message: `Skipped: ${trip.title} (NPR ${trip.price} > remaining NPR ${remainingBudget})`,
          trip: { title: trip.title, price: trip.price }
        });
      }
    }

    this.steps.push({
      type: 'complete',
      message: `Selected ${selectedTrips.length} trips, spent NPR ${budget - remainingBudget}`,
      selectedTrips: selectedTrips.map(t => ({ title: t.title, price: t.price })),
      totalSpent: budget - remainingBudget,
      remainingBudget
    });

    return {
      selectedTrips,
      totalSpent: budget - remainingBudget,
      remainingBudget,
      tripCount: selectedTrips.length,
      steps: this.steps,
      complexity: 'O(n log n)'
    };
  }

  /**
   * Fractional Knapsack for optimal trip selection
   * Based on value-to-weight ratio (rating/price)
   */
  optimalTripSelection(trips, budget, maxDays) {
    this.steps = [];

    this.steps.push({
      type: 'start',
      message: `Optimizing trip selection: Budget NPR ${budget}, Max ${maxDays} days`,
      budget,
      maxDays
    });

    // Calculate value-to-cost ratio
    const tripsWithRatio = trips.map(trip => ({
      ...trip,
      ratio: (trip.rating * 100) / trip.price,
      efficiency: trip.rating / trip.duration
    }));

    // Sort by ratio (greedy choice)
    const sortedTrips = tripsWithRatio.sort((a, b) => b.ratio - a.ratio);

    this.steps.push({
      type: 'calculate',
      message: 'Calculated value-to-cost ratio for each trip',
      ratios: sortedTrips.map(t => ({
        title: t.title,
        ratio: t.ratio.toFixed(2),
        rating: t.rating,
        price: t.price
      }))
    });

    const selectedTrips = [];
    let remainingBudget = budget;
    let remainingDays = maxDays;

    for (const trip of sortedTrips) {
      if (trip.price <= remainingBudget && trip.duration <= remainingDays) {
        selectedTrips.push(trip);
        remainingBudget -= trip.price;
        remainingDays -= trip.duration;

        this.steps.push({
          type: 'select',
          message: `Selected: ${trip.title} (Ratio: ${trip.ratio.toFixed(2)})`,
          trip: {
            title: trip.title,
            price: trip.price,
            duration: trip.duration,
            ratio: trip.ratio.toFixed(2)
          },
          remainingBudget,
          remainingDays
        });
      }
    }

    const totalValue = selectedTrips.reduce((sum, trip) => sum + (trip.rating * 100), 0);

    this.steps.push({
      type: 'complete',
      message: `Optimal selection complete`,
      selectedTrips: selectedTrips.map(t => ({ title: t.title, price: t.price })),
      totalValue,
      totalSpent: budget - remainingBudget,
      totalDays: maxDays - remainingDays
    });

    return {
      selectedTrips,
      totalValue,
      totalSpent: budget - remainingBudget,
      totalDays: maxDays - remainingDays,
      remainingBudget,
      remainingDays,
      steps: this.steps,
      complexity: 'O(n log n)'
    };
  }
}

export default GreedyAlgorithm;
