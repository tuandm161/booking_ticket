import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/services/firebase_providers.dart';
import '../../../core/services/local_notification_service.dart';

final localNotificationServiceProvider = Provider(
  (_) => LocalNotificationService(FlutterLocalNotificationsPlugin()),
);
final fcmServiceProvider = Provider(
  (ref) => FcmService(
    messaging: FirebaseMessaging.instance,
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    localNotifications: ref.watch(localNotificationServiceProvider),
  ),
);
final fcmInitializationProvider = FutureProvider<void>(
  (ref) => ref.watch(fcmServiceProvider).initialize(),
);
