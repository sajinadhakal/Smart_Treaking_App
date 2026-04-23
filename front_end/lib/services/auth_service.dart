import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<bool> hasValidToken() async {
    final token = await getToken();
    if (token == null || token.trim().isEmpty) {
      return false;
    }

    final isJwt = token.split('.').length == 3;
    if (!isJwt) {
      return true;
    }

    try {
      final payload = token.split('.')[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = payloadMap['exp'];
      if (exp == null) {
        return true;
      }
      final expiration =
          DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000, isUtc: true);
      return expiration.isAfter(DateTime.now().toUtc());
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    String firstName = '',
    String lastName = '',
    String fullName = '',
    String address = '',
    String contactNumber = '',
    String gender = 'OTHER',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.register),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'email': email,
              'password': password,
              'password_confirm': passwordConfirm,
              'first_name': firstName,
              'last_name': lastName,
              'full_name': fullName,
              'address': address,
              'contact_number': contactNumber,
              'gender': gender,
            }),
          )
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => throw SocketException(
                'Connection timeout - Backend unreachable at ${ApiConfig.baseUrl}'),
          );

      if (response.statusCode == 201) {
        final data = _tryDecodeJson(response.body);
        if (data is! Map<String, dynamic>) {
          return {
            'success': false,
            'error': 'Server returned an invalid response format.'
          };
        }
        await saveToken(data['token']);
        if (data['refresh'] != null) {
          await saveRefreshToken(data['refresh']);
        }
        await saveUser(User.fromJson(data['user']));
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        final error = _tryDecodeJson(response.body) ?? response.body;
        return {'success': false, 'error': _extractApiError(error)};
      }
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'Socket Error: Cannot reach backend server.\n\n'
            'Check:\n'
            '1. Backend is running (run `run-backend.ps1`)\n'
            '2. Phone is on same WiFi as laptop\n'
            '3. Start the app with `front_end\\run-app.ps1` so API_BASE_URL uses the current LAN IP\n'
            '4. Backend URL currently in use: ${ApiConfig.baseUrl}\n\n'
            'Error: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection Error: ${e.toString()}\n\n'
            'Check that backend is running at ${ApiConfig.baseUrl} and that your phone is on the same network'
      };
    }
  }

  String _extractApiError(dynamic payload) {
    if (payload is String && payload.trim().isNotEmpty) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      for (final value in payload.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }
    }

    return 'Request failed. Please check your details and try again.';
  }

  dynamic _tryDecodeJson(String body) {
    if (body.trim().isEmpty) {
      return null;
    }
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => throw SocketException(
                'Connection timeout - Backend unreachable at ${ApiConfig.baseUrl}'),
          );

      if (response.statusCode == 200) {
        final data = _tryDecodeJson(response.body);
        if (data is! Map<String, dynamic>) {
          return {
            'success': false,
            'error': 'Server returned an invalid response format.'
          };
        }
        await saveToken(data['token']);
        if (data['refresh'] != null) {
          await saveRefreshToken(data['refresh']);
        }
        await saveUser(User.fromJson(data['user']));
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        final error = _tryDecodeJson(response.body) ?? response.body;
        return {'success': false, 'error': _extractApiError(error)};
      }
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'Socket Error: Cannot reach backend server.\n\n'
            'Check:\n'
            '1. Backend is running (run `run-backend.ps1`)\n'
            '2. Phone is on same WiFi as laptop\n'
            '3. Start the app with `front_end\\run-app.ps1` so API_BASE_URL uses the current LAN IP\n'
            '4. Backend URL currently in use: ${ApiConfig.baseUrl}\n\n'
            'Error: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection Error: ${e.toString()}\n\n'
            'Check that backend is running at ${ApiConfig.baseUrl} and that your phone is on the same network'
      };
    }
  }

  Future<bool> logout() async {
    try {
      final token = await getToken();
      final refreshToken = await getRefreshToken();
      if (token != null) {
        await http.post(
          Uri.parse(ApiConfig.logout),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'refresh': refreshToken}),
        );
      }
      await clearAuth();
      return true;
    } catch (e) {
      await clearAuth();
      return false;
    }
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.forgotPassword),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email.trim()}),
      );

      final data = _tryDecodeJson(response.body);
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent successfully.'
        };
      }
      return {
        'success': false,
        'error': data is Map<String, dynamic>
            ? data['error'] ?? 'Failed to send OTP.'
            : 'Invalid server response: ${response.body}'
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyOtp),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'otp': otpCode.trim(),
        }),
      );

      final data = _tryDecodeJson(response.body);
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully.'
        };
      }
      return {
        'success': false,
        'error': data is Map<String, dynamic>
            ? data['error'] ?? 'Failed to verify OTP.'
            : 'Invalid server response: ${response.body}'
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.resetPassword),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'new_password': newPassword,
        }),
      );

      final data = _tryDecodeJson(response.body);
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset successful.'
        };
      }
      return {
        'success': false,
        'error': data is Map<String, dynamic>
            ? data['error'] ?? 'Failed to reset password.'
            : 'Invalid server response: ${response.body}'
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'You are not logged in.'};
      }

      final response = await http.post(
        Uri.parse(ApiConfig.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if (response.statusCode == 200) {
        final newToken = data['token'];
        if (newToken is String && newToken.isNotEmpty) {
          await saveToken(newToken);
        }
        final newRefresh = data['refresh'];
        if (newRefresh is String && newRefresh.isNotEmpty) {
          await saveRefreshToken(newRefresh);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully.'
        };
      }
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to change password.'
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String fullName = '',
    String address = '',
    String contactNumber = '',
    String gender = 'OTHER',
  }) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'error': 'You are not logged in.'};
      }

      final response = await http.patch(
        Uri.parse(ApiConfig.profile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'email': email.trim(),
          'full_name': fullName.trim(),
          'address': address.trim(),
          'contact_number': contactNumber.trim(),
          'gender': gender,
        }),
      );

      final data = _tryDecodeJson(response.body);
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        final dynamic payload = data['data'] ?? data['user'] ?? data;
        if (payload is Map<String, dynamic>) {
          final updatedUser = User.fromJson(payload);
          await saveUser(updatedUser);
          return {
            'success': true,
            'message': data['message'] ?? 'Profile updated successfully.',
            'user': updatedUser,
          };
        }
      }

      return {
        'success': false,
        'error': _extractApiError(data ?? response.body),
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
