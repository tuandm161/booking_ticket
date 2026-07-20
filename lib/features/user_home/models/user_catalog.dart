import '../../movies/models/movie.dart';
import '../../showtimes/models/showtime.dart';

class UserCatalog {
  const UserCatalog({
    required this.nowShowing,
    required this.comingSoon,
    required this.popular,
    this.bookable = const [],
  });
  final List<Movie> nowShowing;
  final List<Movie> comingSoon;
  final List<Movie> popular;
  final List<Movie> bookable;
  List<Movie> get all => bookable.isNotEmpty
      ? bookable
      : {...nowShowing, ...comingSoon, ...popular}.toList();
}

UserCatalog aggregateUserCatalog({
  required List<Movie> movies,
  required List<Showtime> showtimes,
  required DateTime now,
}) {
  final ids = showtimes
      .where((s) => s.isActive && s.startTime.isAfter(now))
      .map((s) => s.movieId)
      .toSet();
  final bookable = movies
      .where((m) => m.isActive && ids.contains(m.id))
      .toList();
  final popular = [...bookable]
    ..sort((a, b) {
      final featured = (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0);
      return featured != 0
          ? featured
          : b.bookingCount.compareTo(a.bookingCount);
    });
  return UserCatalog(
    nowShowing: bookable
        .where((m) => m.status == MovieStatus.nowShowing)
        .toList(),
    comingSoon: bookable
        .where((m) => m.status == MovieStatus.comingSoon)
        .toList(),
    popular: popular,
    bookable: bookable,
  );
}

List<Movie> searchUserMovies(UserCatalog catalog, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return catalog.popular;
  return catalog.all
      .where(
        (m) => [
          m.title,
          m.director,
          ...m.genres,
        ].any((v) => v.toLowerCase().contains(q)),
      )
      .toSet()
      .toList();
}
