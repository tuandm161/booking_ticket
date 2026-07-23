import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../../rooms/models/cinema_seat.dart';
import '../../models/seat_hold.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/app_press_scale.dart';

/// CGV-style sticky bottom bar for seat selection:
/// Left: [seat icon] X SEATS / [price icon] total
/// Right: BOOK NOW red pill button
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceText =
        NumberFormat('#,###', 'vi').format(total).replaceAll(',', '.');

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Seat count + total price
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event_seat_rounded, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${seats.length} ghế',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (total > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$priceText đ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.cgvRed,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // BOOK NOW button
          AppPressScale(
            enabled: seats.isNotEmpty,
            child: FilledButton(
              onPressed: seats.isNotEmpty ? onContinue : null,
              style: FilledButton.styleFrom(
                backgroundColor:
                    seats.isNotEmpty ? AppTheme.cgvRed : Colors.grey,
                minimumSize: const Size(120, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'ĐẶT VÉ NGAY',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
