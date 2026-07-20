// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import '../../../rooms/models/cinema_room.dart';
import '../../../rooms/models/cinema_seat.dart';
import '../../models/seat_hold.dart';
import 'seat_widget.dart';

class SeatMap extends StatelessWidget {
  const SeatMap({
    super.key,
    required this.room,
    required this.selectedCodes,
    required this.bookedCodes,
    required this.holds,
    required this.userId,
    required this.reservationId,
    required this.now,
    required this.onToggle,
  });
  final CinemaRoom room;
  final Set<String> selectedCodes, bookedCodes;
  final Map<String, SeatHold> holds;
  final String? userId, reservationId;
  final DateTime now;
  final ValueChanged<CinemaSeat> onToggle;
  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<CinemaSeat>>{};
    for (final seat in room.seats)
      grouped.putIfAbsent(seat.row, () => []).add(seat);
    return Column(
      children: [
        Container(
          width: 220,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text('MÀN HÌNH'),
        ),
        const SizedBox(height: 20),
        ...grouped.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 22, child: Text(entry.key)),
                ...entry.value.map((seat) {
                  final status = seatAvailability(
                    seat: seat,
                    selectedCodes: selectedCodes,
                    bookedCodes: bookedCodes,
                    holds: holds,
                    userId: userId,
                    reservationId: reservationId,
                    now: now,
                  );
                  return SeatWidget(
                    seat: seat,
                    status: status,
                    onTap: () => onToggle(seat),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
