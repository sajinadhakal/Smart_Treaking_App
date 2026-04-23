from rest_framework import viewsets, status, filters, serializers
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.core.mail import send_mail
from django.db.models import Avg, Count
from django.db.models.functions import Coalesce
from django.shortcuts import get_object_or_404
from django.utils import timezone
from datetime import timedelta
import requests
import secrets
import string
from django.conf import settings

from .models import (
    Destination, TrekRoute, WeatherCache,
    Booking, Review, PasswordResetOTP, Notification
)
from .serializers import (
    UserSerializer, UserRegistrationSerializer,
    DestinationListSerializer, DestinationDetailSerializer,
    TrekRouteSerializer, WeatherCacheSerializer,
    BookingSerializer, ReviewSerializer, ForgotPasswordSerializer,
    ResetPasswordSerializer, ChangePasswordSerializer, NotificationSerializer,
    UserProfileUpdateSerializer
)

# Import algorithm services
from services.searching import SearchingService
from services.sorting import SortingService
from services.graph import GraphService
from services.greedy import GreedyService
from services.dp import DynamicProgrammingService
from services.recommendations import RecommendationService


# Authentication Views
@api_view(['POST'])
@permission_classes([AllowAny])
def register_user(request):
    """Register a new user"""
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)
        return Response({
            'user': UserSerializer(user).data,
            'token': access_token,
            'access': access_token,
            'refresh': str(refresh),
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_user(request):
    """Login user and return JWT tokens"""
    username_or_email = (request.data.get('username') or request.data.get('email') or '').strip()
    password = request.data.get('password')

    if not username_or_email or not password:
        return Response({'error': 'Username/email and password are required'}, status=status.HTTP_400_BAD_REQUEST)

    user = authenticate(username=username_or_email, password=password)

    # Mobile keyboards can auto-capitalize usernames; retry using case-insensitive lookup.
    if not user and '@' not in username_or_email:
        matched_user = User.objects.filter(username__iexact=username_or_email).first()
        if matched_user:
            user = authenticate(username=matched_user.username, password=password)

    if not user and '@' in username_or_email:
        matched_user = User.objects.filter(email__iexact=username_or_email).first()
        if matched_user:
            user = authenticate(username=matched_user.username, password=password)

    if user:
        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)
        return Response({
            'user': UserSerializer(user).data,
            'token': access_token,
            'access': access_token,
            'refresh': str(refresh),
        })
    return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_user(request):
    """Logout user and optionally blacklist refresh token if provided."""
    refresh_token = request.data.get('refresh')
    if refresh_token:
        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
        except Exception:
            return Response({'error': 'Invalid refresh token'}, status=status.HTTP_400_BAD_REQUEST)
    return Response({'message': 'Successfully logged out'})


@api_view(['GET', 'PATCH'])
@permission_classes([IsAuthenticated])
def get_user_profile(request):
    """Get or update current user profile."""
    if request.method == 'GET':
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    serializer = UserProfileUpdateSerializer(
        instance=request.user,
        data=request.data,
        partial=True,
        context={'request': request},
    )
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    user = serializer.save()
    return Response(
        {
            'message': 'Profile updated successfully.',
            'data': UserSerializer(user).data,
        },
        status=status.HTTP_200_OK,
    )


# Destination Views
class DestinationViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for viewing destinations
    list: Get all destinations
    retrieve: Get single destination with full details
    """
    queryset = Destination.objects.all()
    permission_classes = [AllowAny]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'location', 'description']
    ordering_fields = ['price', 'duration_days', 'altitude', 'created_at', 'average_rating']
    ordering = ['-average_rating', 'name']

    def get_queryset(self):
        return Destination.objects.annotate(
            average_rating=Coalesce(Avg('reviews__rating'), 0.0),
            total_reviews=Count('reviews')
        )
    
    def get_serializer_class(self):
        if self.action == 'list':
            return DestinationListSerializer
        return DestinationDetailSerializer
    
    @action(detail=True, methods=['get'])
    def route(self, request, pk=None):
        """Get route coordinates for a destination"""
        destination = self.get_object()
        route_points = destination.route_points.all()
        serializer = TrekRouteSerializer(route_points, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def weather(self, request, pk=None):
        """Get weather data for a destination"""
        destination = self.get_object()
        
        # Check for cached weather data
        cached_weather = destination.weather_data.first()
        if cached_weather and cached_weather.is_cache_valid(settings.WEATHER_CACHE_DURATION):
            serializer = WeatherCacheSerializer(cached_weather)
            return Response(serializer.data)
        
        # Fetch new weather data
        weather_data = fetch_weather_for_destination(destination)
        if weather_data:
            serializer = WeatherCacheSerializer(weather_data)
            return Response(serializer.data)
        
        return Response({'error': 'Unable to fetch weather data'}, 
                       status=status.HTTP_503_SERVICE_UNAVAILABLE)
    
    @action(detail=False, methods=['get'])
    def featured(self, request):
        """Get featured destinations"""
        featured = self.queryset.filter(featured=True)
        serializer = self.get_serializer(featured, many=True)
        return Response(serializer.data)


def fetch_weather_for_destination(destination):
    """
    Fetch weather data from OpenWeatherMap API and cache it
    """
    if not settings.WEATHER_API_KEY:
        # Fallback to Open-Meteo (no API key required) for real weather data.
        weather = fetch_weather_from_open_meteo(destination)
        if weather:
            return weather
        return create_dummy_weather(destination)
    
    try:
        url = f"https://api.openweathermap.org/data/2.5/weather"
        params = {
            'lat': destination.latitude,
            'lon': destination.longitude,
            'appid': settings.WEATHER_API_KEY,
            'units': 'metric'
        }
        
        response = requests.get(url, params=params, timeout=5)
        response.raise_for_status()
        data = response.json()
        
        # Determine risk warnings
        temp = data['main']['temp']
        weather_main = data['weather'][0]['main'].lower()
        
        has_rain = 'rain' in weather_main or 'drizzle' in weather_main
        has_snow = 'snow' in weather_main
        has_altitude_warning = destination.altitude > 4000
        
        # Calculate risk level
        risk_level = 'LOW'
        if has_snow or (has_altitude_warning and temp < 0):
            risk_level = 'HIGH'
        elif has_rain or has_altitude_warning:
            risk_level = 'MEDIUM'
        
        # Delete old cache and create new
        WeatherCache.objects.filter(destination=destination).delete()
        weather_cache = WeatherCache.objects.create(
            destination=destination,
            temperature=temp,
            weather_condition=data['weather'][0]['main'],
            description=data['weather'][0]['description'],
            humidity=data['main']['humidity'],
            wind_speed=data['wind']['speed'],
            has_rain_warning=has_rain,
            has_snow_warning=has_snow,
            has_altitude_warning=has_altitude_warning,
            risk_level=risk_level
        )
        return weather_cache
    
    except Exception as e:
        print(f"Error fetching weather: {e}")
        # Fallback to Open-Meteo before dummy data.
        weather = fetch_weather_from_open_meteo(destination)
        if weather:
            return weather
        return create_dummy_weather(destination)


def fetch_weather_from_open_meteo(destination):
    """Fetch real weather from Open-Meteo API (no API key)."""
    try:
        url = "https://api.open-meteo.com/v1/forecast"
        params = {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
            'current': 'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code,rain,snowfall',
            'timezone': 'auto',
        }

        response = requests.get(url, params=params, timeout=8)
        response.raise_for_status()
        data = response.json()
        current = data.get('current', {})

        temp = float(current.get('temperature_2m', 0))
        humidity = int(float(current.get('relative_humidity_2m', 0)))
        wind_speed = float(current.get('wind_speed_10m', 0))
        rain_mm = float(current.get('rain', 0) or 0)
        snow_mm = float(current.get('snowfall', 0) or 0)
        weather_code = int(current.get('weather_code', 0) or 0)

        condition_map = {
            0: ('Clear', 'Clear sky'),
            1: ('Mainly Clear', 'Mainly clear'),
            2: ('Partly Cloudy', 'Partly cloudy'),
            3: ('Overcast', 'Overcast'),
            45: ('Fog', 'Fog'),
            48: ('Fog', 'Depositing rime fog'),
            51: ('Drizzle', 'Light drizzle'),
            53: ('Drizzle', 'Moderate drizzle'),
            55: ('Drizzle', 'Dense drizzle'),
            61: ('Rain', 'Slight rain'),
            63: ('Rain', 'Moderate rain'),
            65: ('Rain', 'Heavy rain'),
            71: ('Snow', 'Slight snowfall'),
            73: ('Snow', 'Moderate snowfall'),
            75: ('Snow', 'Heavy snowfall'),
            80: ('Rain Showers', 'Slight rain showers'),
            81: ('Rain Showers', 'Moderate rain showers'),
            82: ('Rain Showers', 'Violent rain showers'),
            95: ('Thunderstorm', 'Thunderstorm'),
        }
        weather_condition, description = condition_map.get(weather_code, ('Unknown', 'Weather data available'))

        has_rain = rain_mm > 0 or weather_condition.lower().find('rain') >= 0
        has_snow = snow_mm > 0 or weather_condition.lower().find('snow') >= 0
        has_altitude_warning = destination.altitude > 4000

        risk_level = 'LOW'
        if has_snow or (has_altitude_warning and temp < 0):
            risk_level = 'HIGH'
        elif has_rain or has_altitude_warning or wind_speed > 10:
            risk_level = 'MEDIUM'

        WeatherCache.objects.filter(destination=destination).delete()
        weather_cache = WeatherCache.objects.create(
            destination=destination,
            temperature=temp,
            weather_condition=weather_condition,
            description=description,
            humidity=humidity,
            wind_speed=wind_speed,
            has_rain_warning=has_rain,
            has_snow_warning=has_snow,
            has_altitude_warning=has_altitude_warning,
            risk_level=risk_level,
        )
        return weather_cache
    except Exception as e:
        print(f"Open-Meteo fallback error: {e}")
        return None


def create_dummy_weather(destination):
    """Create dummy weather data for development"""
    WeatherCache.objects.filter(destination=destination).delete()
    
    has_altitude_warning = destination.altitude > 4000
    weather_cache = WeatherCache.objects.create(
        destination=destination,
        temperature=15.5,
        weather_condition='Clear',
        description='clear sky',
        humidity=65,
        wind_speed=3.5,
        has_rain_warning=False,
        has_snow_warning=False,
        has_altitude_warning=has_altitude_warning,
        risk_level='MEDIUM' if has_altitude_warning else 'LOW'
    )
    return weather_cache


# Booking Views
class BookingViewSet(viewsets.ModelViewSet):
    """
    ViewSet for bookings
    """
    serializer_class = BookingSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Booking.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['patch'])
    def cancel(self, request, pk=None):
        booking = self.get_object()
        if booking.status == 'COMPLETED':
            return Response({'error': 'Completed bookings cannot be cancelled.'}, status=status.HTTP_400_BAD_REQUEST)
        booking.status = 'CANCELLED'
        booking.save(update_fields=['status', 'updated_at'])
        return Response(self.get_serializer(booking).data, status=status.HTTP_200_OK)

    @action(detail=True, methods=['patch'])
    def confirm(self, request, pk=None):
        """Admin/Staff action to confirm a booking"""
        booking = self.get_object()
        if booking.status != 'PENDING':
            return Response({'error': 'Only pending bookings can be confirmed.'}, status=status.HTTP_400_BAD_REQUEST)
        booking.status = 'CONFIRMED'
        booking.save(update_fields=['status', 'updated_at'])
        return Response(self.get_serializer(booking).data, status=status.HTTP_200_OK)

    @action(detail=True, methods=['patch'])
    def complete(self, request, pk=None):
        """Mark booking as completed"""
        booking = self.get_object()
        if booking.status not in ['CONFIRMED', 'IN_PROGRESS']:
            return Response({'error': 'Only confirmed or in-progress bookings can be completed.'}, status=status.HTTP_400_BAD_REQUEST)
        booking.status = 'COMPLETED'
        booking.save(update_fields=['status', 'updated_at'])
        return Response(self.get_serializer(booking).data, status=status.HTTP_200_OK)


# Review Views
class ReviewViewSet(viewsets.ModelViewSet):
    """
    ViewSet for reviews
    """
    serializer_class = ReviewSerializer
    parser_classes = [MultiPartParser, FormParser, JSONParser]
    filter_backends = [filters.OrderingFilter]
    ordering_fields = ['rating', 'created_at']
    ordering = ['-rating', '-created_at']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsAuthenticated()]
    
    def get_queryset(self):
        destination_id = self.request.query_params.get('destination_id') or self.request.query_params.get('destination')
        if destination_id:
            return Review.objects.filter(destination_id=destination_id).select_related('user', 'destination').order_by('-rating', '-created_at')
        return Review.objects.select_related('user', 'destination').order_by('-rating', '-created_at')
    
    def perform_create(self, serializer):
        review = serializer.save(user=self.request.user)
        # Notify the user about their review being posted
        Notification.objects.create(
            user=self.request.user,
            title='Review Posted',
            message=f'Your review for {review.destination.name} has been published.'
        )
        # Notify other users following this destination about new review
        other_users = User.objects.filter(
            booking__destination=review.destination
        ).distinct().exclude(id=self.request.user.id)[:10]
        for user in other_users:
            Notification.objects.create(
                user=user,
                title=f'New Review: {review.destination.name}',
                message=f'{self.request.user.username} posted a {review.rating}★ review.'
            )

    def perform_update(self, serializer):
        if serializer.instance.user != self.request.user:
            raise serializers.ValidationError({'error': 'You can only edit your own review.'})
        serializer.save()

    def perform_destroy(self, instance):
        if instance.user != self.request.user:
            raise serializers.ValidationError({'error': 'You can only delete your own review.'})
        instance.delete()


class NotificationViewSet(viewsets.ModelViewSet):
    """
    Notification endpoints for bell badge and notification panel.
    """
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    http_method_names = ['get', 'post', 'patch', 'head', 'options']

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user).order_by('-created_at')

    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        count = Notification.objects.filter(user=request.user, is_read=False).count()
        return Response({'unread_count': count}, status=status.HTTP_200_OK)

    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        updated = Notification.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'message': f'{updated} notifications marked as read.'}, status=status.HTTP_200_OK)

    def partial_update(self, request, *args, **kwargs):
        notification = self.get_object()
        notification.is_read = bool(request.data.get('is_read', True))
        notification.save(update_fields=['is_read'])
        serializer = self.get_serializer(notification)
        return Response(serializer.data, status=status.HTTP_200_OK)


def _generate_otp_code():
    return ''.join(secrets.choice(string.digits) for _ in range(6))


class ForgotPasswordAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        if not serializer.is_valid():
            first_error = next(iter(serializer.errors.values()))[0]
            return Response({'error': str(first_error)}, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        user = User.objects.filter(email__iexact=email).first()
        if not user:
            return Response({'error': 'No account found with this email.'}, status=status.HTTP_404_NOT_FOUND)

        PasswordResetOTP.objects.filter(user=user, is_used=False).update(is_used=True)
        otp_code = _generate_otp_code()
        expires_at = timezone.now() + timedelta(minutes=5)
        otp_record = PasswordResetOTP.objects.create(
            user=user,
            otp_code=otp_code,
            expires_at=expires_at,
        )

        try:
            send_mail(
                subject='Nepal Trekking App - Password Reset OTP',
                message=(
                    f'Your OTP is {otp_code}.\n\n'
                    'Use this 6-digit code within 5 minutes to reset your password.'
                ),
                from_email=getattr(settings, 'DEFAULT_FROM_EMAIL', 'noreply@nepaltrekkingapp.com'),
                recipient_list=[email],
                fail_silently=False,
            )
        except Exception as exc:
            print(f'Password reset email error for user {user.email}: {exc}')
            otp_record.delete()
            return Response(
                {'error': 'Unable to send password reset email. Please try again later.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

        return Response({'message': 'OTP has been sent to your email.'}, status=status.HTTP_200_OK)


class VerifyOTPAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        if not serializer.is_valid():
            first_error = next(iter(serializer.errors.values()))[0]
            return Response({'error': str(first_error)}, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email'].strip().lower()
        otp = serializer.validated_data['otp'].strip()

        user = User.objects.filter(email__iexact=email).first()
        if not user:
            return Response({'error': 'No account found with this email.'}, status=status.HTTP_404_NOT_FOUND)

        otp_record = PasswordResetOTP.objects.filter(
            user=user,
            otp_code=otp,
            is_used=False,
            expires_at__gte=timezone.now(),
        ).order_by('-created_at').first()

        if not otp_record:
            return Response({'error': 'Invalid or expired OTP.'}, status=status.HTTP_400_BAD_REQUEST)

        otp_record.verified_at = timezone.now()
        otp_record.save(update_fields=['verified_at'])

        return Response({'message': 'OTP verified successfully.'}, status=status.HTTP_200_OK)


class ResetPasswordAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        if not serializer.is_valid():
            first_error = next(iter(serializer.errors.values()))[0]
            return Response({'error': str(first_error)}, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email'].strip().lower()
        new_password = serializer.validated_data['new_password']

        user = User.objects.filter(email__iexact=email).first()
        if not user:
            return Response({'error': 'No account found with this email.'}, status=status.HTTP_404_NOT_FOUND)

        otp_record = PasswordResetOTP.objects.filter(
            user=user,
            verified_at__isnull=False,
            is_used=False,
            expires_at__gte=timezone.now(),
        ).order_by('-created_at').first()

        if not otp_record:
            return Response(
                {'error': 'OTP must be verified before resetting password, or the OTP has expired.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user.set_password(new_password)
        user.save(update_fields=['password'])

        PasswordResetOTP.objects.filter(user=user, is_used=False).update(is_used=True)

        return Response({'message': 'Password reset successful.'}, status=status.HTTP_200_OK)


class ChangePasswordAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data)
        if not serializer.is_valid():
            first_error = next(iter(serializer.errors.values()))[0]
            return Response({'error': str(first_error)}, status=status.HTTP_400_BAD_REQUEST)

        old_password = serializer.validated_data['old_password']
        new_password = serializer.validated_data['new_password']

        user = request.user
        if not user.check_password(old_password):
            return Response({'error': 'Old password is incorrect.'}, status=status.HTTP_401_UNAUTHORIZED)

        user.set_password(new_password)
        user.save(update_fields=['password'])

        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)

        return Response(
            {
                'message': 'Password changed successfully.',
                'token': access_token,
                'access': access_token,
                'refresh': str(refresh),
            },
            status=status.HTTP_200_OK,
        )
