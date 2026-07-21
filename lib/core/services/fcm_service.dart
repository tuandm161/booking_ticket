import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../constants/firestore_paths.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class FcmService {
  FcmService({
    required FirebaseMessaging messaging,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required LocalNotificationService localNotifications,
  }) : _messaging = messaging,
       _auth = auth,
       _firestore = firestore,
       _localNotifications = localNotifications;
  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final LocalNotificationService _localNotifications;
  final ValueNotifier<String?> bookingTap = ValueNotifier(null);
  StreamSubscription<String?>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<User?>? _authSubscription;
  bool _started = false;

  Future<void> initialize() async {
    if (_started) return;
    _started = true;
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _localNotifications.initialize(onTap: _handlePayload);
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      _authSubscription = _auth.authStateChanges().listen((user) async {
        if (user != null) await _saveToken(await _messaging.getToken());
      });
      await _saveToken(await _messaging.getToken());
      _tokenSubscription = _messaging.onTokenRefresh.listen(_saveToken);
      _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
        final payload = message.data['bookingId']?.toString();
        _localNotifications.show(
          title: message.notification?.title ?? 'Movie Booking',
          body: message.notification?.body ?? 'Bạn có thông báo mới.',
          payload: payload,
        );
      });
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _handlePayload(message.data['bookingId']?.toString()),
      );
      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        _handlePayload(initial.data['bookingId']?.toString());
      }
    } catch (_) {
      // FCM is optional: Firestore in-app notifications continue if setup is absent.
    }
  }

  Future<void> _saveToken(String? token) async {
    final uid = _auth.currentUser?.uid;
    if (token == null || uid == null) return;
    try {
      await _firestore.collection(FirestorePaths.users).doc(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  void _handlePayload(String? bookingId) {
    if (bookingId != null && bookingId.isNotEmpty) bookingTap.value = bookingId;
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _tokenSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    bookingTap.dispose();
  }
}
