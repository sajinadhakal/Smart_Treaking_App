import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MountainModeProvider extends ChangeNotifier {
  static const String _prefsKey = 'mountain_mode_enabled';

  bool _enabled = false;

  bool get enabled => _enabled;
  bool get disableImageLoading => _enabled;
  bool get reduceMotion => _enabled;

  Future<void> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefsKey) ?? false;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    if (_enabled == value) return;
    _enabled = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
    notifyListeners();
  }
}
