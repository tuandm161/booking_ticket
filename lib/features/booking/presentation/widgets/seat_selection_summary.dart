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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: .35),
        ),
        boxShadow: const [BoxShadow(blurRadius: 14, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            seats.isEmpty
                ? 'Chưa chọn ghế'
                : '${seats.map((s) => s.code).join(', ')}\n$capacity người • $total đ',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              if (seats.isNotEmpty) onContinue();
            },
            style: seats.isEmpty
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    foregroundColor: Theme.of(context).colorScheme.outline,
                  )
                : null,
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }
}
