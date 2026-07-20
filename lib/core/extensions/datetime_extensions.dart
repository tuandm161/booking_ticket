import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get displayDateTime =>
      DateFormat('dd/MM/yyyy HH:mm').format(toLocal());
}
