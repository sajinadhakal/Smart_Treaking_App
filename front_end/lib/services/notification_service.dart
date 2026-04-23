import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/app_notification.dart';
import 'auth_service.dart';

class NotificationService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.notifications),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = (data is Map<String, dynamic>) ? (data['results'] ?? []) : data;
        return (items as List<dynamic>)
            .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to load notifications (${response.statusCode}).');
    } catch (error) {
      throw Exception('Backend notification fetch failed: $error');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.notificationsUnreadCount),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['unread_count'] as num?)?.toInt() ?? 0;
      }

      throw Exception('Unread count failed (${response.statusCode}).');
    } catch (error) {
      throw Exception('Backend unread count failed: $error');
    }
  }

  Future<void> markAllRead() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.notificationsMarkAllRead),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Mark all read failed (${response.statusCode}).');
      }
    } catch (error) {
      throw Exception('Failed to mark notifications as read: $error');
    }
  }
}
