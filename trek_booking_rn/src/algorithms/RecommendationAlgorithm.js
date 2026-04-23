/**
 * Recommendation Engine using Rule-Based Filtering
 * Simple AI-like system for trip recommendations
 */

export class RecommendationAlgorithm {
  constructor() {
    this.steps = [];
  }

  /**
   * Rule-based recommendation system
   * Factors: Budget, Days, Difficulty, Season, Preferences
   */
  recommendTrips(trips, userProfile) {
    this.steps = [];
    const { budget, daysAvailable, difficulty, season, preferences } = userProfile;

    this.steps.push({
      type: 'start',
      message: 'Starting recommendation engine',
      userProfile
    });

    let scores = trips.map(trip => ({
      trip,
      score: 0,
      reasons: []
    }));

    // Rule 1: Budget constraint (mandatory)
    scores = scores.filter(item => {
      const withinBudget = item.trip.price <= budget;
      if (!withinBudget) {
        this.steps.push({
          type: 'filter',
          message: `Filtered out: ${item.trip.title} (price exceeds budget)`,
          trip: item.trip.title
        });
      }
      return withinBudget;
    });

    // Rule 2: Duration constraint (mandatory)
    scores = scores.filter(item => {
      const withinTime = item.trip.duration <= daysAvailable;
      if (!withinTime) {
        this.steps.push({
          type: 'filter',
          message: `Filtered out: ${item.trip.title} (duration exceeds available days)`,
          trip: item.trip.title
        });
      }
      return withinTime;
    });

    // Rule 3: Difficulty match (+30 points)
    scores.forEach(item => {
      if (item.trip.difficulty === difficulty) {
        item.score += 30;
        item.reasons.push('Matches your fitness level');
        this.steps.push({
          type: 'score',
          message: `+30 points: ${item.trip.title} matches difficulty`,
          trip: item.trip.title,
          currentScore: item.score
        });
      }
    });

    // Rule 4: Season match (+20 points)
    scores.forEach(item => {
      if (item.trip.season.includes(season)) {
        item.score += 20;
        item.reasons.push(`Best season for this trek`);
        this.steps.push({
          type: 'score',
          message: `+20 points: ${item.trip.title} matches season`,
          trip: item.trip.title,
          currentScore: item.score
        });
      }
    });

    // Rule 5: Rating boost (+rating * 5 points)
    scores.forEach(item => {
      const ratingPoints = Math.floor(item.trip.rating * 5);
      item.score += ratingPoints;
      item.reasons.push(`High rating (${item.trip.rating}/5)`);
      this.steps.push({
        type: 'score',
        message: `+${ratingPoints} points: ${item.trip.title} rating bonus`,
        trip: item.trip.title,
        currentScore: item.score
      });
    });

    // Rule 6: Popularity factor (+popularity/2 points)
    scores.forEach(item => {
      const popPoints = Math.floor(item.trip.popularityScore / 2);
      item.score += popPoints;
      item.reasons.push('Popular destination');
      this.steps.push({
        type: 'score',
        message: `+${popPoints} points: ${item.trip.title} popularity`,
        trip: item.trip.title,
        currentScore: item.score
      });
    });

    // Rule 7: Category preference (+25 points)
    if (preferences && preferences.category) {
      scores.forEach(item => {
        if (item.trip.category === preferences.category) {
          item.score += 25;
          item.reasons.push(`Matches ${preferences.category} preference`);
          this.steps.push({
            type: 'score',
            message: `+25 points: ${item.trip.title} matches category preference`,
            trip: item.trip.title,
            currentScore: item.score
          });
        }
      });
    }

    // Rule 8: Region preference (+15 points)
    if (preferences && preferences.region) {
      scores.forEach(item => {
        if (item.trip.region === preferences.region) {
          item.score += 15;
          item.reasons.push(`In your preferred region`);
          this.steps.push({
            type: 'score',
            message: `+15 points: ${item.trip.title} in preferred region`,
            trip: item.trip.title,
            currentScore: item.score
          });
        }
      });
    }

    // Sort by score
    scores.sort((a, b) => b.score - a.score);

    this.steps.push({
      type: 'complete',
      message: `Recommendations generated`,
      topRecommendations: scores.slice(0, 5).map(s => ({
        title: s.trip.title,
        score: s.score,
        reasons: s.reasons
      }))
    });

    return {
      recommendations: scores,
      steps: this.steps,
      algorithm: 'Rule-based scoring system',
      totalCandidates: scores.length
    };
  }

  /**
   * Content-based filtering
   * Recommend similar trips based on user's liked trips
   */
  similarTrips(trip, allTrips, topN = 5) {
    this.steps = [];

    this.steps.push({
      type: 'start',
      message: `Finding trips similar to: ${trip.title}`,
      referenceTrip: trip.title
    });

    const similarities = allTrips
      .filter(t => t.id !== trip.id)
      .map(t => {
        let score = 0;
        const reasons = [];

        // Same region (+30)
        if (t.region === trip.region) {
          score += 30;
          reasons.push('Same region');
        }

        // Same difficulty (+25)
        if (t.difficulty === trip.difficulty) {
          score += 25;
          reasons.push('Same difficulty level');
        }

        // Similar duration (+20 if within 3 days)
        if (Math.abs(t.duration - trip.duration) <= 3) {
          score += 20;
          reasons.push('Similar duration');
        }

        // Similar price (+15 if within 300)
        if (Math.abs(t.price - trip.price) <= 300) {
          score += 15;
          reasons.push('Similar price range');
        }

        // Same category (+20)
        if (t.category === trip.category) {
          score += 20;
          reasons.push('Same category');
        }

        return { trip: t, score, reasons };
      })
      .sort((a, b) => b.score - a.score)
      .slice(0, topN);

    this.steps.push({
      type: 'complete',
      message: `Found ${similarities.length} similar trips`,
      recommendations: similarities.map(s => ({
        title: s.trip.title,
        score: s.score,
        reasons: s.reasons
      }))
    });

    return {
      similarTrips: similarities,
      steps: this.steps,
      algorithm: 'Content-based filtering'
    };
  }
}

export default RecommendationAlgorithm;
