import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/booking.dart';

class TicketQrCard extends StatelessWidget {
  const TicketQrCard({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          QrImageView(data: booking.qrData, size: 190),
          const SizedBox(height: 8),
          Text(
            booking.bookingCode,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text('Xuất trình mã này tại rạp.'),
        ],
      ),
    ),
  );
}
