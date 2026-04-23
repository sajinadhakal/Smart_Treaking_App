/**
 * Binary Search Algorithm Implementation
 * Time Complexity: O(log n)
 * Space Complexity: O(1)
 * Use Case: Searching trips by ID in sorted array
 */

export class BinarySearchAlgorithm {
  constructor() {
    this.steps = [];
    this.comparisons = 0;
  }

  search(array, target, key = 'id') {
    this.steps = [];
    this.comparisons = 0;
    
    // Sort array first (binary search requires sorted data)
    const sortedArray = [...array].sort((a, b) => {
      if (a[key] < b[key]) return -1;
      if (a[key] > b[key]) return 1;
      return 0;
    });

    let left = 0;
    let right = sortedArray.length - 1;
    
    this.steps.push({
      type: 'start',
      message: `Searching for ${key}: ${target} in sorted array`,
      left,
      right,
      mid: null
    });

    while (left <= right) {
      const mid = Math.floor((left + right) / 2);
      this.comparisons++;

      this.steps.push({
        type: 'compare',
        message: `Comparing middle element at index ${mid}`,
        left,
        right,
        mid,
        value: sortedArray[mid][key]
      });

      if (sortedArray[mid][key] === target) {
        this.steps.push({
          type: 'found',
          message: `Found! Element at index ${mid}`,
          result: sortedArray[mid]
        });
        return {
          found: true,
          result: sortedArray[mid],
          steps: this.steps,
          comparisons: this.comparisons,
          complexity: 'O(log n)'
        };
      }

      if (sortedArray[mid][key] < target) {
        this.steps.push({
          type: 'move',
          message: `Target is greater. Moving left boundary to ${mid + 1}`,
          left: mid + 1,
          right
        });
        left = mid + 1;
      } else {
        this.steps.push({
          type: 'move',
          message: `Target is smaller. Moving right boundary to ${mid - 1}`,
          left,
          right: mid - 1
        });
        right = mid - 1;
      }
    }

    this.steps.push({
      type: 'not-found',
      message: 'Element not found in array'
    });

    return {
      found: false,
      result: null,
      steps: this.steps,
      comparisons: this.comparisons,
      complexity: 'O(log n)'
    };
  }

  // Educational: Compare with Linear Search
  linearSearchComparison(array, target, key = 'id') {
    let comparisons = 0;
    for (let i = 0; i < array.length; i++) {
      comparisons++;
      if (array[i][key] === target) {
        return {
          found: true,
          comparisons,
          complexity: 'O(n)',
          message: `Linear Search: ${comparisons} comparisons`
        };
      }
    }
    return {
      found: false,
      comparisons,
      complexity: 'O(n)',
      message: `Linear Search: ${comparisons} comparisons`
    };
  }
}

export default BinarySearchAlgorithm;
