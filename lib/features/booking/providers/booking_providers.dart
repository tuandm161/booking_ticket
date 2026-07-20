import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_providers.dart';
import '../data/booking_repository.dart';
import '../models/booking.dart';

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(ref.watch(firestoreProvider)),
);
final myBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  return uid == null
      ? Stream.value(const <Booking>[])
      : ref.watch(bookingRepositoryProvider).watchMyBookings(uid);
});
final bookingDetailProvider = FutureProvider.family<Booking?, String>(
  (ref, id) => ref.watch(bookingRepositoryProvider).getBooking(id),
);

({List<Booking> upcoming, List<Booking> past}) groupBookingsByTime(
  List<Booking> bookings,
  DateTime now,
) {
  final upcoming = bookings.where((b) => !b.startTime.isBefore(now)).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  final past = bookings.where((b) => b.startTime.isBefore(now)).toList()
    ..sort((a, b) => b.startTime.compareTo(a.startTime));
  return (upcoming: upcoming, past: past);
}
