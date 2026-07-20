import 'package:flutter/material.dart';
import '../../models/booking.dart';

class TicketSeatSummary extends StatelessWidget {
  const TicketSeatSummary({super.key, required this.booking});
  final Booking booking;
  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: booking.seatItems
          .map(
            (seat) => ListTile(
              leading: const Icon(Icons.event_seat),
              title: Text(seat.code),
              subtitle: Text('${seat.type.name} • ${seat.capacity} người'),
              trailing: Text('${seat.unitPrice} đ'),
            ),
          )
          .toList(),
    ),
  );
}
