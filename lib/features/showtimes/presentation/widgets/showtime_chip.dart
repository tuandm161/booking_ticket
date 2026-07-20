import 'package:flutter/material.dart';
import '../../models/showtime.dart';

class ShowtimeChip extends StatelessWidget {
  const ShowtimeChip({super.key, required this.showtime, required this.onTap});
  final Showtime showtime;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: const Icon(Icons.schedule, size: 18),
    label: Text(
      '${showtime.startTime.hour.toString().padLeft(2, '0')}:${showtime.startTime.minute.toString().padLeft(2, '0')} • ${showtime.roomName} • ${showtime.basePrice} đ',
    ),
    onPressed: onTap,
  );
}
