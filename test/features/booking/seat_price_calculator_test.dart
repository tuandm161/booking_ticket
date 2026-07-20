import 'package:flutter_test/flutter_test.dart';
import 'package:booking_cinema/features/booking/models/seat_hold.dart';
import 'package:booking_cinema/features/rooms/models/cinema_seat.dart';

void main() {
  test('seat prices follow standard, VIP and couple rules', () {
    expect(seatPrice(SeatType.standard, 80000), 80000);
    expect(seatPrice(SeatType.vip, 80000), 100000);
    expect(seatPrice(SeatType.couple, 80000), 180000);
  });
}
