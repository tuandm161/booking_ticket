import 'package:booking_cinema/core/utils/seat_generator.dart';
import 'package:booking_cinema/features/rooms/models/cinema_seat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates VIP rows and couple seats on last row', () {
    final seats = generateSeats(
      rowCount: 8,
      seatsPerRow: 10,
      vipRowStart: 5,
      coupleSeatCount: 4,
    );
    expect(seats.length, 74);
    expect(seats.where((seat) => seat.type == SeatType.vip).length, 30);
    expect(seats.where((seat) => seat.type == SeatType.couple).length, 4);
    expect(
      seats
          .where((seat) => seat.row == 'H')
          .every((seat) => seat.capacity == 2),
      isTrue,
    );
  });

  test('supports no VIP and no couple seats', () {
    final seats = generateSeats(
      rowCount: 2,
      seatsPerRow: 3,
      vipRowStart: 0,
      coupleSeatCount: 0,
    );
    expect(seats.length, 6);
    expect(seats.every((seat) => seat.type == SeatType.standard), isTrue);
  });

  test('rejects invalid input', () {
    expect(
      () => generateSeats(
        rowCount: 0,
        seatsPerRow: 3,
        vipRowStart: 0,
        coupleSeatCount: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => generateSeats(
        rowCount: 2,
        seatsPerRow: 3,
        vipRowStart: 0,
        coupleSeatCount: 4,
      ),
      throwsArgumentError,
    );
  });
}
