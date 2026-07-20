import 'package:flutter_test/flutter_test.dart';
import 'package:booking_cinema/features/booking/data/checkout_repository.dart';
import 'package:booking_cinema/features/booking/models/order_draft.dart';
import 'package:booking_cinema/features/movies/models/movie.dart';
import 'package:booking_cinema/features/rooms/models/cinema_room.dart';
import 'package:booking_cinema/features/showtimes/models/showtime.dart';

void main() {
  final now = DateTime(2026);
  final movie = Movie(
    source: MovieSource.manual,
    title: 'M',
    overview: '',
    posterUrl: '',
    backdropUrl: '',
    durationMinutes: 90,
    genres: const [],
    releaseDate: null,
    ageRating: '',
    country: '',
    director: '',
    cast: const [],
    trailerUrl: '',
    status: MovieStatus.nowShowing,
    isFeatured: false,
    isActive: true,
    bookingCount: 0,
  );
  final room = CinemaRoom(
    name: 'R',
    roomType: RoomType.standard,
    rowCount: 1,
    seatsPerRow: 1,
    vipRowStart: 0,
    coupleSeatCount: 0,
    seats: const [],
    isActive: true,
  );
  final showtime = Showtime(
    movieId: 'm',
    movieTitle: 'M',
    moviePosterUrl: '',
    roomId: 'r',
    roomName: 'R',
    startTime: now.add(const Duration(hours: 1)),
    endTime: now.add(const Duration(hours: 3)),
    basePrice: 1,
    isActive: true,
    bookedSeatCodes: const [],
    heldSeats: const {},
  );
  OrderDraft draft(DateTime? expires, String? reservation) => OrderDraft(
    movie: movie,
    showtime: showtime,
    room: room,
    reservationId: reservation,
    holdExpiresAt: expires,
  );
  test('checkout rejects missing or expired hold before transaction', () {
    expect(
      () => validateCheckoutDraft(
        draft(now.add(const Duration(minutes: 1)), null),
        now,
      ),
      throwsA(isA<Exception>()),
    );
    expect(
      () => validateCheckoutDraft(
        draft(now.subtract(const Duration(seconds: 1)), 'r'),
        now,
      ),
      throwsA(isA<Exception>()),
    );
    expect(
      () => validateCheckoutDraft(
        draft(now.add(const Duration(minutes: 1)), 'r'),
        now,
      ),
      throwsA(isA<Exception>()),
    );
  });
}
