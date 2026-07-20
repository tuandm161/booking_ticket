import 'package:flutter_test/flutter_test.dart';
import 'package:booking_cinema/features/booking/models/booking.dart';
import 'package:booking_cinema/features/booking/providers/booking_providers.dart';

Booking _booking(String id, DateTime startTime) => Booking(
  id: id,
  bookingCode: id,
  qrData: 'qr-$id',
  userId: 'user-1',
  userEmail: 'user@example.com',
  movieId: 'movie-1',
  movieTitle: 'Movie',
  moviePosterUrl: '',
  showtimeId: 'showtime-1',
  roomId: 'room-1',
  roomName: 'Room',
  startTime: startTime,
  seatItems: const [],
  productItems: const [],
  comboItems: const [],
  subtotal: 0,
  discountAmount: 0,
  totalAmount: 0,
  paymentMethod: PaymentMethod.card,
  paymentStatus: PaymentStatus.paid,
  bookingStatus: BookingStatus.confirmed,
  createdAt: startTime,
);

void main() {
  test('groups by start time and sorts upcoming asc/past desc', () {
    final now = DateTime(2026, 7, 20, 12);
    final result = groupBookingsByTime([
      _booking('past-old', now.subtract(const Duration(days: 2))),
      _booking('future-late', now.add(const Duration(hours: 3))),
      _booking('past-new', now.subtract(const Duration(hours: 1))),
      _booking('future-soon', now.add(const Duration(hours: 1))),
      _booking('exact-now', now),
    ], now);

    expect(result.upcoming.map((b) => b.id), [
      'exact-now',
      'future-soon',
      'future-late',
    ]);
    expect(result.past.map((b) => b.id), ['past-new', 'past-old']);
  });
}
