import 'app_exception.dart';

AppException mapToAppException(Object error) {
  if (error is AppException) return error;
  return AppException.unknown(error);
}
