import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService(this._plugin);
  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize({
    required void Function(String? payload) onTap,
  }) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) => onTap(response.payload),
    );
    const channel = AndroidNotificationChannel(
      'booking_updates',
      'Booking updates',
      description: 'Thông báo đặt vé',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) => _plugin.show(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'booking_updates',
        'Booking updates',
        channelDescription: 'Thông báo đặt vé',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    payload: payload,
  );
}
