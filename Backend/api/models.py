from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
import math


class UserProfile(models.Model):
    """
    Extended user profile information for authentication and contact details.
    Includes nationality for dynamic cost estimation (Nepali vs International).
    """
    GENDER_CHOICES = [
        ('MALE', 'Male'),
        ('FEMALE', 'Female'),
        ('OTHER', 'Other'),
    ]
    
    NATIONALITY_CHOICES = [
        ('NEPALI', 'Nepali'),
        ('INTERNATIONAL', 'International'),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    full_name = models.CharField(max_length=150)
    address = models.CharField(max_length=255)
    contact_number = models.CharField(max_length=20)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES)
    nationality = models.CharField(max_length=20, choices=NATIONALITY_CHOICES, default='INTERNATIONAL', help_text="Used for dynamic cost estimation")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['user__username']

    def __str__(self):
        return f"{self.user.username} Profile"


class Destination(models.Model):
    """
    Represents a trekking destination (e.g., Annapurna Base Camp, Everest Base Camp)
    """
    DIFFICULTY_CHOICES = [
        ('EASY', 'Easy'),
        ('MODERATE', 'Moderate'),
        ('CHALLENGING', 'Challenging'),
        ('DIFFICULT', 'Difficult'),
    ]
    
    name = models.CharField(max_length=200)
    description = models.TextField()
    location = models.CharField(max_length=200)
    altitude = models.IntegerField(help_text="Altitude in meters")
    max_altitude = models.IntegerField(default=0, help_text="Maximum altitude in meters")
    duration_days = models.IntegerField(help_text="Trek duration in days")
    difficulty = models.CharField(max_length=20, choices=DIFFICULTY_CHOICES)
    difficulty_level = models.CharField(max_length=20, choices=DIFFICULTY_CHOICES, default='MODERATE')
    price = models.DecimalField(max_digits=10, decimal_places=2, help_text="Price in USD")
    base_price_npr = models.FloatField(default=0, help_text="Base package price in NPR")
    is_restricted_area = models.BooleanField(default=False)
    image = models.ImageField(upload_to='destinations/', blank=True, null=True)
    featured = models.BooleanField(default=False)
    best_season = models.CharField(max_length=100, blank=True)
    group_size_max = models.IntegerField(default=15)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Coordinates for map center
    latitude = models.FloatField(default=28.0)
    longitude = models.FloatField(default=84.0)
    
    class Meta:
        ordering = ['-featured', 'name']

    def save(self, *args, **kwargs):
        if not self.max_altitude:
            self.max_altitude = self.altitude
        if self.max_altitude and self.altitude != self.max_altitude:
            self.altitude = self.max_altitude

        if self.difficulty_level and self.difficulty != self.difficulty_level:
            self.difficulty = self.difficulty_level
        elif not self.difficulty_level:
            self.difficulty_level = self.difficulty

        if not self.base_price_npr:
            self.base_price_npr = float(self.price) * 132

        super().save(*args, **kwargs)
    
    def __str__(self):
        return self.name

class TrekDestination(models.Model):
    """
    Dedicated trek model for algorithmic trip planner input.
    """
    DIFFICULTY_CHOICES = [
        ('EASY', 'Easy'),
        ('MODERATE', 'Moderate'),
        ('CHALLENGING', 'Challenging'),
        ('DIFFICULT', 'Difficult'),
    ]

    name = models.CharField(max_length=200)
    cost = models.PositiveIntegerField(help_text="Cost in NPR")
    duration_days = models.PositiveIntegerField(help_text="Trek duration in days")
    rating = models.FloatField(help_text="Rating between 1.0 and 5.0")
    difficulty = models.CharField(max_length=20, choices=DIFFICULTY_CHOICES)
    image_url = models.URLField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return self.name


