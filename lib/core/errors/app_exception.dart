class AppException implements Exception {
  const AppException({required this.code, required this.message, this.cause});
  final String code;
  final String message;
  final Object? cause;

  factory AppException.network([Object? cause]) => AppException(
    code: 'network',
    message: 'Không thể kết nối mạng.',
    cause: cause,
  );
  factory AppException.validation(String message) =>
      AppException(code: 'validation', message: message);
  factory AppException.unauthorized([Object? cause]) => AppException(
    code: 'unauthorized',
    message: 'Bạn không có quyền thực hiện thao tác này.',
    cause: cause,
  );
  factory AppException.unknown([Object? cause]) => AppException(
    code: 'unknown',
    message: 'Đã xảy ra lỗi. Vui lòng thử lại.',
    cause: cause,
  );

  @override
  String toString() => 'AppException($code): $message';
}
