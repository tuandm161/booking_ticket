import 'package:flutter_test/flutter_test.dart';
import 'package:booking_cinema/features/admin_dashboard/models/dashboard_metrics.dart';
import 'package:booking_cinema/features/booking/models/booking.dart';
import 'package:booking_cinema/features/booking/models/seat_item.dart';
import 'package:booking_cinema/features/rooms/models/cinema_seat.dart';

Booking _b(String id, int total, DateTime created, List<SeatItem> seats) =>
    Booking(
      id: id,
      bookingCode: id,
      qrData: id,
      userId: 'u',
      userEmail: 'u@x.com',
      movieId: 'm',
      movieTitle: 'Movie',
      moviePosterUrl: '',
      showtimeId: 's',
      roomId: 'r',
      roomName: 'R',
      startTime: created.add(const Duration(days: 1)),
      seatItems: seats,
      productItems: const [],
      comboItems: const [],
      subtotal: total,
      discountAmount: 0,
      totalAmount: total,
      paymentMethod: PaymentMethod.card,
      paymentStatus: PaymentStatus.paid,
      bookingStatus: BookingStatus.confirmed,
      createdAt: created,
    );
void main() {
  test('calculates revenue and couple capacity', () {
    final now = DateTime(2026, 7, 20, 12);
    final seats = [
      const SeatItem(
        code: 'A1',
        type: SeatType.standard,
        capacity: 1,
        unitPrice: 80000,
      ),
      const SeatItem(
        code: 'A2',
        type: SeatType.standard,
        capacity: 1,
        unitPrice: 80000,
      ),
    ];
    final couple = [
      const SeatItem(
        code: 'C1',
        type: SeatType.couple,
        capacity: 2,
        unitPrice: 180000,
      ),
    ];
    final m = calculateDashboardMetrics(
      bookings: [
        _b('a', 160000, now, seats),
        _b('b', 180000, now.subtract(const Duration(days: 1)), couple),
      ],
      movies: const [],
      showtimes: const [],
      now: now,
    );
    expect(m.totalBookings, 2);
    expect(m.todayBookings, 1);
    expect(m.todayRevenue, 160000);
    expect(m.totalRevenue, 340000);
    expect(m.ticketsSold, 4);
  });
}
