import 'package:flutter_test/flutter_test.dart';
import 'package:booking_cinema/features/booking/data/seat_hold_repository.dart';
import 'package:booking_cinema/features/rooms/models/cinema_room.dart';
import 'package:booking_cinema/features/rooms/models/cinema_seat.dart';
import 'package:booking_cinema/features/showtimes/models/showtime.dart';

void main() {
  final room = CinemaRoom(
    id: 'room',
    name: 'R',
    roomType: RoomType.standard,
    rowCount: 1,
    seatsPerRow: 2,
    vipRowStart: 0,
    coupleSeatCount: 0,
    seats: const [
      CinemaSeat(
        code: 'A1',
        row: 'A',
        number: 1,
        type: SeatType.standard,
        capacity: 1,
      ),
      CinemaSeat(
        code: 'A2',
        row: 'A',
        number: 2,
        type: SeatType.standard,
        capacity: 1,
      ),
    ],
    isActive: true,
  );
  final now = DateTime(2026);
  Showtime showtime({
    List<String> booked = const [],
    Map<String, HeldSeat> holds = const {},
  }) => Showtime(
    movieId: 'm',
    movieTitle: 'M',
    moviePosterUrl: '',
    roomId: 'room',
    roomName: 'R',
    startTime: now.add(const Duration(hours: 1)),
    endTime: now.add(const Duration(hours: 3)),
    basePrice: 1,
    isActive: true,
    bookedSeatCodes: booked,
    heldSeats: holds,
  );
  test('expired holds are lazily removed and new hold is added', () {
    final result = mergeHeldSeats(
      room: room,
      showtime: showtime(
        holds: {
          'A2': HeldSeat(
            userId: 'old',
            reservationId: 'old',
            expiresAt: now.subtract(const Duration(seconds: 1)),
          ),
        },
      ),
      selectedSeatCodes: ['A1'],
      userId: 'u',
      reservationId: 'r',
      now: now,
      expiresAt: now.add(const Duration(minutes: 10)),
    );
    expect(result.keys, {'A1'});
  });
  test('active hold and booked seat are rejected', () {
    expect(
      () => mergeHeldSeats(
        room: room,
        showtime: showtime(booked: ['A1']),
        selectedSeatCodes: ['A1'],
        userId: 'u',
        reservationId: 'r',
        now: now,
        expiresAt: now.add(const Duration(minutes: 10)),
      ),
      throwsA(isA<Exception>()),
    );
    expect(
      () => mergeHeldSeats(
        room: room,
        showtime: showtime(
          holds: {
            'A1': HeldSeat(
              userId: 'other',
              reservationId: 'x',
              expiresAt: now.add(const Duration(minutes: 1)),
            ),
          },
        ),
        selectedSeatCodes: ['A1'],
        userId: 'u',
        reservationId: 'r',
        now: now,
        expiresAt: now.add(const Duration(minutes: 10)),
      ),
      throwsA(isA<Exception>()),
    );
  });
  test('release only removes matching reservation and expired holds', () {
    final result = releaseMatchingHolds(
      source: {
        'A1': HeldSeat(
          userId: 'u',
          reservationId: 'r',
          expiresAt: now.add(const Duration(minutes: 1)),
        ),
        'A2': HeldSeat(
          userId: 'other',
          reservationId: 'x',
          expiresAt: now.add(const Duration(minutes: 1)),
        ),
        'A3': HeldSeat(
          userId: 'other',
          reservationId: 'x',
          expiresAt: now.subtract(const Duration(seconds: 1)),
        ),
      },
      userId: 'u',
      reservationId: 'r',
      now: now,
    );
    expect(result.keys, {'A2'});
  });
}
