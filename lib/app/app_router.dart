import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/admin_dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/profile_missing_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/rooms/models/cinema_room.dart';
import '../features/movies/presentation/screens/admin_movie_form_screen.dart';
import '../features/movies/presentation/screens/admin_movie_list_screen.dart';
import '../features/showtimes/presentation/screens/admin_showtime_form_screen.dart';
import '../features/showtimes/presentation/screens/admin_showtime_list_screen.dart';
import '../features/concessions/presentation/screens/admin_product_list_screen.dart';
import '../features/concessions/presentation/screens/admin_product_form_screen.dart';
import '../features/concessions/presentation/screens/admin_combo_list_screen.dart';
import '../features/concessions/presentation/screens/admin_combo_form_screen.dart';
import '../features/vouchers/presentation/screens/admin_voucher_list_screen.dart';
import '../features/vouchers/presentation/screens/admin_voucher_form_screen.dart';
import '../features/rooms/presentation/screens/admin_room_form_screen.dart';
import '../features/rooms/presentation/screens/admin_room_list_screen.dart';
import '../features/rooms/presentation/screens/room_detail_screen.dart';
import '../features/user_home/presentation/screens/user_home_screen.dart';
import '../shared/models/app_user.dart';

GoRouter createAppRouter({
  required ThemeMode themeMode,
  required ValueChanged<ThemeMode> onThemeChanged,
  User? firebaseUser,
  AppUser? appUser,
  bool authLoading = false,
  bool profileLoading = false,
  bool authError = false,
  bool profileError = false,
}) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute =
          path == '/login' || path == '/register' || path == '/forgot-password';
      if (authError) {
        return isAuthRoute ? null : '/login';
      }
      if (authLoading) return path == '/splash' ? null : '/splash';
      if (firebaseUser == null) return isAuthRoute ? null : '/login';
      if (profileLoading) return path == '/splash' ? null : '/splash';
      if (profileError || appUser == null) {
        return path == '/profile-missing' ? null : '/profile-missing';
      }
      if (isAuthRoute || path == '/splash' || path == '/profile-missing') {
        return appUser.role == UserRole.admin
            ? '/admin/dashboard'
            : '/user/home';
      }
      if (appUser.role == UserRole.admin && path.startsWith('/user')) {
        return '/admin/dashboard';
      }
      if (appUser.role == UserRole.user && path.startsWith('/admin')) {
        return '/user/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginScreen(themeMode: themeMode, onThemeChanged: onThemeChanged),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/profile-missing',
        builder: (context, state) => const ProfileMissingScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/user/home',
        builder: (context, state) => const UserHomeScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/rooms',
        builder: (context, state) => const AdminRoomListScreen(),
      ),
      GoRoute(
        path: '/admin/movies',
        builder: (context, state) => const AdminMovieListScreen(),
      ),
      GoRoute(
        path: '/admin/movies/new',
        builder: (context, state) => const AdminMovieFormScreen(),
      ),
      GoRoute(
        path: '/admin/movies/:movieId/edit',
        builder: (context, state) =>
            AdminMovieFormScreen(movieId: state.pathParameters['movieId']),
      ),
      GoRoute(
        path: '/admin/showtimes',
        builder: (context, state) => const AdminShowtimeListScreen(),
      ),
      GoRoute(
        path: '/admin/showtimes/new',
        builder: (context, state) => const AdminShowtimeFormScreen(),
      ),
      GoRoute(
        path: '/admin/showtimes/:showtimeId/edit',
        builder: (context, state) => AdminShowtimeFormScreen(
          showtimeId: state.pathParameters['showtimeId'],
        ),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (context, state) => const AdminProductListScreen(),
      ),
      GoRoute(
        path: '/admin/products/new',
        builder: (context, state) => const AdminProductFormScreen(),
      ),
      GoRoute(
        path: '/admin/products/:productId/edit',
        builder: (context, state) => AdminProductFormScreen(
          productId: state.pathParameters['productId'],
        ),
      ),
      GoRoute(
        path: '/admin/combos',
        builder: (context, state) => const AdminComboListScreen(),
      ),
      GoRoute(
        path: '/admin/combos/new',
        builder: (context, state) => const AdminComboFormScreen(),
      ),
      GoRoute(
        path: '/admin/combos/:comboId/edit',
        builder: (context, state) =>
            AdminComboFormScreen(comboId: state.pathParameters['comboId']),
      ),
      GoRoute(
        path: '/admin/vouchers',
        builder: (context, state) => const AdminVoucherListScreen(),
      ),
      GoRoute(
        path: '/admin/vouchers/new',
        builder: (context, state) => const AdminVoucherFormScreen(),
      ),
      GoRoute(
        path: '/admin/vouchers/:voucherId/edit',
        builder: (context, state) => AdminVoucherFormScreen(
          voucherId: state.pathParameters['voucherId'],
        ),
      ),
      GoRoute(
        path: '/admin/rooms/new',
        builder: (context, state) => const AdminRoomFormScreen(),
      ),
      GoRoute(
        path: '/admin/rooms/:roomId/edit',
        builder: (context, state) =>
            AdminRoomFormScreen(roomId: state.pathParameters['roomId']),
      ),
      GoRoute(
        path: '/admin/rooms/:roomId',
        builder: (context, state) {
          final room = state.extra;
          return room is CinemaRoom
              ? RoomDetailScreen(room: room)
              : const Scaffold(
                  body: Center(child: Text('Không tìm thấy phòng.')),
                );
        },
      ),
    ],
  );
}
