import '../../../core/utils/firestore_converters.dart';

class AppNotification {
  const AppNotification({
    this.id = '',
    required this.userId,
    required this.title,
    required this.body,
    required this.bookingId,
    required this.isRead,
    required this.createdAt,
  });
  final String id, userId, title, body, bookingId;
  final bool isRead;
  final DateTime createdAt;
  factory AppNotification.fromMap(String id, Map<String, Object?> m) =>
      AppNotification(
        id: id,
        userId: m['userId'] as String? ?? '',
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
        bookingId: m['bookingId'] as String? ?? '',
        isRead: m['isRead'] as bool? ?? false,
        createdAt:
            dateFromFirestore(m['createdAt']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
  Map<String, Object?> toMap() => {
    'userId': userId,
    'title': title,
    'body': body,
    'bookingId': bookingId,
    'isRead': isRead,
    'createdAt': dateToFirestore(createdAt),
  };
  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? bookingId,
    bool? isRead,
    DateTime? createdAt,
  }) => AppNotification(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    body: body ?? this.body,
    bookingId: bookingId ?? this.bookingId,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
  );
}
