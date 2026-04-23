import 'package:flutter/foundation.dart';

class ApiConfig {
  // 🔧 IMPORTANT: Set API_BASE_URL via run-app.ps1 which auto-detects your laptop's LAN IP
  // Example: API_BASE_URL='http://192.168.1.8:8000/api'
  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL');
  static const String _localWebBaseUrl = 'http://127.0.0.1:8000/api';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000/api';
  static const bool _forceLanForAndroid = bool.fromEnvironment(
    'FORCE_LAN_FOR_ANDROID',
    defaultValue: true,
  );
  static const bool _useAndroidEmulatorHost = bool.fromEnvironment(
    'USE_ANDROID_EMULATOR_HOST',
    defaultValue: false,
  );

  // Fallback to localhost if no env variable (for web/emulator)
  static String get _deviceBaseUrl => 'http://127.0.0.1:8000/api';

  static String get _lanBaseUrl =>
      _apiBaseUrlOverride.isNotEmpty ? _apiBaseUrlOverride : _deviceBaseUrl;

  static String get baseUrl {
    if (kIsWeb) {
      return _localWebBaseUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (_forceLanForAndroid) {
        return _lanBaseUrl;
      }
      if (_useAndroidEmulatorHost) {
        return _androidEmulatorBaseUrl;
      }
    }
    return _apiBaseUrlOverride.isNotEmpty
        ? _apiBaseUrlOverride
        : _deviceBaseUrl;
  }

  // Endpoints
  static String get login => '$baseUrl/auth/login/';
  static String get register => '$baseUrl/auth/register/';
  static String get logout => '$baseUrl/auth/logout/';
  static String get profile => '$baseUrl/auth/profile/';
  static String get forgotPassword => '$baseUrl/auth/forgot-password/';
  static String get verifyOtp => '$baseUrl/auth/verify-otp/';
  static String get resetPassword => '$baseUrl/auth/reset-password/';
  static String get changePassword => '$baseUrl/auth/change-password/';

  static String get destinations => '$baseUrl/destinations/';
  static String destinationDetail(int id) => '$baseUrl/destinations/$id/';
  static String destinationRoute(int id) => '$baseUrl/destinations/$id/route/';
  static String destinationWeather(int id) =>
      '$baseUrl/destinations/$id/weather/';

  static String get bookings => '$baseUrl/bookings/';
  static String get reviews => '$baseUrl/reviews/';
  static String get tripPlanner => '$baseUrl/algorithms/trip-planner/';
  static String get itineraryCreate => '$baseUrl/itinerary/create/';
  static String get itineraryOptimize => '$baseUrl/itinerary/optimize/';
  static String get weatherRisk => '$baseUrl/weather/risk/';
  static String get notifications => '$baseUrl/notifications/';
  static String get notificationsUnreadCount =>
      '$baseUrl/notifications/unread_count/';
  static String get notificationsMarkAllRead =>
      '$baseUrl/notifications/mark_all_read/';
}