class TrekRoute(models.Model):
    """
    Stores GPS coordinates for trekking routes
    """
    destination = models.ForeignKey(Destination, on_delete=models.CASCADE, related_name='route_points')
    sequence_order = models.IntegerField(help_text="Order of this point in the route")
    latitude = models.FloatField()
    longitude = models.FloatField()
    altitude = models.IntegerField(help_text="Altitude at this point in meters")
    location_name = models.CharField(max_length=200, blank=True)
    description = models.TextField(blank=True)
    
    class Meta:
        ordering = ['destination', 'sequence_order']
        unique_together = ['destination', 'sequence_order']
    
    def __str__(self):
        return f"{self.destination.name} - Point {self.sequence_order}"
    
    @staticmethod
    def calculate_distance(lat1, lon1, lat2, lon2):
        """
        Calculate distance between two points using Haversine formula
        Returns distance in kilometers
        """
        R = 6371  # Earth's radius in kilometers
        
        # Convert degrees to radians
        lat1_rad = math.radians(lat1)
        lat2_rad = math.radians(lat2)
        delta_lat = math.radians(lat2 - lat1)
        delta_lon = math.radians(lon2 - lon1)
        
        # Haversine formula
        a = (math.sin(delta_lat / 2) ** 2 +
             math.cos(lat1_rad) * math.cos(lat2_rad) *
             math.sin(delta_lon / 2) ** 2)
        c = 2 * math.asin(math.sqrt(a))
        
        distance = R * c
        return distance


class WeatherCache(models.Model):
    """
    Caches weather data to reduce API calls
    """
    destination = models.ForeignKey(Destination, on_delete=models.CASCADE, related_name='weather_data')
    temperature = models.FloatField()
    weather_condition = models.CharField(max_length=100)
    description = models.CharField(max_length=200)
    humidity = models.IntegerField()
    wind_speed = models.FloatField()
    
    # Risk indicators
    has_rain_warning = models.BooleanField(default=False)
    has_snow_warning = models.BooleanField(default=False)
    has_altitude_warning = models.BooleanField(default=False)
    risk_level = models.CharField(max_length=20, default='LOW')  # LOW, MEDIUM, HIGH
    
    cached_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-cached_at']
    
    def __str__(self):
        return f"{self.destination.name} - {self.weather_condition}"
    
    def is_cache_valid(self, cache_duration=3600):
        """Check if cache is still valid (default 1 hour)"""
        from django.utils import timezone
        import datetime
        time_diff = timezone.now() - self.cached_at
        return time_diff.total_seconds() < cache_duration


class Booking(models.Model):
    """
    Booking/Inquiry system for trek packages
    """
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('CONFIRMED', 'Confirmed'),
        ('CANCELLED', 'Cancelled'),
        ('COMPLETED', 'Completed'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings')
    destination = models.ForeignKey(Destination, on_delete=models.CASCADE, related_name='bookings')
    start_date = models.DateField()
    number_of_people = models.IntegerField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    special_requirements = models.TextField(blank=True)
    contact_phone = models.CharField(max_length=20)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.username} - {self.destination.name} - {self.start_date}"


class Review(models.Model):
    """
    User reviews for destinations
    """
    destination = models.ForeignKey(Destination, on_delete=models.CASCADE, related_name='reviews')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='reviews')
    rating = models.IntegerField(choices=[(i, i) for i in range(1, 6)])
    comment = models.TextField()
    image = models.ImageField(upload_to='reviews/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
        unique_together = ['destination', 'user']
    
    def __str__(self):
        return f"{self.user.username} - {self.destination.name} - {self.rating}★"


class PasswordResetOTP(models.Model):
    """
    Stores short-lived OTPs for forgot password flow.
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='password_reset_otps')
    otp_code = models.CharField(max_length=6)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    verified_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"OTP for {self.user.username}"

    def is_valid(self):
        return (not self.is_used) and timezone.now() <= self.expires_at


class Notification(models.Model):
    """
    User notification model for in-app bell and unread badge.
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=120)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} - {self.title}"


# ============================================================================
# ALGORITHM & OPTIMIZATION MODELS (For Advanced DSA Features)
# ============================================================================

