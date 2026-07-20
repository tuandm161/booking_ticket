import 'package:flutter/material.dart';
import '../../../rooms/models/cinema_seat.dart';
import '../../models/seat_hold.dart';

class SeatSelectionSummary extends StatelessWidget {
  const SeatSelectionSummary({
    super.key,
    required this.seats,
    required this.basePrice,
    required this.onContinue,
  });
  final List<CinemaSeat> seats;
  final int basePrice;
  final VoidCallback onContinue;
  @override
  Widget build(BuildContext context) {
    final total = seats.fold<int>(
      0,
      (sum, seat) => sum + seatPrice(seat.type, basePrice),
    );
    final capacity = seats.fold<int>(0, (sum, seat) => sum + seat.capacity);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                seats.isEmpty
                    ? 'Chưa chọn ghế'
                    : '${seats.map((s) => s.code).join(', ')}\n$capacity người • $total đ',
              ),
            ),
            FilledButton(
              onPressed: seats.isEmpty ? null : onContinue,
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      ),
    );
  }
}
