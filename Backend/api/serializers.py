from rest_framework import serializers
from django.contrib.auth.models import User
from django.utils import timezone
from decimal import Decimal
import re
from django.utils.html import strip_tags
from .models import (
    Destination, TrekRoute, WeatherCache, UserProfile, TrekDestination,
    Booking, Review, PasswordResetOTP, Notification,
    CostConfiguration, Detour, TrekItinerary, TrekActivity, Guide
)
from .services.safety_logic import analyze_trek_safety_and_finance
from services.trip_planner import TripPlannerService


class UserSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()
    address = serializers.SerializerMethodField()
    contact_number = serializers.SerializerMethodField()
    gender = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name',
            'full_name', 'address', 'contact_number', 'gender'
        ]
        read_only_fields = ['id']

    def get_full_name(self, obj):
        if hasattr(obj, 'profile'):
            return obj.profile.full_name
        return obj.get_full_name().strip()

    def get_address(self, obj):
        if hasattr(obj, 'profile'):
            return obj.profile.address
        return ''

    def get_contact_number(self, obj):
        if hasattr(obj, 'profile'):
            return obj.profile.contact_number
        return ''

    def get_gender(self, obj):
        if hasattr(obj, 'profile'):
            return obj.profile.gender
        return ''


class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True, min_length=8)
    full_name = serializers.CharField(write_only=True, max_length=150, required=False, allow_blank=True)
    address = serializers.CharField(write_only=True, max_length=255, required=False, allow_blank=True)
    contact_number = serializers.CharField(write_only=True, max_length=20, required=False, allow_blank=True)
    gender = serializers.ChoiceField(write_only=True, choices=UserProfile.GENDER_CHOICES, required=False)
    
    class Meta:
        model = User
        fields = [
            'username', 'email', 'password', 'password_confirm',
            'first_name', 'last_name', 'full_name', 'address',
            'contact_number', 'gender'
        ]
    
    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError("Passwords do not match")

        email = data.get('email', '').strip().lower()
        email_regex = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        if not email:
            raise serializers.ValidationError({'email': 'Email is required.'})
        if not re.fullmatch(email_regex, email):
            raise serializers.ValidationError({'email': 'Invalid email format.'})
        data['email'] = email

        username = data.get('username', '').strip()
        if len(username) < 2:
            raise serializers.ValidationError({'username': 'Username must be at least 2 characters.'})
        if username.isdigit():
            raise serializers.ValidationError({'username': 'Username cannot be only numbers.'})
        if not re.fullmatch(r'^[a-zA-Z0-9_.-]{2,}$', username):
            raise serializers.ValidationError({'username': 'Username can only contain letters, numbers, ., _, and -.'})

        first_name = data.get('first_name', '').strip()
        last_name = data.get('last_name', '').strip()
        name_regex = r'^[A-Za-z]{2,10}$'
        if not first_name or not re.fullmatch(name_regex, first_name):
            raise serializers.ValidationError({'first_name': 'First name must be 2-10 letters only.'})
        if not last_name or not re.fullmatch(name_regex, last_name):
            raise serializers.ValidationError({'last_name': 'Last name must be 2-10 letters only.'})

        password = data['password']
        if not re.search(r'[A-Z]', password):
            raise serializers.ValidationError({'password': 'Password must contain at least one uppercase letter.'})
        if not re.search(r'\d', password):
            raise serializers.ValidationError({'password': 'Password must contain at least one number.'})
        if not re.search(r'[^\w\s]', password):
            raise serializers.ValidationError({'password': 'Password must contain at least one special character.'})
        return data
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        first_name = validated_data.get('first_name', '').strip()
        last_name = validated_data.get('last_name', '').strip()
        full_name = validated_data.pop('full_name', '').strip()
        address = validated_data.pop('address', '').strip()
        contact_number = validated_data.pop('contact_number', '').strip()
        gender = validated_data.pop('gender', UserProfile.GENDER_CHOICES[2][0])

        resolved_full_name = full_name or f"{first_name} {last_name}".strip() or validated_data['username']

        # Django uses PBKDF2 with SHA256 for password hashing (secure)
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password'],
            first_name=first_name,
            last_name=last_name
        )

        UserProfile.objects.create(
            user=user,
            full_name=resolved_full_name,
            address=address,
            contact_number=contact_number,
            gender=gender,
        )
        return user


