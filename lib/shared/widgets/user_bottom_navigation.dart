import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserBottomNavigation extends StatelessWidget {
  const UserBottomNavigation({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: index,
    onDestinationSelected: (i) {
      final paths = [
        '/user/home',
        '/user/search',
        '/user/tickets',
        '/user/notifications',
        '/user/profile',
      ];
      context.go(paths[i]);
    },
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        label: 'Trang chủ',
      ),
      NavigationDestination(icon: Icon(Icons.search), label: 'Tìm kiếm'),
      NavigationDestination(
        icon: Icon(Icons.confirmation_num_outlined),
        label: 'Vé của tôi',
      ),
      NavigationDestination(
        icon: Icon(Icons.notifications_none),
        label: 'Thông báo',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        label: 'Tài khoản',
      ),
    ],
  );
}
