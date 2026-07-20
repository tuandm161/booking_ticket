// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/app_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onRead,
  });
  final AppNotification notification;
  final VoidCallback onRead;
  @override
  Widget build(BuildContext context) => ListTile(
    tileColor: notification.isRead
        ? null
        : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .35),
    leading: Icon(
      notification.isRead
          ? Icons.notifications_none
          : Icons.notifications_active,
    ),
    title: Text(
      notification.title,
      style: TextStyle(
        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
      ),
    ),
    subtitle: Text(notification.body),
    trailing: Text(
      '${notification.createdAt.day}/${notification.createdAt.month}',
    ),
    onTap: () {
      onRead();
      if (notification.bookingId.isNotEmpty)
        context.push('/user/tickets/${notification.bookingId}');
    },
  );
}
