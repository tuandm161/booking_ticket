import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_providers.dart';
import '../data/notification_repository.dart';
import '../models/app_notification.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(firestoreProvider)),
);
final myNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  return uid == null
      ? Stream.value(const <AppNotification>[])
      : ref.watch(notificationRepositoryProvider).watchMyNotifications(uid);
});
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  return uid == null
      ? Stream.value(0)
      : ref.watch(notificationRepositoryProvider).watchUnreadCount(uid);
});
