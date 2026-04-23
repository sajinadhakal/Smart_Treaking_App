"""
Recommendation Engine Service

Implements rule-based and content filtering recommendations.
For TU BCA 6th Semester - Data Structures & Algorithms
"""

import time
from typing import List, Dict, Any


class RecommendationService:
    """Service class for recommendation algorithms"""
    
    @staticmethod
    def rule_based_recommendations(
        destinations: List[Dict],
        user_preferences: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Rule-Based Recommendation System
        Uses scoring based on multiple rules
        
        Time Complexity: O(n)
        Space Complexity: O(n)
        
        Args:
            destinations: List of all destinations
            user_preferences: User preferences dict with keys:
                - budget: float
                - max_days: int
                - difficulty: str
                - preferred_season: str
                - min_rating: float
        
        Returns:
            Dictionary with recommended trips and scores
        """
        start_time = time.time()
        steps = []
        scored_destinations = []
        
        budget = float(user_preferences.get('budget', 999999))
        max_days = int(user_preferences.get('max_days', 30))
        difficulty = user_preferences.get('difficulty', '').upper()
        season = user_preferences.get('preferred_season', '')
        min_rating = float(user_preferences.get('min_rating', 0))
        
        steps.append({
            'step': 1,
            'action': 'initialize',
            'preferences': user_preferences,
            'total_destinations': len(destinations)
        })
        
        for dest in destinations:
            score = 0
            reasons = []
            
            # Rule 1: Budget filter (hard constraint)
            price = float(dest.get('price', 0))
            if price > budget:
                continue
            
            # Rule 2: Days filter (hard constraint)
            days = int(dest.get('duration_days', 1))
            if days > max_days:
                continue
            
            # Rule 3: Minimum rating filter
            rating = float(dest.get('average_rating', 0))
            if rating < min_rating:
                continue
            
            # Rule 4: Difficulty match (+30 points)
            if difficulty and dest.get('difficulty', '').upper() == difficulty:
                score += 30
                reasons.append('Matches difficulty preference')
            
            # Rule 5: Season match (+20 points)
            if season and season.lower() in dest.get('best_season', '').lower():
                score += 20
                reasons.append('Best season match')
            
            # Rule 6: Rating bonus (0-25 points)
            rating_score = int((rating / 5.0) * 25)
            score += rating_score
            reasons.append(f'High rating ({rating}/5)')
            
            # Rule 7: Featured destination (+15 points)
            if dest.get('featured', False):
                score += 15
                reasons.append('Featured destination')
            
            # Rule 8: Budget efficiency (+0-20 points)
            budget_ratio = price / budget
            if budget_ratio < 0.5:
                efficiency_score = int((1 - budget_ratio) * 20)
                score += efficiency_score
                reasons.append('Budget-friendly')
            
            # Rule 9: Duration match (+10 points if close to max_days)
            if abs(days - max_days) <= 2:
                score += 10
                reasons.append('Duration fits perfectly')
            
            scored_destinations.append({
                'destination': dest,
                'score': score,
                'reasons': reasons,
                'price': price,
                'days': days,
                'rating': rating
            })
            
            steps.append({
                'step': len(steps) + 1,
                'action': 'score',
                'destination': dest.get('name'),
                'score': score,
                'reasons': reasons
            })
        
        # Sort by score descending
        scored_destinations.sort(key=lambda x: x['score'], reverse=True)
        
        # Take top recommendations
        top_recommendations = scored_destinations[:10]
        
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': 'Rule-Based Recommendation System',
            'user_preferences': user_preferences,
            'total_candidates': len(scored_destinations),
            'recommendations': [
                {
                    **item['destination'],
                    'recommendation_score': item['score'],
                    'reasons': item['reasons']
                }
                for item in top_recommendations
            ],
            'steps': steps[:30],
            'scoring_rules': {
                'difficulty_match': 30,
                'season_match': 20,
                'rating_bonus': '0-25',
                'featured_bonus': 15,
                'budget_efficiency': '0-20',
                'duration_match': 10
            },
            'time_complexity': 'O(n)',
            'space_complexity': 'O(n)',
            'execution_time_ms': round(execution_time, 4),
            'description': 'Scores destinations based on multiple preference rules',
            'pseudocode': [
                'for each destination:',
                '    score = 0',
                '    if price > budget: skip',
                '    if days > max_days: skip',
                '    if rating < min_rating: skip',
                '    ',
                '    if difficulty matches: score += 30',
                '    if season matches: score += 20',
                '    score += rating_score (0-25)',
                '    if featured: score += 15',
                '    if budget_friendly: score += 0-20',
                '    if duration_perfect: score += 10',
                '    ',
                '    add to candidates',
                'sort by score (descending)',
                'return top N recommendations'
            ]
        }
    
    @staticmethod
    def content_based_filtering(
        destinations: List[Dict],
        liked_destination_id: int
    ) -> Dict[str, Any]:
        """
        Content-Based Filtering
        Find similar destinations based on attributes
        
        Time Complexity: O(n)
        Space Complexity: O(n)
        
        Args:
            destinations: List of all destinations
            liked_destination_id: ID of destination user liked
        
        Returns:
            Dictionary with similar destinations
        """
        start_time = time.time()
        steps = []
        
        # Find the liked destination
        liked = next((d for d in destinations if d.get('id') == liked_destination_id), None)
        
        if not liked:
            return {'error': 'Destination not found', 'recommendations': []}
        
        steps.append({
            'step': 1,
            'action': 'reference',
            'liked_destination': liked.get('name'),
            'attributes': {
                'difficulty': liked.get('difficulty'),
                'duration': liked.get('duration_days'),
                'price': liked.get('price'),
                'location': liked.get('location')
            }
        })
        
        similar_destinations = []
        
        for dest in destinations:
            if dest.get('id') == liked_destination_id:
                continue
            
            similarity_score = 0
            reasons = []
            
            # Same difficulty (+30 points)
            if dest.get('difficulty') == liked.get('difficulty'):
                similarity_score += 30
                reasons.append('Same difficulty level')
            
            # Similar duration (+20 points if within 3 days)
            days_diff = abs(int(dest.get('duration_days', 0)) - int(liked.get('duration_days', 0)))
            if days_diff <= 3:
                duration_score = 20 - (days_diff * 5)
                similarity_score += duration_score
                reasons.append('Similar duration')
            
            # Similar price (+25 points if within 30%)
            price_diff_ratio = abs(float(dest.get('price', 0)) - float(liked.get('price', 0))) / float(liked.get('price', 1))
            if price_diff_ratio <= 0.3:
                price_score = int((1 - price_diff_ratio) * 25)
                similarity_score += price_score
                reasons.append('Similar price range')
            
            # Same region/location (+15 points)
            if dest.get('location', '').split(',')[0] == liked.get('location', '').split(',')[0]:
                similarity_score += 15
                reasons.append('Same region')
            
            # Similar rating (+10 points if within 0.5)
            rating_diff = abs(float(dest.get('average_rating', 0)) - float(liked.get('average_rating', 0)))
            if rating_diff <= 0.5:
                similarity_score += 10
                reasons.append('Similar ratings')
            
            if similarity_score > 0:
                similar_destinations.append({
                    'destination': dest,
                    'similarity_score': similarity_score,
                    'reasons': reasons
                })
                
                steps.append({
                    'step': len(steps) + 1,
                    'action': 'calculate_similarity',
                    'destination': dest.get('name'),
                    'score': similarity_score
                })
        
        # Sort by similarity
        similar_destinations.sort(key=lambda x: x['similarity_score'], reverse=True)
        
        execution_time = (time.time() - start_time) * 1000
        
        return {
            'algorithm': 'Content-Based Filtering',
            'based_on': liked.get('name'),
            'total_similar': len(similar_destinations),
            'recommendations': [
                {
                    **item['destination'],
                    'similarity_score': item['similarity_score'],
                    'reasons': item['reasons']
                }
                for item in similar_destinations[:10]
            ],
            'steps': steps[:20],
            'similarity_factors': {
                'same_difficulty': 30,
                'similar_duration': '0-20',
                'similar_price': '0-25',
                'same_region': 15,
                'similar_rating': 10
            },
            'time_complexity': 'O(n)',
            'space_complexity': 'O(n)',
            'execution_time_ms': round(execution_time, 4),
            'description': 'Finds destinations with similar attributes to liked destination',
            'pseudocode': [
                'find reference destination',
                'for each other destination:',
                '    similarity = 0',
                '    if same difficulty: similarity += 30',
                '    if similar duration: similarity += 0-20',
                '    if similar price: similarity += 0-25',
                '    if same region: similarity += 15',
                '    if similar rating: similarity += 10',
                '    add to candidates',
                'sort by similarity (descending)',
                'return top N'
            ]
        }
