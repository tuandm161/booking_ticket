import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';

class AdminBookingCard extends StatelessWidget {
  const AdminBookingCard({super.key, required this.booking});
  final Booking booking;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: () => context.push('/admin/bookings/${booking.id}'),
      child: ListTile(
        title: Text('${booking.bookingCode} • ${booking.movieTitle}'),
        subtitle: Text(
          '${booking.userEmail}\n${booking.startTime} • ${booking.seatItems.map((s) => s.code).join(', ')}',
        ),
        isThreeLine: true,
        trailing: Text('${booking.totalAmount} đ'),
      ),
    ),
  );
}
