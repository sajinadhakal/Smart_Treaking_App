/**
 * Quick Sort Algorithm Implementation
 * Average Time Complexity: O(n log n)
 * Worst Case: O(n²)
 * Space Complexity: O(log n)
 * Use Case: Sorting trips by price, duration, rating, popularity
 */

export class QuickSortAlgorithm {
  constructor() {
    this.steps = [];
    this.swaps = 0;
    this.comparisons = 0;
  }

  sort(array, key = 'price', order = 'asc') {
    this.steps = [];
    this.swaps = 0;
    this.comparisons = 0;

    const arr = [...array];
    
    this.steps.push({
      type: 'start',
      message: `Starting Quick Sort on ${key} (${order})`,
      array: [...arr]
    });

    this.quickSort(arr, 0, arr.length - 1, key, order);

    this.steps.push({
      type: 'complete',
      message: 'Sorting complete!',
      array: [...arr],
      comparisons: this.comparisons,
      swaps: this.swaps
    });

    return {
      sorted: arr,
      steps: this.steps,
      comparisons: this.comparisons,
      swaps: this.swaps,
      complexity: 'O(n log n) average'
    };
  }

  quickSort(arr, low, high, key, order) {
    if (low < high) {
      const pi = this.partition(arr, low, high, key, order);
      
      this.steps.push({
        type: 'partition',
        message: `Partitioned at index ${pi}`,
        pivotIndex: pi,
        pivotValue: arr[pi][key],
        low,
        high
      });

      this.quickSort(arr, low, pi - 1, key, order);
      this.quickSort(arr, pi + 1, high, key, order);
    }
  }

  partition(arr, low, high, key, order) {
    const pivot = arr[high][key];
    let i = low - 1;

    this.steps.push({
      type: 'select-pivot',
      message: `Selected pivot: ${pivot} at index ${high}`,
      pivotIndex: high,
      pivotValue: pivot
    });

    for (let j = low; j < high; j++) {
      this.comparisons++;
      
      const shouldSwap = order === 'asc' 
        ? arr[j][key] < pivot 
        : arr[j][key] > pivot;

      if (shouldSwap) {
        i++;
        [arr[i], arr[j]] = [arr[j], arr[i]];
        this.swaps++;

        this.steps.push({
          type: 'swap',
          message: `Swapped elements at indices ${i} and ${j}`,
          index1: i,
          index2: j,
          value1: arr[i][key],
          value2: arr[j][key]
        });
      }
    }

    [arr[i + 1], arr[high]] = [arr[high], arr[i + 1]];
    this.swaps++;

    return i + 1;
  }

  // Alternative: Merge Sort implementation
  mergeSort(array, key = 'price', order = 'asc') {
    if (array.length <= 1) return array;

    const mid = Math.floor(array.length / 2);
    const left = this.mergeSort(array.slice(0, mid), key, order);
    const right = this.mergeSort(array.slice(mid), key, order);

    return this.merge(left, right, key, order);
  }

  merge(left, right, key, order) {
    const result = [];
    let i = 0, j = 0;

    while (i < left.length && j < right.length) {
      this.comparisons++;
      const shouldTakeLeft = order === 'asc'
        ? left[i][key] <= right[j][key]
        : left[i][key] >= right[j][key];

      if (shouldTakeLeft) {
        result.push(left[i++]);
      } else {
        result.push(right[j++]);
      }
    }

    return result.concat(left.slice(i)).concat(right.slice(j));
  }
}

export default QuickSortAlgorithm;