class UserProfileUpdateSerializer(serializers.Serializer):
    first_name = serializers.CharField(max_length=150, required=False, allow_blank=True)
    last_name = serializers.CharField(max_length=150, required=False, allow_blank=True)
    email = serializers.EmailField(required=False, allow_blank=True)
    full_name = serializers.CharField(max_length=150, required=False, allow_blank=True)
    address = serializers.CharField(max_length=255, required=False, allow_blank=True)
    contact_number = serializers.CharField(max_length=20, required=False, allow_blank=True)
    gender = serializers.ChoiceField(choices=UserProfile.GENDER_CHOICES, required=False)

    def validate_email(self, value):
        email = (value or '').strip().lower()
        if not email:
            return email

        user = self.context['request'].user
        existing = User.objects.filter(email__iexact=email).exclude(id=user.id)
        if existing.exists():
            raise serializers.ValidationError('This email is already in use.')
        return email

    def validate_contact_number(self, value):
        sanitized = (value or '').strip()
        if sanitized and not re.fullmatch(r'^\+?[0-9\-\s]{7,20}$', sanitized):
            raise serializers.ValidationError('Invalid contact phone format.')
        return sanitized

    def update(self, instance, validated_data):
        user = instance

        if 'first_name' in validated_data:
            user.first_name = validated_data['first_name'].strip()
        if 'last_name' in validated_data:
            user.last_name = validated_data['last_name'].strip()
        if 'email' in validated_data:
            user.email = validated_data['email']
        user.save(update_fields=['first_name', 'last_name', 'email'])

        profile, _ = UserProfile.objects.get_or_create(
            user=user,
            defaults={
                'full_name': user.get_full_name().strip() or user.username,
                'address': '',
                'contact_number': '',
                'gender': UserProfile.GENDER_CHOICES[2][0],
            },
        )

        if 'full_name' in validated_data:
            profile.full_name = validated_data['full_name'].strip() or user.get_full_name().strip() or user.username
        if 'address' in validated_data:
            profile.address = validated_data['address'].strip()
        if 'contact_number' in validated_data:
            profile.contact_number = validated_data['contact_number']
        if 'gender' in validated_data:
            profile.gender = validated_data['gender']
        profile.save(update_fields=['full_name', 'address', 'contact_number', 'gender'])

        return user


class TrekRouteSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrekRoute
        fields = ['id', 'sequence_order', 'latitude', 'longitude', 
                 'altitude', 'location_name', 'description']


class WeatherCacheSerializer(serializers.ModelSerializer):
    class Meta:
        model = WeatherCache
        fields = ['id', 'temperature', 'weather_condition', 'description',
                 'humidity', 'wind_speed', 'has_rain_warning', 'has_snow_warning',
                 'has_altitude_warning', 'risk_level', 'cached_at']


class ReviewSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    user_name = serializers.CharField(source='user.username', read_only=True)
    destination_name = serializers.CharField(source='destination.name', read_only=True)
    image = serializers.ImageField(required=False, allow_null=True)
    
    class Meta:
        model = Review
        fields = [
            'id', 'user', 'user_name', 'destination', 'destination_name',
            'rating', 'comment', 'image', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'user_name', 'destination_name']

    def validate(self, attrs):
        request = self.context.get('request')
        if request is None or request.user.is_anonymous:
            return attrs

        destination = attrs.get('destination') or getattr(self.instance, 'destination', None)
        if destination is None:
            raise serializers.ValidationError({'destination': 'Destination is required.'})

        existing = Review.objects.filter(user=request.user, destination=destination)
        if self.instance is not None:
            existing = existing.exclude(id=self.instance.id)

        if existing.exists():
            raise serializers.ValidationError({'error': 'You have already posted a review for this destination.'})

        return attrs

    def validate_rating(self, value):
        if value < 1 or value > 5:
            raise serializers.ValidationError('Rating must be between 1 and 5.')
        return value

    def validate_comment(self, value):
        cleaned = strip_tags(value or '').strip()
        if len(cleaned) < 5:
            raise serializers.ValidationError('Review comment must be at least 5 characters.')
        if len(cleaned) > 1200:
            raise serializers.ValidationError('Review comment must be 1200 characters or less.')
        return cleaned


class DestinationListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for list view"""
    average_rating = serializers.FloatField(read_only=True)
    total_reviews = serializers.IntegerField(read_only=True)

    class Meta:
        model = Destination
        fields = ['id', 'name', 'location', 'altitude', 'duration_days',
                 'max_altitude', 'difficulty', 'difficulty_level', 'price', 'base_price_npr',
                 'is_restricted_area', 'image', 'featured', 'latitude', 'longitude',
                 'average_rating', 'total_reviews', 'created_at']


class DestinationDetailSerializer(serializers.ModelSerializer):
    """Detailed serializer with all related data"""
    route_points = TrekRouteSerializer(many=True, read_only=True)
    weather_data = WeatherCacheSerializer(many=True, read_only=True)
    reviews = ReviewSerializer(many=True, read_only=True)
    average_rating = serializers.SerializerMethodField()
    total_reviews = serializers.SerializerMethodField()
    
    class Meta:
        model = Destination
        fields = '__all__'
    
    def get_average_rating(self, obj):
        reviews = obj.reviews.all()
        if reviews:
            return sum(r.rating for r in reviews) / len(reviews)
        return 0
    
    def get_total_reviews(self, obj):
        return obj.reviews.count()


class BookingSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    destination_name = serializers.CharField(source='destination.name', read_only=True)
    
    class Meta:
        model = Booking
        fields = ['id', 'user', 'destination', 'destination_name', 'start_date',
                 'number_of_people', 'status', 'special_requirements', 
                 'contact_phone', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at', 'status']

    def validate_start_date(self, value):
        if value <= timezone.now().date():
            raise serializers.ValidationError('Bookings must be made at least 24 hours in advance.')
        return value

    def validate_number_of_people(self, value):
        if value < 1 or value > 30:
            raise serializers.ValidationError('Number of people must be between 1 and 30.')
        return value

    def validate_contact_phone(self, value):
        sanitized = value.strip()
        if not re.fullmatch(r'^\+?[0-9\-\s]{7,20}$', sanitized):
            raise serializers.ValidationError('Invalid contact phone format.')
        return sanitized

    def validate_special_requirements(self, value):
        cleaned = strip_tags(value or '').strip()
        if len(cleaned) > 1000:
            raise serializers.ValidationError('Special requirements are too long.')
        return cleaned


class TrekDestinationSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrekDestination
        fields = [
            'id', 'name', 'cost', 'duration_days', 'rating',
            'difficulty', 'image_url', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate_cost(self, value):
        if value <= 0:
            raise serializers.ValidationError('Cost must be greater than zero.')
        return value

    def validate_duration_days(self, value):
        if value <= 0:
            raise serializers.ValidationError('Duration days must be greater than zero.')
        return value

    def validate_rating(self, value):
        if value <= 1.0 or value >= 5.0:
            raise serializers.ValidationError('Rating must be strictly between 1.0 and 5.0.')
        return value


class TripPlannerRequestSerializer(serializers.Serializer):
    user_budget = serializers.DecimalField(max_digits=10, decimal_places=2)
    max_days = serializers.IntegerField(min_value=2, max_value=5)

    def validate_user_budget(self, value: Decimal):
        if value < Decimal('5000'):
            raise serializers.ValidationError('Budget must be at least 5000 NPR.')
        return value

    def validate_max_days(self, value: int):
        if value < 2 or value > 5:
            raise serializers.ValidationError('Available days must be between 2 and 5.')
        return value


class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        sanitized = value.strip().lower()
        email_regex = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        if not re.fullmatch(email_regex, sanitized):
            raise serializers.ValidationError('Invalid email format.')
        if not User.objects.filter(email__iexact=sanitized).exists():
            raise serializers.ValidationError('No account found with this email.')
        return sanitized


class VerifyOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField(min_length=6, max_length=6)

    def validate_email(self, value):
        sanitized = value.strip().lower()
        email_regex = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        if not re.fullmatch(email_regex, sanitized):
            raise serializers.ValidationError('Invalid email format.')
        if not User.objects.filter(email__iexact=sanitized).exists():
            raise serializers.ValidationError('No account found with this email.')
        return sanitized

    def validate_otp(self, value):
        if not value.isdigit():
            raise serializers.ValidationError('OTP must contain only digits.')
        return value.strip()


class ResetPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()
    new_password = serializers.CharField(write_only=True, min_length=8)

    def validate_email(self, value):
        sanitized = value.strip().lower()
        email_regex = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        if not re.fullmatch(email_regex, sanitized):
            raise serializers.ValidationError('Invalid email format.')
        if not User.objects.filter(email__iexact=sanitized).exists():
            raise serializers.ValidationError('No account found with this email.')
        return sanitized

    def validate_new_password(self, value):
        if not re.search(r'[A-Z]', value):
            raise serializers.ValidationError('Password must contain at least one uppercase letter.')
        if not re.search(r'\d', value):
            raise serializers.ValidationError('Password must contain at least one number.')
        if not re.search(r'[^\w\s]', value):
            raise serializers.ValidationError('Password must contain at least one special character.')
        return value


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, min_length=8)

    def validate_new_password(self, value):
        if not re.search(r'[A-Z]', value):
            raise serializers.ValidationError('Password must contain at least one uppercase letter.')
        if not re.search(r'\d', value):
            raise serializers.ValidationError('Password must contain at least one number.')
        if not re.search(r'[^\w\s]', value):
            raise serializers.ValidationError('Password must contain at least one special character.')
        return value


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'title', 'message', 'is_read', 'created_at']
        read_only_fields = ['id', 'title', 'message', 'created_at']


# ============================================================================
# ALGORITHM & OPTIMIZATION SERIALIZERS
# ============================================================================

class DetourSerializer(serializers.ModelSerializer):
    """Detour model serializer for optional trek routes"""
    class Meta:
        model = Detour
        fields = [
            'id', 'destination', 'name', 'description',
            'start_latitude', 'start_longitude', 'end_latitude', 'end_longitude',
            'extra_cost_usd', 'extra_days', 'distance_km',
            'difficulty', 'quality_rating', 'is_optional',
            'required_before_detours', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class GuideSerializer(serializers.ModelSerializer):
    """Guide profile serializer for legal-compliance matching."""

    class Meta:
        model = Guide
        fields = [
            'id', 'name', 'license_number', 'experience_years',
            'specialization', 'daily_rate', 'is_active',
        ]
        read_only_fields = ['id']


class CostConfigurationSerializer(serializers.ModelSerializer):
    """Cost configuration for dynamic pricing"""
    destination_name = serializers.CharField(source='destination.name', read_only=True)
    
    class Meta:
        model = CostConfiguration
        fields = [
            'id', 'destination', 'destination_name',
            'hotel_cost_per_night', 'meals_cost_per_day', 'bus_transport_cost',
            'permit_fee_saarc', 'permit_fee_international',
            'guide_daily_rate', 'porter_daily_rate',
            'saarc_discount_multiplier', 'international_multiplier',
            'detour_premium_percent'
        ]
        read_only_fields = ['id']


class TrekActivitySerializer(serializers.ModelSerializer):
    """Individual activity/stop within an itinerary"""
    class Meta:
        model = TrekActivity
        fields = [
            'id', 'itinerary', 'day_number', 'sequence_order',
            'name', 'description', 'latitude', 'longitude', 'altitude',
            'estimated_hours', 'distance_from_previous_km',
            'activity_type', 'difficulty'
        ]
        read_only_fields = ['id']


class TrekItinerarySerializer(serializers.ModelSerializer):
    """User's planned trek with costs and route"""
    destination_name = serializers.CharField(source='destination.name', read_only=True)
    selected_guide_data = GuideSerializer(source='selected_guide', read_only=True)
    selected_detours_data = DetourSerializer(source='selected_detours', many=True, read_only=True)
    activities = TrekActivitySerializer(many=True, read_only=True)
    is_safe = serializers.SerializerMethodField()
    safety_warnings = serializers.SerializerMethodField()
    cash_recommendation_npr = serializers.SerializerMethodField()
    is_safe_acclimatization = serializers.SerializerMethodField()
    suggested_cash_npr = serializers.SerializerMethodField()

    class Meta:
        model = TrekItinerary
        fields = [
            'id', 'user', 'destination', 'destination_name',
            'start_date', 'end_date',
            'base_cost', 'permit_cost', 'guide_cost', 'porter_cost', 'detour_cost', 'total_cost',
            'number_of_people', 'include_guide', 'include_porter', 'number_of_porters',
            'selected_guide', 'selected_guide_data',
            'selected_detours', 'selected_detours_data',
            'total_distance_km', 'total_duration_days', 'weather_risk_level',
            'is_safe', 'safety_warnings', 'cash_recommendation_npr',
            'is_safe_acclimatization', 'suggested_cash_npr', 'calculated_safety_json',
            'algorithm_used', 'execution_steps',
            'status', 'activities',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'execution_steps']

    def _build_route_stops(self, obj):
        activity_stops = list(
            obj.activities.order_by('day_number', 'sequence_order').values('name', 'altitude')
        )
        if activity_stops:
            return activity_stops

        route_stops = list(
            TrekRoute.objects.filter(destination=obj.destination)
            .order_by('sequence_order')
            .values('location_name', 'altitude')
        )
        if route_stops:
            normalized = []
            for stop in route_stops:
                normalized.append(
                    {
                        'name': stop.get('location_name') or obj.destination.name,
                        'altitude': stop.get('altitude', 0),
                    }
                )
            return normalized

        return [{'name': obj.destination.name, 'altitude': obj.destination.altitude}]

    def _analyze_safety_and_finance(self, obj):
        nationality = 'Foreigner'
        if hasattr(obj.user, 'profile') and obj.user.profile.nationality == 'NEPALI':
            nationality = 'Nepali'

        return analyze_trek_safety_and_finance(
            route_stops=self._build_route_stops(obj),
            nationality=nationality,
        )

    def _extract_altitude_sequence(self, obj):
        altitudes = list(
            obj.activities.order_by('day_number', 'sequence_order').values_list('altitude', flat=True)
        )
        if altitudes:
            return altitudes

        route_altitudes = list(
            TrekRoute.objects.filter(destination=obj.destination)
            .order_by('sequence_order')
            .values_list('altitude', flat=True)
        )
        if route_altitudes:
            return route_altitudes

        return [obj.destination.altitude]

    def get_is_safe_acclimatization(self, obj):
        altitudes = self._extract_altitude_sequence(obj)
        return TripPlannerService.is_safe_acclimatization(altitudes)

    def get_is_safe(self, obj):
        if obj.calculated_safety_json:
            return bool(obj.calculated_safety_json.get('is_safe', True))
        result = self._analyze_safety_and_finance(obj)
        return bool(result.get('is_safe', True))

    def get_safety_warnings(self, obj):
        if obj.calculated_safety_json:
            return list(obj.calculated_safety_json.get('safety_warnings', []))
        result = self._analyze_safety_and_finance(obj)
        return list(result.get('safety_warnings', []))

    def get_cash_recommendation_npr(self, obj):
        if obj.calculated_safety_json:
            return float(obj.calculated_safety_json.get('cash_required_npr', 0))
        result = self._analyze_safety_and_finance(obj)
        return float(result.get('cash_required_npr', 0))

    def get_suggested_cash_npr(self, obj):
        duration_days = max(int(obj.total_duration_days or 1), 1)
        people = max(int(obj.number_of_people or 1), 1)
        return TripPlannerService.calculate_cash_required_npr(
            duration_days=duration_days,
            number_of_people=people,
            base_cost=Decimal(obj.base_cost),
            permit_cost=Decimal(obj.permit_cost),
        )


