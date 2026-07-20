// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../../../core/services/firebase_providers.dart';
import '../../providers/notification_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myNotificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: () {
              final uid = ref.read(notificationRepositoryProvider);
              final userId = ref.read(firebaseAuthProvider).currentUser?.uid;
              if (userId != null) uid.markAllAsRead(userId);
            },
            child: const Text('Đọc tất cả'),
          ),
        ],
      ),
      bottomNavigationBar: const UserBottomNavigation(index: 3),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Không tải được thông báo.')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Chưa có thông báo.'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => NotificationTile(
                  notification: items[i],
                  onRead: () {
                    if (!items[i].isRead)
                      ref
                          .read(notificationRepositoryProvider)
                          .markAsRead(items[i].id);
                  },
                ),
              ),
      ),
    );
  }
}
