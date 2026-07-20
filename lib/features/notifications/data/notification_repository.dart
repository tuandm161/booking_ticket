// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../models/app_notification.dart';

class NotificationRepository {
  const NotificationRepository(this._firestore);
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection(FirestorePaths.notifications);
  Stream<List<AppNotification>> watchMyNotifications(String userId) =>
      _notifications
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => AppNotification.fromMap(
                    doc.id,
                    Map<String, Object?>.from(doc.data()),
                  ),
                )
                .toList(),
          );
  Stream<int> watchUnreadCount(String userId) => watchMyNotifications(
    userId,
  ).map((items) => items.where((item) => !item.isRead).length);
  Future<void> markAsRead(String notificationId) =>
      _notifications.doc(notificationId).update({'isRead': true});
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs)
      batch.update(doc.reference, {'isRead': true});
    await batch.commit();
  }
}
