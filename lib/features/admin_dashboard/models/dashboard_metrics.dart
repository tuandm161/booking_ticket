import '../../booking/models/booking.dart';
import '../../movies/models/movie.dart';
import '../../showtimes/models/showtime.dart';

class DashboardMetrics {
  const DashboardMetrics({
    required this.totalBookings,
    required this.todayBookings,
    required this.todayRevenue,
    required this.totalRevenue,
    required this.ticketsSold,
    required this.topMovie,
    required this.upcomingShowtimes24h,
  });
  final int totalBookings,
      todayBookings,
      todayRevenue,
      totalRevenue,
      ticketsSold,
      upcomingShowtimes24h;
  final Movie? topMovie;
}

DashboardMetrics calculateDashboardMetrics({
  required List<Booking> bookings,
  required List<Movie> movies,
  required List<Showtime> showtimes,
  required DateTime now,
}) {
  final paid = bookings
      .where(
        (b) =>
            b.paymentStatus == PaymentStatus.paid &&
            b.bookingStatus == BookingStatus.confirmed,
      )
      .toList();
  final day = DateTime(now.year, now.month, now.day);
  final tomorrow = day.add(const Duration(days: 1));
  final today = paid
      .where(
        (b) => !b.createdAt.isBefore(day) && b.createdAt.isBefore(tomorrow),
      )
      .toList();
  final top = movies.isEmpty
      ? null
      : (movies.toList()
              ..sort((a, b) => b.bookingCount.compareTo(a.bookingCount)))
            .first;
  return DashboardMetrics(
    totalBookings: bookings.length,
    todayBookings: today.length,
    todayRevenue: today.fold(0, (sum, b) => sum + b.totalAmount),
    totalRevenue: paid.fold(0, (sum, b) => sum + b.totalAmount),
    ticketsSold: paid.fold(
      0,
      (sum, b) => sum + b.seatItems.fold(0, (s, seat) => s + seat.capacity),
    ),
    topMovie: top,
    upcomingShowtimes24h: showtimes
        .where(
          (s) =>
              s.isActive &&
              !s.startTime.isBefore(now) &&
              s.startTime.isBefore(now.add(const Duration(hours: 24))),
        )
        .length,
  );
}
