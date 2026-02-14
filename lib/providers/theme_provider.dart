import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app theme (light/dark mode)
class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadThemePreference();
  }

  /// Load saved theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);

      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
          default:
            _themeMode = ThemeMode.dark;
        }
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemePreference(String theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, theme);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Set theme to light mode
  void setLightMode() {
    _themeMode = ThemeMode.light;
    notifyListeners();
    unawaited(_saveThemePreference('light'));
  }

  /// Set theme to dark mode
  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
    unawaited(_saveThemePreference('dark'));
  }

  /// Set theme to system default
  void setSystemMode() {
    _themeMode = ThemeMode.system;
    notifyListeners();
    unawaited(_saveThemePreference('system'));
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setLightMode();
    } else {
      setDarkMode();
    }
  }

  /// Set theme mode directly
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    unawaited(_saveThemePreference(modeString));
  }
}
