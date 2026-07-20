import 'package:flutter/material.dart';
import '../../models/cinema_seat.dart';

class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 8,
    children: [
      for (final item in [
        (SeatType.standard, 'Standard'),
        (SeatType.vip, 'VIP'),
        (SeatType.couple, 'Couple'),
      ])
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _color(item.$1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Text(item.$2),
          ],
        ),
    ],
  );
  Color _color(SeatType type) => switch (type) {
    SeatType.standard => Colors.blueGrey,
    SeatType.vip => Colors.amber.shade700,
    SeatType.couple => Colors.pink.shade400,
  };
}
