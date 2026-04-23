from django.contrib import admin
from .models import (
    Destination, TrekRoute, WeatherCache, UserProfile,
    Booking, Review, TrekDestination, PasswordResetOTP,
    Notification
)


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'full_name', 'contact_number', 'gender']
    list_filter = ['gender']
    search_fields = ['user__username', 'full_name', 'contact_number', 'address']


@admin.register(Destination)
class DestinationAdmin(admin.ModelAdmin):
    list_display = ['name', 'location', 'altitude', 'difficulty', 'price', 'featured']
    list_filter = ['difficulty', 'featured', 'best_season']
    search_fields = ['name', 'location', 'description']
    list_editable = ['featured']


@admin.register(TrekRoute)
class TrekRouteAdmin(admin.ModelAdmin):
    list_display = ['destination', 'sequence_order', 'location_name', 'altitude']
    list_filter = ['destination']
    ordering = ['destination', 'sequence_order']


@admin.register(WeatherCache)
class WeatherCacheAdmin(admin.ModelAdmin):
    list_display = ['destination', 'temperature', 'weather_condition', 'risk_level', 'cached_at']
    list_filter = ['risk_level', 'has_rain_warning', 'has_snow_warning']


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ['user', 'destination', 'start_date', 'number_of_people', 'status']
    list_filter = ['status', 'start_date']
    search_fields = ['user__username', 'destination__name']
    list_editable = ['status']


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ['user', 'destination', 'rating', 'image', 'created_at']
    list_filter = ['rating', 'created_at']
    search_fields = ['user__username', 'destination__name', 'comment']


@admin.register(TrekDestination)
class TrekDestinationAdmin(admin.ModelAdmin):
    list_display = ['name', 'cost', 'duration_days', 'rating', 'difficulty']
    list_filter = ['difficulty']
    search_fields = ['name']


@admin.register(PasswordResetOTP)
class PasswordResetOTPAdmin(admin.ModelAdmin):
    list_display = ['user', 'otp_code', 'expires_at', 'is_used', 'created_at']
    list_filter = ['is_used', 'created_at']
    search_fields = ['user__username', 'user__email', 'otp_code']


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ['user', 'title', 'is_read', 'created_at']
    list_filter = ['is_read', 'created_at']
    search_fields = ['user__username', 'title', 'message']
