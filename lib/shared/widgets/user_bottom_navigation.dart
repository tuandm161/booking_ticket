import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firebase_providers.dart';
import '../../features/notifications/providers/notification_providers.dart';

class UserBottomNavigation extends ConsumerWidget {
  const UserBottomNavigation({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final unread = uid == null
        ? 0
        : ref
              .watch(unreadNotificationCountProvider)
              .maybeWhen(data: (count) => count, orElse: () => 0);
    return NavigationBar(
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
      destinations: [
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
          icon: unread > 0
              ? Badge(
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_none),
                )
              : const Icon(Icons.notifications_none),
          label: 'Thông báo',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Tài khoản',
        ),
      ],
    );
  }
}
