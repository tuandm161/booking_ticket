import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_exception.dart';

AppException mapToAppException(Object error) {
  if (error is AppException) return error;
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => AppException.unauthorized(error),
      'email-already-in-use' => AppException.validation(
        'Email đã được sử dụng.',
      ),
      'weak-password' => AppException.validation('Mật khẩu chưa đủ mạnh.'),
      _ => AppException.unknown(error),
    };
  }
  if (error is FirebaseException && error.code == 'permission-denied') {
    return AppException.unauthorized(error);
  }
  if (error is DioException) return AppException.network(error);
  return AppException.unknown(error);
}
