import 'package:booking_cinema/features/movies/data/movie_repository.dart';
import 'package:booking_cinema/features/movies/models/movie.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('movie draft preserves manual source and fields', () {
    const draft = MovieDraft(
      source: MovieSource.manual,
      title: 'Demo',
      overview: 'Overview',
      posterUrl: 'https://example.com/poster.jpg',
      backdropUrl: '',
      durationMinutes: 120,
      genres: ['Action'],
      ageRating: 'T13',
      country: 'VN',
      director: 'A',
      cast: ['B'],
      trailerUrl: '',
      status: MovieStatus.nowShowing,
      isFeatured: false,
      isActive: true,
    );
    final changed = draft.copyWith(title: 'Changed', isFeatured: true);
    expect(changed.source, MovieSource.manual);
    expect(changed.title, 'Changed');
    expect(changed.durationMinutes, 120);
    expect(changed.isFeatured, isTrue);
  });
}
