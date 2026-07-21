import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminBottomNavigation extends StatelessWidget {
  const AdminBottomNavigation({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: .28),
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .14),
          blurRadius: 18,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: NavigationBar(
      selectedIndex: index,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Tổng quan',
        ),
        NavigationDestination(
          icon: Icon(Icons.movie_outlined),
          selectedIcon: Icon(Icons.movie_rounded),
          label: 'Phim',
        ),
        NavigationDestination(
          icon: Icon(Icons.schedule_outlined),
          selectedIcon: Icon(Icons.schedule_rounded),
          label: 'Suất chiếu',
        ),
        NavigationDestination(
          icon: Icon(Icons.confirmation_num_outlined),
          selectedIcon: Icon(Icons.confirmation_num),
          label: 'Booking',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Quản lý',
        ),
      ],
    ),
  );
}
