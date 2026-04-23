"""
Weather Risk Engine Service
Analyzes weather patterns to assign risk levels to trekking routes.
Provides safety recommendations based on conditions.
"""

from typing import Dict, List, Tuple
from decimal import Decimal
from datetime import datetime, timedelta
import requests
from django.conf import settings
from django.db import models
from api.models import Destination, WeatherCache, TrekRoute


class WeatherRiskEngine:
    """
    Evaluates weather-based safety risks for trekking.
    
    Risk Calculation:
    - Base risk from weather condition (rain, snow, wind)
    - Altitude risk (higher altitude = increased risk in bad weather)
    - Seasonal risk (some routes risky in certain seasons)
    - Historical data (trends from past weather)
    
    Returns: LOW, MEDIUM, or HIGH risk level
    """
    
    # Temperature thresholds
    EXTREME_COLD_CELSIUS = -10
    VERY_COLD_CELSIUS = 0
    COMFORTABLE_TEMP_RANGE = (15, 25)
    
    # Wind speed thresholds (km/h)
    DANGEROUS_WIND_KMH = 50
    RISKY_WIND_KMH = 30
    
    # Altitude danger zones (meters)
    HIGH_ALTITUDE = 4000  # Increased AMS risk
    EXTREME_ALTITUDE = 7000  # Extreme risk
    
    def __init__(self):
        self.execution_steps = []
    
    def assess_risk(self, destination: Destination, check_date: datetime = None) -> Dict:
        """
        Assess weather risk for a destination.
        
        Args:
            destination: Destination object
            check_date: Date to check (default: today)
        
        Returns:
            {
                risk_level: str ('LOW', 'MEDIUM', 'HIGH'),
                factors: Dict of contributing factors,
                recommendations: List[str],
                execution_steps: List[str],
                weather_data: Dict
            }
        """
        self.execution_steps = []
        
        if check_date is None:
            check_date = datetime.now()
        
        self.execution_steps.append(f"Risk Assessment for {destination.name}")
        self.execution_steps.append(f"Date: {check_date.strftime('%Y-%m-%d')}")
        
        # Get weather data
        weather_data = self._get_weather(destination)
        
        if not weather_data:
            self.execution_steps.append("WARNING: No weather data available, defaulting to MEDIUM risk")
            return {
                'risk_level': 'MEDIUM',
                'factors': {},
                'recommendations': ['Could not fetch weather data. Proceed with caution.'],
                'execution_steps': self.execution_steps,
                'weather_data': {}
            }
        
        # Risk factor scoring
        risk_scores = {
            'temperature': 0,
            'precipitation': 0,
            'wind': 0,
            'altitude': 0,
            'visibility': 0
        }
        
        # ===== Temperature Risk =====
        temp = weather_data.get('temperature', 20)
        self.execution_steps.append(f"Temperature: {temp}°C")
        
        if temp < self.EXTREME_COLD_CELSIUS:
            risk_scores['temperature'] = 10  # Very high risk
            self.execution_steps.append(f"EXTREME COLD: {temp}°C < {self.EXTREME_COLD_CELSIUS}°C → Score: 10")
        elif temp < self.VERY_COLD_CELSIUS:
            risk_scores['temperature'] = 6  # High risk
            self.execution_steps.append(f"Very cold: {temp}°C < {self.VERY_COLD_CELSIUS}°C → Score: 6")
        elif temp < self.COMFORTABLE_TEMP_RANGE[0] or temp > self.COMFORTABLE_TEMP_RANGE[1]:
            risk_scores['temperature'] = 2  # Mild risk
            self.execution_steps.append(f"Outside comfort range → Score: 2")
        else:
            risk_scores['temperature'] = 0
            self.execution_steps.append(f"Comfortable temperature → Score: 0")
        
        # ===== Precipitation Risk =====
        condition = weather_data.get('weather_condition', '').lower()
        has_rain = any(word in condition for word in ['rain', 'drizzle', 'shower'])
        has_snow = any(word in condition for word in ['snow', 'sleet'])
        has_thunder = any(word in condition for word in ['thunder', 'storm'])
        
        self.execution_steps.append(f"Conditions: {condition}")
        
        if has_thunder:
            risk_scores['precipitation'] = 10
            self.execution_steps.append("THUNDERSTORM detected → Score: 10")
        elif has_snow:
            risk_scores['precipitation'] = 8
            self.execution_steps.append("Snow detected → Score: 8")
        elif has_rain:
            risk_scores['precipitation'] = 5
            self.execution_steps.append("Rain detected → Score: 5")
        else:
            risk_scores['precipitation'] = 0
            self.execution_steps.append("Clear weather → Score: 0")
        
        # ===== Wind Risk =====
        wind_speed = weather_data.get('wind_speed', 0)
        self.execution_steps.append(f"Wind Speed: {wind_speed} km/h")
        
        if wind_speed > self.DANGEROUS_WIND_KMH:
            risk_scores['wind'] = 10
            self.execution_steps.append(f"DANGEROUS WIND: {wind_speed} > {self.DANGEROUS_WIND_KMH} → Score: 10")
        elif wind_speed > self.RISKY_WIND_KMH:
            risk_scores['wind'] = 6
            self.execution_steps.append(f"Risky wind: {wind_speed} > {self.RISKY_WIND_KMH} → Score: 6")
        else:
            risk_scores['wind'] = 0
            self.execution_steps.append(f"Safe wind → Score: 0")
        
        # ===== Altitude Risk =====
        max_altitude_on_route = self._get_max_altitude(destination)
        self.execution_steps.append(f"Max altitude: {max_altitude_on_route}m")
        
        if max_altitude_on_route > self.EXTREME_ALTITUDE:
            risk_scores['altitude'] = 8
            self.execution_steps.append(f"EXTREME ALTITUDE: {max_altitude_on_route} > {self.EXTREME_ALTITUDE} → Score: 8")
        elif max_altitude_on_route > self.HIGH_ALTITUDE:
            risk_scores['altitude'] = 4
            self.execution_steps.append(f"High altitude: {max_altitude_on_route} > {self.HIGH_ALTITUDE} → Score: 4")
            
            # Altitude risk increases with bad weather
            if has_rain or has_snow or temp < self.VERY_COLD_CELSIUS:
                risk_scores['altitude'] = 6
                self.execution_steps.append("  Worsened by bad weather → Score increased to 6")
        else:
            risk_scores['altitude'] = 0
            self.execution_steps.append("Safe altitude → Score: 0")
        
        # ===== Visibility Risk =====
        humidity = weather_data.get('humidity', 50)
        visibility_km = weather_data.get('visibility_km', 10)
        
        if visibility_km < 1:
            risk_scores['visibility'] = 7
            self.execution_steps.append(f"POOR VISIBILITY: {visibility_km}km → Score: 7")
        elif visibility_km < 3:
            risk_scores['visibility'] = 4
            self.execution_steps.append(f"Limited visibility: {visibility_km}km → Score: 4")
        else:
            risk_scores['visibility'] = 0
        
        # ===== Overall Risk Calculation =====
        total_score = sum(risk_scores.values())
        max_score = 10 * len(risk_scores)  # Max 50 for 5 factors
        
        self.execution_steps.append(f"\nRisk Score Breakdown:")
        for factor, score in risk_scores.items():
            self.execution_steps.append(f"  {factor.upper()}: {score}/10")
        
        self.execution_steps.append(f"TOTAL SCORE: {total_score}/{max_score}")
        
        # Assign risk level
        if total_score <= 10:
            risk_level = 'LOW'
        elif total_score <= 25:
            risk_level = 'MEDIUM'
        else:
            risk_level = 'HIGH'
        
        self.execution_steps.append(f"Risk Level: {risk_level}")
        
        # Generate recommendations
        recommendations = self._generate_recommendations(risk_level, risk_scores, weather_data)
        
        factors = {
            'temperature': temp,
            'condition': condition,
            'wind_speed': wind_speed,
            'humidity': humidity,
            'visibility_km': visibility_km,
            'max_altitude': max_altitude_on_route,
            'risk_scores': risk_scores
        }
        
        return {
            'risk_level': risk_level,
            'factors': factors,
            'recommendations': recommendations,
            'execution_steps': self.execution_steps,
            'weather_data': weather_data
        }
    
    def _get_weather(self, destination: Destination) -> Dict:
        """Fetch or retrieve cached weather data"""
        try:
            # Check for recent cache
            weather = destination.weather_data.latest('cached_at')
            
            if weather.is_cache_valid(3600):  # 1 hour cache
                self.execution_steps.append(f"Using cached weather data (age: recent)")
                return {
                    'temperature': weather.temperature,
                    'weather_condition': weather.weather_condition,
                    'humidity': weather.humidity,
                    'wind_speed': weather.wind_speed,
                    'visibility_km': 10,  # Default
                    'risk_level': weather.risk_level
                }
        except:
            pass
        
        # Try to fetch new weather data
        if settings.WEATHER_API_KEY:
            try:
                url = 'https://api.openweathermap.org/data/2.5/weather'
                params = {
                    'lat': destination.latitude,
                    'lon': destination.longitude,
                    'appid': settings.WEATHER_API_KEY,
                    'units': 'metric'
                }
                response = requests.get(url, params=params, timeout=5)
                response.raise_for_status()
                data = response.json()
                
                return {
                    'temperature': data['main']['temp'],
                    'weather_condition': data['weather'][0]['main'],
                    'humidity': data['main']['humidity'],
                    'wind_speed': data.get('wind', {}).get('speed', 0) * 3.6,  # m/s to km/h
                    'visibility_km': data.get('visibility', 10000) / 1000
                }
            except Exception as e:
                self.execution_steps.append(f"Weather API error: {str(e)}")
        
        # Fallback: return null or default
        return None
    
    def _get_max_altitude(self, destination: Destination) -> int:
        """Get maximum altitude from destination route points"""
        route_points = destination.route_points.all()
        if route_points.exists():
            max_alt = route_points.aggregate(models.Max('altitude'))['altitude__max']
            return max_alt or destination.altitude
        return destination.altitude
    
    def _generate_recommendations(self, risk_level: str, risk_scores: Dict, weather_data: Dict) -> List[str]:
        """Generate safety recommendations based on risk assessment"""
        recommendations = []
        
        if risk_level == 'HIGH':
            recommendations.append("⚠️ HIGH RISK - Consider postponing this trek")
            recommendations.append("Contact local guides for current conditions")
            recommendations.append("Ensure all participants have experience and proper gear")
        else:
            recommendations.append(f"✓ {risk_level} risk level - Trek is generally safe")
        
        # Specific recommendations
        if risk_scores.get('temperature', 0) >= 6:
            recommendations.append("Bring extra warm clothing and insulation gear")
        
        if risk_scores.get('precipitation', 0) >= 8:
            recommendations.append("Pack waterproof gear and rain protection")
        
        if risk_scores.get('wind', 0) >= 6:
            recommendations.append("Avoid exposed ridges during peak wind times")
        
        if risk_scores.get('altitude', 0) >= 6:
            recommendations.append("Take altitude acclimatization seriously")
            recommendations.append("Consider hiring experience guides for high altitude")
        
        if risk_scores.get('visibility', 0) >= 4:
            recommendations.append("Trek only in daylight hours")
            recommendations.append("Bring flashlights and navigational tools")
        
        return recommendations
