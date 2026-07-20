import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminBottomNavigation extends StatelessWidget {
  const AdminBottomNavigation({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: index,
    onDestinationSelected: (i) => context.go(
      [
        '/admin/dashboard',
        '/admin/movies',
        '/admin/showtimes',
        '/admin/bookings',
        '/admin/management',
      ][i],
    ),
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        label: 'Dashboard',
      ),
      NavigationDestination(icon: Icon(Icons.movie_outlined), label: 'Phim'),
      NavigationDestination(
        icon: Icon(Icons.schedule_outlined),
        label: 'Suất chiếu',
      ),
      NavigationDestination(
        icon: Icon(Icons.confirmation_num_outlined),
        label: 'Booking',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        label: 'Quản lý',
      ),
    ],
  );
}
