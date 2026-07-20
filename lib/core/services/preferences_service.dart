import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

final preferencesServiceProvider = Provider<PreferencesService>(
  (_) => throw UnimplementedError(),
);

class PreferencesService {
  const PreferencesService(this._preferences);
  final SharedPreferences _preferences;

  ThemeMode getThemeMode() {
    return switch (_preferences.getString(AppConstants.themeModeKey)) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _preferences.setString(AppConstants.themeModeKey, mode.name);
  bool get onboardingCompleted =>
      _preferences.getBool(AppConstants.onboardingCompletedKey) ?? false;
}
