import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/preferences_service.dart';
import '../core/services/fcm_service.dart';
import '../features/notifications/providers/fcm_provider.dart';
import '../features/auth/providers/auth_providers.dart';
import '../shared/models/app_user.dart';
import 'app_router.dart';
import 'app_theme.dart';

class MovieBookingApp extends ConsumerStatefulWidget {
  const MovieBookingApp({super.key});
  @override
  ConsumerState<MovieBookingApp> createState() => _MovieBookingAppState();
}

class _MovieBookingAppState extends ConsumerState<MovieBookingApp> {
  late ThemeMode _themeMode;
  GoRouter? _router;
  FcmService? _fcmService;
  @override
  void initState() {
    super.initState();
    _themeMode = ref.read(preferencesServiceProvider).getThemeMode();
    Future.microtask(() async {
      try {
        final service = ref.read(fcmServiceProvider);
        _fcmService = service;
        service.bookingTap.addListener(_handleBookingTap);
        await service.initialize();
      } catch (_) {
        // Firebase/FCM is optional until a real project is configured.
      }
    });
  }

  void _handleBookingTap() {
    final id = _fcmService?.bookingTap.value;
    if (id == null || _router == null) return;
    _fcmService!.bookingTap.value = null;
    final role = ref.read(currentAppUserProvider).value?.role;
    _router!.go(
      role == UserRole.admin ? '/admin/bookings/$id' : '/user/tickets/$id',
    );
  }

  @override
  void dispose() {
    _fcmService?.bookingTap.removeListener(_handleBookingTap);
    super.dispose();
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await ref.read(preferencesServiceProvider).setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    _router = ref.watch(
      routerProvider((
        themeMode: _themeMode,
        onThemeChanged: _setThemeMode,
      )),
    );
    return MaterialApp.router(
      title: 'Movie Booking',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      routerConfig: _router!,
    );
  }
}