class CostConfiguration(models.Model):
    """
    Stores detailed costs for trek expenses.
    Used by the Dynamic Cost Estimator algorithm.
    
    Cost Breakdown:
    - Hotel (per night): accommodation during trek
    - Meals (per day): food & water
    - Bus Transport: to/from trailhead
    - Permits: government fees
    - Guide: professional guide daily rate
    - Porter: porter daily rate
    """
    destination = models.OneToOneField(Destination, on_delete=models.CASCADE, related_name='cost_config')
    
    # Actual daily costs in USD (per person, per day)
    hotel_cost_per_night = models.DecimalField(max_digits=8, decimal_places=2, default=20.0, help_text="Hotel/lodge cost per night per person (USD)")
    meals_cost_per_day = models.DecimalField(max_digits=8, decimal_places=2, default=10.0, help_text="Meals & snacks per day per person (USD)")
    bus_transport_cost = models.DecimalField(max_digits=8, decimal_places=2, default=5.0, help_text="Round-trip bus/jeep to trailhead per person (USD)")
    
    # Permit fee per person in USD
    permit_fee_saarc = models.DecimalField(max_digits=8, decimal_places=2, default=0, help_text="Permit fee for SAARC nationals (USD)")
    permit_fee_international = models.DecimalField(max_digits=8, decimal_places=2, default=0, help_text="Permit fee for international guests (USD)")
    
    # Guide and porter daily rates in USD
    guide_daily_rate = models.DecimalField(max_digits=8, decimal_places=2, default=30.0, help_text="Guide daily rate (USD)")
    porter_daily_rate = models.DecimalField(max_digits=8, decimal_places=2, default=15.0, help_text="Porter daily rate (USD)")
    
    # Price multiplier for nationals vs international (base destination.price is for international)
    saarc_discount_multiplier = models.FloatField(default=0.5, help_text="Price multiplier for SAARC nationals (0.0-1.0)")
    international_multiplier = models.FloatField(default=1.0, help_text="Price multiplier for international guests")
    
    # Optional: Detour premium (additional cost %)
    detour_premium_percent = models.FloatField(default=15.0, help_text="Additional cost % for including detours")
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name_plural = "Cost Configurations"
    
    def __str__(self):
        return f"Cost Config: {self.destination.name}"


class Detour(models.Model):
    """
    Represents optional detours/side-trips that can be added to a trek.
    Modeled as a Directed Acyclic Graph (DAG) where multiple routes can branch.
    
    Used for:
    - Dijkstra's algorithm: finding optimal path cost when user adds detours
    - Graph visualization: showing alternative routes to users
    """
    destination = models.ForeignKey(Destination, on_delete=models.CASCADE, related_name='detours')
    
    name = models.CharField(max_length=200, help_text="e.g., 'Mera Peak Ascent', 'Chame Hot Spring'")
    description = models.TextField()
    
    # GPS route for this detour
    start_latitude = models.FloatField()
    start_longitude = models.FloatField()
    end_latitude = models.FloatField()
    end_longitude = models.FloatField()
    
    # Cost and distance impact
    extra_cost_usd = models.DecimalField(max_digits=10, decimal_places=2, help_text="Additional cost for this detour (USD)")
    extra_days = models.IntegerField(default=1, help_text="Additional days required for this detour")
    distance_km = models.FloatField(help_text="Distance of this detour in km (for algorithm)")
    
    # Difficulty and rating
    difficulty = models.CharField(
        max_length=20,
        choices=[('EASY', 'Easy'), ('MODERATE', 'Moderate'), ('CHALLENGING', 'Challenging'), ('DIFFICULT', 'Difficult')],
        default='MODERATE'
    )
    quality_rating = models.FloatField(default=4.0, help_text="Quality/Beauty rating (1-5) for knapsack quality value")
    
    # Graph relationship: parent and optional predecessors
    is_optional = models.BooleanField(default=True, help_text="If False, detour is mandatory")
    required_before_detours = models.ManyToManyField('self', symmetrical=False, blank=True, related_name='dependent_detours', help_text="Other detours that must be completed first (DAG edges)")
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['destination', 'name']
    
    def __str__(self):
        return f"{self.destination.name} - {self.name}"


