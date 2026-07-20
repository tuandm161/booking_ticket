import 'package:booking_cinema/shared/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unknown role safely falls back to user', () {
    final user = AppUser.fromMap('uid', {
      'displayName': 'Demo',
      'email': 'demo@example.com',
      'role': 'unexpected',
    });
    expect(user.role, UserRole.user);
  });

  test('admin role maps from Firestore value', () {
    final user = AppUser.fromMap('uid', {
      'displayName': 'Admin',
      'email': 'admin@example.com',
      'role': 'admin',
    });
    expect(user.role, UserRole.admin);
    expect(user.toMap()['role'], 'admin');
  });
}
