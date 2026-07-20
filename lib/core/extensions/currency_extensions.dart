import 'package:intl/intl.dart';

extension CurrencyExtensions on int {
  String get vnd => NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  ).format(this);
}