# Request/Response Serializers for Optimization Endpoints

class CostBreakdownRequestSerializer(serializers.Serializer):
    """Request body for /api/cost-breakdown/ endpoint"""
    destination_id = serializers.IntegerField()
    duration_days = serializers.IntegerField(min_value=2, max_value=5)
    number_of_people = serializers.IntegerField(min_value=1, max_value=30)
    nationality = serializers.ChoiceField(choices=['NEPALI', 'INTERNATIONAL'], default='INTERNATIONAL')
    include_guide = serializers.BooleanField(default=False)
    selected_guide_id = serializers.IntegerField(required=False, allow_null=True)
    include_porter = serializers.BooleanField(default=False)
    number_of_porters = serializers.IntegerField(min_value=0, default=0)
    selected_detour_ids = serializers.ListField(child=serializers.IntegerField(), required=False, default=list)


class CostBreakdownResponseSerializer(serializers.Serializer):
    """Response format for cost breakdown"""
    base_cost = serializers.DecimalField(max_digits=12, decimal_places=2)
    permit_cost = serializers.DecimalField(max_digits=12, decimal_places=2)
    guide_cost = serializers.DecimalField(max_digits=12, decimal_places=2)
    porter_cost = serializers.DecimalField(max_digits=12, decimal_places=2)
    detour_cost = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_cost = serializers.DecimalField(max_digits=12, decimal_places=2)
    cost_per_person = serializers.DecimalField(max_digits=12, decimal_places=2)
    cost_breakdown = serializers.DictField()
    selected_detours = DetourSerializer(many=True)
    total_duration_days = serializers.IntegerField()
    suggested_cash_npr = serializers.DecimalField(max_digits=12, decimal_places=2)
    execution_steps = serializers.ListField(child=serializers.CharField())


