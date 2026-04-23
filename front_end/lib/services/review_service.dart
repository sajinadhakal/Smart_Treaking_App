import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/review.dart';

class ReviewService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['access'];
        if (newToken != null) {
          await _saveToken(newToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  Future<List<Review>> getReviews({
    int? destinationId,
    String ordering = '-rating,-created_at',
  }) async {
    final query = <String>[];
    if (destinationId != null) {
      query.add('destination_id=$destinationId');
    }
    if (ordering.isNotEmpty) {
      query.add('ordering=${Uri.encodeQueryComponent(ordering)}');
    }

    var url = ApiConfig.reviews;
    if (query.isNotEmpty) {
      url = '$url?${query.join('&')}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch reviews: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final List items = decoded is Map<String, dynamic>
        ? (decoded['results'] as List? ?? <dynamic>[])
        : (decoded as List? ?? <dynamic>[]);

    return items
        .map((item) => Review.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Review> createReview({
    required int destinationId,
    required int rating,
    required String comment,
    File? imageFile,
  }) async {
    var token = await _getToken();
    
    // Debug: Check if token exists
    if (token == null || token.trim().isEmpty) {
      throw Exception('Authentication required. Please login first to share your experience.');
    }
    
    print('[ReviewService] Using token: ${token.substring(0, 20)}...');
    
    final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.reviews));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['destination'] = destinationId.toString();
    request.fields['rating'] = rating.toString();
    request.fields['comment'] = comment;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    var streamedResponse = await request.send();
    var responseBody = await streamedResponse.stream.bytesToString();

    // If 401, try to refresh token and retry
    if (streamedResponse.statusCode == 401) {
      print('[ReviewService] Got 401, attempting token refresh...');
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        token = await _getToken();
        print('[ReviewService] Token refreshed, retrying...');
        final retryRequest = http.MultipartRequest('POST', Uri.parse(ApiConfig.reviews));
        retryRequest.headers['Authorization'] = 'Bearer $token';
        retryRequest.headers['Accept'] = 'application/json';
        retryRequest.fields['destination'] = destinationId.toString();
        retryRequest.fields['rating'] = rating.toString();
        retryRequest.fields['comment'] = comment;

        if (imageFile != null) {
          retryRequest.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        }

        streamedResponse = await retryRequest.send();
        responseBody = await streamedResponse.stream.bytesToString();
      } else {
        print('[ReviewService] Token refresh failed');
      }
    }

    if (streamedResponse.statusCode != 201) {
      print('[ReviewService] Error response: ${streamedResponse.statusCode} - $responseBody');
      throw Exception('Failed to create review: ${streamedResponse.statusCode} $responseBody');
    }

    return Review.fromJson(Map<String, dynamic>.from(jsonDecode(responseBody) as Map));
  }

  Future<Review> updateReview({
    required int reviewId,
    required int destinationId,
    required int rating,
    required String comment,
    File? imageFile,
    bool removeImage = false,
  }) async {
    var token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please log in to update your experience.');
    }

    final request = http.MultipartRequest('PUT', Uri.parse('${ApiConfig.reviews}$reviewId/'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['destination'] = destinationId.toString();
    request.fields['rating'] = rating.toString();
    request.fields['comment'] = comment;

    if (removeImage) {
      request.fields['image'] = '';
    } else if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    var streamedResponse = await request.send();
    var responseBody = await streamedResponse.stream.bytesToString();

    // If 401, try to refresh token and retry
    if (streamedResponse.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        token = await _getToken();
        final retryRequest = http.MultipartRequest('PUT', Uri.parse('${ApiConfig.reviews}$reviewId/'));
        retryRequest.headers['Authorization'] = 'Bearer $token';
        retryRequest.fields['destination'] = destinationId.toString();
        retryRequest.fields['rating'] = rating.toString();
        retryRequest.fields['comment'] = comment;

        if (removeImage) {
          retryRequest.fields['image'] = '';
        } else if (imageFile != null) {
          retryRequest.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        }

        streamedResponse = await retryRequest.send();
        responseBody = await streamedResponse.stream.bytesToString();
      }
    }

    if (streamedResponse.statusCode != 200) {
      throw Exception('Failed to update review: ${streamedResponse.statusCode} $responseBody');
    }

    return Review.fromJson(Map<String, dynamic>.from(jsonDecode(responseBody) as Map));
  }

  Future<void> deleteReview(int reviewId) async {
    var token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please log in to delete your experience.');
    }

    var response = await http.delete(
      Uri.parse('${ApiConfig.reviews}$reviewId/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // If 401, try to refresh token and retry
    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        token = await _getToken();
        response = await http.delete(
          Uri.parse('${ApiConfig.reviews}$reviewId/'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    }

    if (response.statusCode != 204) {
      throw Exception('Failed to delete review: ${response.statusCode}');
    }
  }
}
