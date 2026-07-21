import 'package:flutter/material.dart';
import '../../models/seat_hold.dart';
import '../../../rooms/models/cinema_seat.dart';

class SeatWidget extends StatelessWidget {
  const SeatWidget({
    super.key,
    required this.seat,
    required this.status,
    required this.onTap,
  });
  final CinemaSeat seat;
  final SeatAvailability status;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final disabled =
        status == SeatAvailability.booked ||
        status == SeatAvailability.heldByOther;
    final color = switch (status) {
      SeatAvailability.selected => Colors.green,
      SeatAvailability.heldByMe => Colors.orange,
      SeatAvailability.booked => Colors.grey,
      SeatAvailability.heldByOther => Colors.redAccent,
      SeatAvailability.available => Colors.blueGrey,
    };
    return SizedBox(
      width: seat.type == SeatType.couple ? 66 : 38,
      height: 38,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: color.withValues(alpha: disabled ? .35 : 1),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: disabled ? null : onTap,
            borderRadius: BorderRadius.circular(6),
            child: Center(
              child: Text(
                seat.code,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
