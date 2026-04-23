import 'package:flutter/material.dart';

final RegExp _emailRegex =
    RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
final RegExp _nameRegex = RegExp(r'^[A-Za-z]{2,10}$');
final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_.-]{2,}$');
final RegExp _usernameAllDigits = RegExp(r'^\d+$');
final RegExp _passwordUppercase = RegExp(r'[A-Z]');
final RegExp _passwordNumber = RegExp(r'\d');
final RegExp _passwordSpecial = RegExp(r'[^\w\s]');
final RegExp _phoneRegex = RegExp(r'^\+?[0-9\-\s]{7,20}$');

String? validateName(String? value, String fieldName) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return '$fieldName is required';
  }
  if (trimmed.length < 2 || trimmed.length > 10) {
    return '$fieldName must be 2 to 10 letters';
  }
  if (!_nameRegex.hasMatch(trimmed)) {
    return '$fieldName can only contain letters';
  }
  return null;
}

String? validateUsername(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Username is required';
  }
  if (trimmed.length < 2) {
    return 'Username must be at least 2 characters';
  }
  if (!_usernameRegex.hasMatch(trimmed)) {
    return 'Username can only contain letters, numbers, ., _, and -';
  }
  if (_usernameAllDigits.hasMatch(trimmed)) {
    return 'Username cannot be only numbers';
  }
  return null;
}

String? validateEmail(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Email is required';
  }
  if (!_emailRegex.hasMatch(trimmed)) {
    return 'Please enter a valid email address';
  }
  return null;
}

String? validatePassword(String? value, {bool requireStrong = true}) {
  final password = value ?? '';
  if (password.isEmpty) {
    return 'Password is required';
  }
  if (password.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!requireStrong) {
    return null;
  }
  if (!_passwordUppercase.hasMatch(password)) {
    return 'Password needs at least one uppercase letter';
  }
  if (!_passwordNumber.hasMatch(password)) {
    return 'Password needs at least one number';
  }
  if (!_passwordSpecial.hasMatch(password)) {
    return 'Password needs at least one special character';
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  final confirm = value ?? '';
  if (confirm.isEmpty) {
    return 'Please confirm your password';
  }
  if (confirm != password) {
    return 'Passwords do not match';
  }
  return null;
}

String? validateContactNumber(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Contact number is required';
  }
  if (!_phoneRegex.hasMatch(trimmed)) {
    return 'Please enter a valid contact number';
  }
  return null;
}

String? validateAddress(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return 'Address is required';
  }
  if (trimmed.length < 5) {
    return 'Address must be at least 5 characters';
  }
  return null;
}
