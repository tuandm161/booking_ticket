import 'package:flutter_test/flutter_test.dart';
import 'package:booking_cinema/features/booking/models/seat_hold.dart';
import 'package:booking_cinema/features/rooms/models/cinema_seat.dart';

void main() {
  final seat = const CinemaSeat(
    code: 'A1',
    row: 'A',
    number: 1,
    type: SeatType.standard,
    capacity: 1,
  );
  final now = DateTime(2026);
  test(
    'availability prioritizes booked, active holds, then local selection',
    () {
      expect(
        seatAvailability(
          seat: seat,
          selectedCodes: {'A1'},
          bookedCodes: {'A1'},
          holds: const {},
          userId: 'u',
          reservationId: 'r',
          now: now,
        ),
        SeatAvailability.booked,
      );
      final other = {
        'A1': SeatHold(
          userId: 'other',
          reservationId: 'x',
          expiresAt: now.add(const Duration(minutes: 1)),
        ),
      };
      expect(
        seatAvailability(
          seat: seat,
          selectedCodes: {},
          bookedCodes: const {},
          holds: other,
          userId: 'u',
          reservationId: 'r',
          now: now,
        ),
        SeatAvailability.heldByOther,
      );
      final mine = {
        'A1': SeatHold(
          userId: 'u',
          reservationId: 'r',
          expiresAt: now.add(const Duration(minutes: 1)),
        ),
      };
      expect(
        seatAvailability(
          seat: seat,
          selectedCodes: {'A1'},
          bookedCodes: const {},
          holds: mine,
          userId: 'u',
          reservationId: 'r',
          now: now,
        ),
        SeatAvailability.selected,
      );
    },
  );
  test('expired hold becomes available', () {
    final hold = {
      'A1': SeatHold(
        userId: 'other',
        reservationId: 'x',
        expiresAt: now.subtract(const Duration(seconds: 1)),
      ),
    };
    expect(
      seatAvailability(
        seat: seat,
        selectedCodes: const {},
        bookedCodes: const {},
        holds: hold,
        userId: 'u',
        reservationId: 'r',
        now: now,
      ),
      SeatAvailability.available,
    );
  });
}
