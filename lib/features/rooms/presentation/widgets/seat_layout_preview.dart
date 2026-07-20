import 'package:flutter/material.dart';

import '../../models/cinema_seat.dart';
import 'seat_legend.dart';

class SeatLayoutPreview extends StatelessWidget {
  const SeatLayoutPreview({super.key, required this.seats});
  final List<CinemaSeat> seats;

  @override
  Widget build(BuildContext context) {
    final rows = <String, List<CinemaSeat>>{};
    for (final seat in seats) {
      rows.putIfAbsent(seat.row, () => <CinemaSeat>[]).add(seat);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Màn hình',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        ...rows.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 20, child: Text(entry.key)),
                ...entry.value.map(
                  (seat) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Tooltip(
                      message: '${seat.code} • ${seat.type.label}',
                      child: Container(
                        width: seat.type == SeatType.couple ? 32 : 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _color(seat.type),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${seat.number}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const SeatLegend(),
      ],
    );
  }

  Color _color(SeatType type) => switch (type) {
    SeatType.standard => Colors.blueGrey,
    SeatType.vip => Colors.amber,
    SeatType.couple => Colors.pink,
  };
}
