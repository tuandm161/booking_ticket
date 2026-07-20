import 'package:flutter_test/flutter_test.dart';
import 'package:booking_cinema/core/utils/validators.dart';

void main() {
  test('validates required, email and password', () {
    expect(requiredText(''), isNotNull);
    expect(emailValidator('user@example.com'), isNull);
    expect(emailValidator('invalid'), isNotNull);
    expect(passwordValidator('12345'), isNotNull);
    expect(passwordValidator('123456'), isNull);
  });

  test('validates positive integer, URL and voucher code', () {
    expect(positiveIntegerValidator('2'), isNull);
    expect(positiveIntegerValidator('0'), isNotNull);
    expect(urlValidator('https://example.com'), isNull);
    expect(urlValidator('ftp://example.com'), isNotNull);
    expect(voucherCodeValidator('MOVIE20'), isNull);
    expect(voucherCodeValidator('MOVIE 20'), isNotNull);
  });
}
