import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_endpoints.dart';

/// Local Settings & Preferences Storage Service
class LocalStorageService {
  static const String _keyBaseUrl = 'pref_base_url';
  static const String _keyThemeMode = 'pref_theme_mode';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  /// Get configured base URL or default
  String getBaseUrl() {
    return _prefs.getString(_keyBaseUrl) ?? ApiEndpoints.defaultBaseUrl;
  }

  Future<void> setBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url);
  }

  /// Get ThemeMode
  ThemeMode getThemeMode() {
    final mode = _prefs.getString(_keyThemeMode);
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_keyThemeMode, mode.name);
  }
}