class WeatherRiskRequestSerializer(serializers.Serializer):
    """Request for /api/weather-risk/ endpoint"""
    destination_id = serializers.IntegerField()
    date = serializers.DateField(required=False)


class WeatherRiskResponseSerializer(serializers.Serializer):
    """Response format for weather risk assessment"""
    risk_level = serializers.CharField()  # 'LOW', 'MEDIUM', 'HIGH'
    factors = serializers.DictField()
    recommendations = serializers.ListField(child=serializers.CharField())
    weather_data = serializers.DictField()
    execution_steps = serializers.ListField(child=serializers.CharField())


class TripPlannerOptimizeRequestSerializer(serializers.Serializer):
    """Request for /api/optimize-trip/ endpoint (Knapsack)"""
    destination_id = serializers.IntegerField()
    max_budget_usd = serializers.DecimalField(max_digits=10, decimal_places=2, min_value=100)
    max_days = serializers.IntegerField(min_value=2, max_value=5)
    number_of_people = serializers.IntegerField(min_value=1, max_value=30)
    nationality = serializers.ChoiceField(choices=['NEPALI', 'INTERNATIONAL'], default='INTERNATIONAL')
    include_guide = serializers.BooleanField(default=False)
    selected_guide_id = serializers.IntegerField(required=False, allow_null=True)
    include_porter = serializers.BooleanField(default=False)


class TripPlannerOptimizeResponseSerializer(serializers.Serializer):
    """Response format for optimized trip"""
    itinerary = TrekItinerarySerializer()
    algorithm_used = serializers.CharField()
    optimization_metrics = serializers.DictField()
    execution_steps = serializers.ListField(child=serializers.CharField())


class AlgorithmVisualizerRequestSerializer(serializers.Serializer):
    """Request for algorithm visualization"""
    algorithm = serializers.ChoiceField(choices=['binary_search', 'linear_search', 'quicksort', 'mergesort', 'dijkstra', 'knapsack'])
    items = serializers.ListField(child=serializers.DictField())
    search_query = serializers.CharField(required=False, allow_blank=True)
    sort_key = serializers.CharField(required=False, default='price')


class AlgorithmVisualizerResponseSerializer(serializers.Serializer):
    """Response with algorithm execution steps"""
    algorithm = serializers.CharField()
    result = serializers.DictField()
    execution_steps = serializers.ListField(child=serializers.CharField())
    metrics = serializers.DictField()  # {iterations, comparisons, time_complexity, space_complexity}
