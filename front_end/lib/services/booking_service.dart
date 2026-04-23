import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/booking.dart';
import 'auth_service.dart';

class BookingService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Booking>> getMyBookings() async {

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.bookings),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        return (results as List)
            .map((json) => Booking.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  Future<Booking?> createBooking(Booking booking) async {

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.bookings),
        headers: await _getHeaders(),
        body: jsonEncode(booking.toJson()),
      );

      if (response.statusCode == 201) {
        return Booking.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  Future<Booking?> updateBooking(int bookingId, Booking booking) async {

    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.bookings}$bookingId/'),
        headers: await _getHeaders(),
        body: jsonEncode(booking.toJson()),
      );

      if (response.statusCode == 200) {
        return Booking.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error updating booking: $e');
      return null;
    }
  }

  Future<Booking?> cancelBooking(int bookingId) async {

    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.bookings}$bookingId/cancel/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Booking.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error cancelling booking: $e');
      return null;
    }
  }

  Future<bool> deleteBooking(int bookingId) async {

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.bookings}$bookingId/'),
        headers: await _getHeaders(),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting booking: $e');
      return false;
    }
  }
}
