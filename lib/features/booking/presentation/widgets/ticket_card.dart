// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.booking, required this.upcoming});
  final Booking booking;
  final bool upcoming;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: () => context.push('/user/tickets/${booking.id}'),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              height: 92,
              child: CachedNetworkImage(
                imageUrl: booking.moviePosterUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(Icons.movie),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.movieTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${booking.startTime.day}/${booking.startTime.month}/${booking.startTime.year} ${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')}',
                  ),
                  Text(
                    '${booking.roomName} • ${booking.seatItems.map((s) => s.code).join(', ')}',
                  ),
                  Text(
                    booking.bookingCode,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: upcoming
                          ? const Color(0xFFD7262D).withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: upcoming
                            ? const Color(0xFFD7262D)
                            : Colors.grey.shade400,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      upcoming ? 'Sắp diễn ra' : 'Đã xem',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: upcoming
                            ? const Color(0xFFD7262D)
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade300
                                : Colors.grey.shade800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
