import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  Future<void> bootstrapAuth() async {
    final hasValidToken = await _authService.hasValidToken();
    _status = hasValidToken ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  void markLoggedIn() {
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
