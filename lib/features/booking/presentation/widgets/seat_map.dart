// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../../rooms/models/cinema_room.dart';
import '../../../rooms/models/cinema_seat.dart';
import '../../models/seat_hold.dart';

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
    for (final seat in room.seats) {
      grouped.putIfAbsent(seat.row, () => []).add(seat);
    }

    return Column(
      children: [
        // ── SCREEN label ─────────────────────────────────────
        Container(
          width: 220,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'SCREEN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Seat Grid ────────────────────────────────────────
        _PaintedSeatGrid(
          rows: grouped,
          availability: (seat) => seatAvailability(
            seat: seat,
            selectedCodes: selectedCodes,
            bookedCodes: bookedCodes,
            holds: holds,
            userId: userId,
            reservationId: reservationId,
            now: now,
          ),
          onToggle: onToggle,
        ),
      ],
    );
  }
}

class _PaintedSeatGrid extends StatelessWidget {
  const _PaintedSeatGrid({
    required this.rows,
    required this.availability,
    required this.onToggle,
  });

  final Map<String, List<CinemaSeat>> rows;
  final SeatAvailability Function(CinemaSeat) availability;
  final ValueChanged<CinemaSeat> onToggle;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = Size(constraints.maxWidth, 8 + rows.length * 44.0);
      final seats = _layoutSeats(rows, size);
      return Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          for (final item in seats) {
            if (!item.rect.contains(event.localPosition)) continue;
            final status = availability(item.seat);
            if (status != SeatAvailability.booked &&
                status != SeatAvailability.heldByOther) {
              onToggle(item.seat);
            }
            return;
          }
        },
        child: ExcludeSemantics(
          child: CustomPaint(
            size: size,
            painter: _SeatPainter(
              rows: rows,
              seats: seats,
              availability: availability,
              labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    },
  );
}

class _SeatLayout {
  const _SeatLayout(this.seat, this.rect);
  final CinemaSeat seat;
  final Rect rect;
}

List<_SeatLayout> _layoutSeats(Map<String, List<CinemaSeat>> rows, Size size) {
  const labelWidth = 24.0;
  const gap = 4.0;
  final result = <_SeatLayout>[];
  var rowIndex = 0;
  for (final row in rows.values) {
    final naturalWidth = row.fold<double>(
      0,
      (sum, seat) => sum + (seat.type == SeatType.couple ? 64 : 34) + gap,
    );
    final available = (size.width - labelWidth - 8).clamp(1, double.infinity);
    final scale = naturalWidth > available ? available / naturalWidth : 1.0;
    var x = labelWidth + (available - naturalWidth * scale) / 2;
    final y = 5 + rowIndex * 44.0;
    for (final seat in row) {
      final width = (seat.type == SeatType.couple ? 64.0 : 34.0) * scale;
      result.add(_SeatLayout(seat, Rect.fromLTWH(x, y, width, 34)));
      x += width + gap * scale;
    }
    rowIndex++;
  }
  return result;
}

class _SeatPainter extends CustomPainter {
  const _SeatPainter({
    required this.rows,
    required this.seats,
    required this.availability,
    required this.labelColor,
  });
  final Map<String, List<CinemaSeat>> rows;
  final List<_SeatLayout> seats;
  final SeatAvailability Function(CinemaSeat) availability;
  final Color labelColor;

  /// CGV seat colour scheme:
  /// - Standard/available  : Xám nhạt #C8C8C8
  /// - VIP/available       : Đỏ đô #8B1A1A
  /// - Couple/available    : Hồng đậm #E91E63
  /// - Selected            : Đỏ tươi CGV #D7262D + viền trắng
  /// - HeldByMe            : Cam nhạt #FF9800
  /// - Booked/HeldByOther  : Xám tối #4A4A4A
  Color _colorFor(CinemaSeat seat, SeatAvailability status) {
    return switch (status) {
      SeatAvailability.selected => AppTheme.cgvRed,
      SeatAvailability.heldByMe => const Color(0xFFFF9800),
      SeatAvailability.booked => const Color(0xFF4A4A4A),
      SeatAvailability.heldByOther => const Color(0xFF4A4A4A),
      SeatAvailability.available => switch (seat.type) {
          SeatType.vip => const Color(0xFF8B1A1A),
          SeatType.couple => const Color(0xFFE91E63),
          _ => const Color(0xFFC0C0C0),
        },
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    var rowIndex = 0;
    for (final label in rows.keys) {
      _text(label, labelColor, 11, FontWeight.w700)
          .paint(canvas, Offset(2, 12 + rowIndex * 44.0));
      rowIndex++;
    }
    for (final item in seats) {
      final status = availability(item.seat);
      final color = _colorFor(item.seat, status);
      final disabled = status == SeatAvailability.booked ||
          status == SeatAvailability.heldByOther;

      final rrect = RRect.fromRectAndRadius(
          item.rect, const Radius.circular(5));

      // Selected or HeldByMe: dynamic glowing halo shadow around seat
      if (status == SeatAvailability.selected ||
          status == SeatAvailability.heldByMe) {
        final glowColor = status == SeatAvailability.selected
            ? AppTheme.cgvRed
            : const Color(0xFFFF9800);
        canvas.drawRRect(
          rrect.inflate(2.5),
          Paint()
            ..color = glowColor.withValues(alpha: 0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }

      // Fill
      canvas.drawRRect(
        rrect,
        Paint()..color = color.withValues(alpha: disabled ? .4 : 1),
      );

      // Selected: white border ring
      if (status == SeatAvailability.selected) {
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // Occupied: X mark
      if (disabled) {
        final cx = item.rect.center.dx;
        final cy = item.rect.center.dy;
        final d = item.rect.width * 0.22;
        canvas.drawLine(
          Offset(cx - d, cy - d),
          Offset(cx + d, cy + d),
          Paint()..color = Colors.white54..strokeWidth = 1.5,
        );
        canvas.drawLine(
          Offset(cx + d, cy - d),
          Offset(cx - d, cy + d),
          Paint()..color = Colors.white54..strokeWidth = 1.5,
        );
      } else {
        // Label code on seat
        final label = _text(item.seat.code, Colors.white, 9, FontWeight.w700)
          ..layout(maxWidth: item.rect.width);
        label.paint(
          canvas,
          Offset(
            item.rect.center.dx - label.width / 2,
            item.rect.center.dy - label.height / 2,
          ),
        );
      }
    }
  }

  TextPainter _text(
    String value,
    Color color,
    double size,
    FontWeight weight,
  ) =>
      TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(color: color, fontSize: size, fontWeight: weight),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  @override
  bool shouldRepaint(covariant _SeatPainter oldDelegate) => true;
}
