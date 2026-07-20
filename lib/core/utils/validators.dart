String? requiredText(String? value, {String field = 'Trường này'}) =>
    value == null || value.trim().isEmpty
    ? '$field không được để trống.'
    : null;

String? emailValidator(String? value) {
  final required = requiredText(value, field: 'Email');
  if (required != null) return required;
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())
      ? null
      : 'Email không hợp lệ.';
}

String? passwordValidator(String? value) =>
    value == null || value.length < 6 ? 'Mật khẩu cần ít nhất 6 ký tự.' : null;

String? positiveIntegerValidator(String? value) {
  final number = int.tryParse(value ?? '');
  return number == null || number <= 0
      ? 'Giá trị phải là số nguyên dương.'
      : null;
}

String? urlValidator(String? value) {
  final required = requiredText(value, field: 'URL');
  if (required != null) return required;
  final uri = Uri.tryParse(value!.trim());
  return uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty
      ? null
      : 'URL phải bắt đầu bằng http:// hoặc https://.';
}

String? voucherCodeValidator(String? value) {
  final required = requiredText(value, field: 'Mã voucher');
  if (required != null) return required;
  return value!.contains(RegExp(r'\s'))
      ? 'Mã voucher không được chứa khoảng trắng.'
      : null;
}