class Guide(models.Model):
    """Licensed trekking guide profile used for restricted-area compliance."""
    name = models.CharField(max_length=150)
    license_number = models.CharField(max_length=100, unique=True)
    experience_years = models.IntegerField(default=1)
    specialization = models.CharField(max_length=150, blank=True)
    daily_rate = models.DecimalField(max_digits=10, decimal_places=2, default=35.0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return f"{self.name} ({self.license_number})"


class TrekItinerary(models.Model):
    """
    User's planned trek with selected detours and estimated costs/time.
    This is the output of the optimization algorithms (Knapsack, Dijkstra).
    
    The backend generates:
    - total_cost (from cost estimator)
    - total_duration (updated by selected detours)
    - route_polyline (from Dijkstra's shortest path)
    - execution_steps (for algorithm visualization)
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='trek_itineraries')
    destination = models.ForeignKey(Destination, on_delete=models.CASCADE, related_name='user_itineraries')
    selected_guide = models.ForeignKey(Guide, on_delete=models.SET_NULL, null=True, blank=True, related_name='itineraries')
    
    # Time range for trip
    start_date = models.DateField()
    end_date = models.DateField()
    
    # METADATA: Cost Breakdown
    base_cost = models.DecimalField(max_digits=12, decimal_places=2, help_text="Base destination price (with nationality multiplier)")
    permit_cost = models.DecimalField(max_digits=12, decimal_places=2, help_text="Permit fees for all people")
    guide_cost = models.DecimalField(max_digits=12, decimal_places=2, default=0, help_text="Guide hiring costs")
    porter_cost = models.DecimalField(max_digits=12, decimal_places=2, default=0, help_text="Porter hiring costs")
    detour_cost = models.DecimalField(max_digits=12, decimal_places=2, default=0, help_text="Additional costs from detours")
    total_cost = models.DecimalField(max_digits=12, decimal_places=2, help_text="Total estimated trip cost (USD)")
    
    # Trip parameters
    number_of_people = models.IntegerField(default=1)
    include_guide = models.BooleanField(default=False)
    include_porter = models.BooleanField(default=False)
    number_of_porters = models.IntegerField(default=0)
    
    # Selected detours from this itinerary
    selected_detours = models.ManyToManyField(Detour, blank=True, related_name='in_itineraries', help_text="Detours user selected for this trip")
    
    # Route information
    total_distance_km = models.FloatField(default=0, help_text="Total trek distance including detours (km)")
    total_duration_days = models.IntegerField(help_text="Total days including detours")
    weather_risk_level = models.CharField(max_length=20, default='LOW', choices=[('LOW', 'Low'), ('MEDIUM', 'Medium'), ('HIGH', 'High')])
    
    # Algorithm execution metadata (for visualization)
    algorithm_used = models.CharField(max_length=100, blank=True, help_text="e.g., 'knapsack', 'dijkstra'")
    execution_steps = models.JSONField(default=list, blank=True, help_text="List of steps for frontend visualization")
    calculated_safety_json = models.JSONField(default=dict, blank=True)
    
    # Status
    status = models.CharField(
        max_length=20,
        choices=[('DRAFT', 'Draft'), ('CONFIRMED', 'Confirmed'), ('IN_PROGRESS', 'In Progress'), ('COMPLETED', 'Completed')],
        default='DRAFT'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name_plural = "Trek Itineraries"
    
    def __str__(self):
        return f"{self.user.username} - {self.destination.name} ({self.start_date})"
    
    def days_count(self):
        """Calculate number of days in this itinerary"""
        return (self.end_date - self.start_date).days + 1


class TrekActivity(models.Model):
    """
    Individual stops/activities within a TrekItinerary.
    Represents nodes in the DAG or Dijkstra path visualization.
    """
    itinerary = models.ForeignKey(TrekItinerary, on_delete=models.CASCADE, related_name='activities')
    
    # Sequence order (for stepper UI)
    day_number = models.IntegerField()
    sequence_order = models.IntegerField(help_text="Order within the day")
    
    # Activity details
    name = models.CharField(max_length=200, help_text="e.g., 'Arrive at Base Camp', 'Rest day at Namche'")
    description = models.TextField(blank=True)
    
    # GPS coordinates
    latitude = models.FloatField()
    longitude = models.FloatField()
    altitude = models.IntegerField(help_text="Altitude in meters")
    
    # Time estimate
    estimated_hours = models.FloatField(default=8.0, help_text="Estimated hours for this activity")
    distance_from_previous_km = models.FloatField(default=0, help_text="Distance from previous activity (km)")
    
    # Activity type
    ACTIVITY_TYPES = [
        ('START', 'Trek Start'),
        ('WALK', 'Walking'),
        ('REST', 'Rest Day'),
        ('CAMP', 'Camp/Acclimation'),
        ('DETOUR', 'Detour Activity'),
        ('END', 'Trek End'),
    ]
    activity_type = models.CharField(max_length=20, choices=ACTIVITY_TYPES, default='WALK')
    
    # Difficulty for this segment
    difficulty = models.CharField(
        max_length=20,
        choices=[('EASY', 'Easy'), ('MODERATE', 'Moderate'), ('CHALLENGING', 'Challenging')],
        default='MODERATE'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['itinerary', 'day_number', 'sequence_order']
        unique_together = ['itinerary', 'day_number', 'sequence_order']
    
    def __str__(self):
        return f"{self.itinerary.destination.name} - Day {self.day_number}: {self.name}"
