import 'package:flutter_test/flutter_test.dart';
import 'package:booking_cinema/features/movies/models/movie.dart';
import 'package:booking_cinema/features/showtimes/models/showtime.dart';
import 'package:booking_cinema/features/user_home/models/user_catalog.dart';

Movie m(String id, bool featured, int count) => Movie(
  id: id,
  source: MovieSource.manual,
  title: id,
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
  isFeatured: featured,
  isActive: true,
  bookingCount: count,
);
Showtime s(String movieId, DateTime start) => Showtime(
  movieId: movieId,
  movieTitle: movieId,
  moviePosterUrl: '',
  roomId: 'r',
  roomName: 'R',
  startTime: start,
  endTime: start.add(const Duration(hours: 2)),
  basePrice: 1,
  isActive: true,
  bookedSeatCodes: const [],
  heldSeats: const {},
);

void main() {
  test('popular sort featured then booking count', () {
    final now = DateTime(2026);
    final c = aggregateUserCatalog(
      movies: [m('A', true, 2), m('B', true, 10), m('C', false, 100)],
      showtimes: [
        s('A', now.add(const Duration(days: 1))),
        s('B', now.add(const Duration(days: 1))),
        s('C', now.add(const Duration(days: 1))),
      ],
      now: now,
    );
    expect(c.popular.map((x) => x.title), ['B', 'A', 'C']);
  });
  test('active movie without future showtime is hidden', () {
    final c = aggregateUserCatalog(
      movies: [m('A', false, 0)],
      showtimes: const [],
      now: DateTime(2026),
    );
    expect(c.popular, isEmpty);
  });
  test('search only returns bookable movies by title, director or genre', () {
    final now = DateTime(2026);
    final bookable = m(
      'Action Hero',
      false,
      1,
    ).copyWith(director: 'Jane Doe', genres: ['Action']);
    final hidden = m('Hidden Action', false, 99).copyWith(isActive: false);
    final c = aggregateUserCatalog(
      movies: [bookable, hidden],
      showtimes: [
        s(bookable.id, now.add(const Duration(days: 1))),
        s(hidden.id, now.add(const Duration(days: 1))),
      ],
      now: now,
    );
    expect(searchUserMovies(c, 'jane').map((x) => x.id), ['Action Hero']);
    expect(searchUserMovies(c, 'action').map((x) => x.id), ['Action Hero']);
  });
}
