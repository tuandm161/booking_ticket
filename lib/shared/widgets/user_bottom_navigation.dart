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
    return Container(
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
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Tìm kiếm',
          ),
          const NavigationDestination(
            icon: Icon(Icons.confirmation_num_outlined),
            selectedIcon: Icon(Icons.confirmation_num),
            label: 'Vé của tôi',
          ),
          NavigationDestination(
            icon: unread > 0
                ? Badge(
                    label: Text('$unread'),
                    child: const Icon(Icons.notifications_none_rounded),
                  )
                : const Icon(Icons.notifications_none_rounded),
            selectedIcon: unread > 0
                ? Badge(
                    label: Text('$unread'),
                    child: const Icon(Icons.notifications_rounded),
                  )
                : const Icon(Icons.notifications_rounded),
            label: 'Thông báo',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
