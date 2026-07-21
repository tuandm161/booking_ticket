import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, admin }

extension UserRoleX on UserRole {
  String get value => name;

  static UserRole fromValue(Object? value) =>
      value == 'admin' ? UserRole.admin : UserRole.user;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    this.createdAt,
    this.updatedAt,
    this.fcmTokens = const [],
  });

  final String id;
  final String displayName;
  final String email;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> fcmTokens;

  factory AppUser.fromMap(String id, Map<String, Object?> map) => AppUser(
    id: id,
    displayName: map['displayName'] as String? ?? '',
    email: map['email'] as String? ?? '',
    role: UserRoleX.fromValue(map['role']),
    createdAt: _dateFrom(map['createdAt']),
    updatedAt: _dateFrom(map['updatedAt']),
    fcmTokens:
        (map['fcmTokens'] as Iterable?)?.whereType<String>().toList() ??
        const [],
  );

  Map<String, Object?> toMap() => {
    'displayName': displayName,
    'email': email,
    'role': role.value,
    'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    'fcmTokens': fcmTokens,
  };

  static DateTime? _dateFrom(Object? value) => value is Timestamp
      ? value.toDate()
      : value is DateTime
      ? value
      : null;
}
