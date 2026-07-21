// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
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
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 18, 10, 16),
        child: Column(
          children: [
            Container(
              width: 240,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.tertiary],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: .24),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.crop_landscape_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'MÀN HÌNH',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              room.name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
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
        ),
      ),
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

  @override
  void paint(Canvas canvas, Size size) {
    var rowIndex = 0;
    for (final label in rows.keys) {
      _text(
        label,
        labelColor,
        12,
        FontWeight.w800,
      ).paint(canvas, Offset(2, 12 + rowIndex * 44.0));
      rowIndex++;
    }
    for (final item in seats) {
      final status = availability(item.seat);
      final color = switch (status) {
        SeatAvailability.selected => Colors.green,
        SeatAvailability.heldByMe => Colors.orange,
        SeatAvailability.booked => Colors.grey,
        SeatAvailability.heldByOther => Colors.redAccent,
        SeatAvailability.available => Colors.blueGrey,
      };
      final disabled =
          status == SeatAvailability.booked ||
          status == SeatAvailability.heldByOther;
      canvas.drawRRect(
        RRect.fromRectAndRadius(item.rect, const Radius.circular(6)),
        Paint()..color = color.withValues(alpha: disabled ? .35 : 1),
      );
      final label = _text(item.seat.code, Colors.white, 10, FontWeight.bold)
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

  TextPainter _text(
    String value,
    Color color,
    double size,
    FontWeight weight,
  ) => TextPainter(
    text: TextSpan(
      text: value,
      style: TextStyle(color: color, fontSize: size, fontWeight: weight),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  bool shouldRepaint(covariant _SeatPainter oldDelegate) => true;
}
