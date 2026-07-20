import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import 'booking_providers.dart';

final allBookingsProvider = StreamProvider<List<Booking>>(
  (ref) => ref.watch(bookingRepositoryProvider).watchAllBookings(),
);

List<Booking> filterAdminBookings(
  List<Booking> source, {
  String query = '',
  DateTime? date,
  String? movieId,
  bool? upcoming,
  String? paymentMethod,
  DateTime? now,
}) {
  final q = query.trim().toLowerCase();
  final current = now ?? DateTime.now();
  return source.where((b) {
    final matchesQuery =
        q.isEmpty ||
        b.bookingCode.toLowerCase().contains(q) ||
        b.userEmail.toLowerCase().contains(q) ||
        b.movieTitle.toLowerCase().contains(q);
    final matchesDate =
        date == null ||
        (b.createdAt.year == date.year &&
            b.createdAt.month == date.month &&
            b.createdAt.day == date.day);
    final matchesMovie =
        movieId == null || movieId.isEmpty || b.movieId == movieId;
    final matchesTime =
        upcoming == null ||
        (upcoming
            ? !b.startTime.isBefore(current)
            : b.startTime.isBefore(current));
    final matchesPayment =
        paymentMethod == null ||
        paymentMethod.isEmpty ||
        b.paymentMethod.name == paymentMethod;
    return matchesQuery &&
        matchesDate &&
        matchesMovie &&
        matchesTime &&
        matchesPayment;
  }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
