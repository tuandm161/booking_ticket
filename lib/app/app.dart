import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/preferences_service.dart';
import '../features/auth/providers/auth_providers.dart';
import 'app_router.dart';
import 'app_theme.dart';

class MovieBookingApp extends ConsumerStatefulWidget {
  const MovieBookingApp({super.key});
  @override
  ConsumerState<MovieBookingApp> createState() => _MovieBookingAppState();
}

class _MovieBookingAppState extends ConsumerState<MovieBookingApp> {
  late ThemeMode _themeMode;
  @override
  void initState() {
    super.initState();
    _themeMode = ref.read(preferencesServiceProvider).getThemeMode();
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await ref.read(preferencesServiceProvider).setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firebaseAuthStateProvider);
    final appUser = ref.watch(currentAppUserProvider);
    return MaterialApp.router(
      title: 'Movie Booking',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      routerConfig: createAppRouter(
        themeMode: _themeMode,
        onThemeChanged: _setThemeMode,
        firebaseUser: authState.value,
        appUser: appUser.value,
        authLoading: authState.isLoading,
        profileLoading: appUser.isLoading,
        authError: authState.hasError,
        profileError: appUser.hasError,
      ),
    );
  }
}
