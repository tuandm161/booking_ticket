import 'package:booking_cinema/features/movies/models/tmdb_movie_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps TMDB details including director, cast and trailer', () {
    final details = TmdbMovieDetails.fromMap({
      'id': 10,
      'title': 'Movie',
      'overview': 'Desc',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'release_date': '2026-01-02',
      'runtime': 130,
      'genres': [
        {'name': 'Action'},
      ],
      'production_countries': [
        {'name': 'United States'},
      ],
      'credits': {
        'crew': [
          {'job': 'Director', 'name': 'Director Name'},
        ],
        'cast': [
          {'name': 'Actor One'},
          {'name': 'Actor Two'},
        ],
      },
      'videos': {
        'results': [
          {'site': 'YouTube', 'type': 'Trailer', 'key': 'abc'},
        ],
      },
    });
    expect(details.title, 'Movie');
    expect(details.genres, ['Action']);
    expect(details.director, 'Director Name');
    expect(details.cast, ['Actor One', 'Actor Two']);
    expect(details.trailerUrl, 'https://www.youtube.com/watch?v=abc');
    expect(details.posterUrl, 'https://image.tmdb.org/t/p/w500/poster.jpg');
  });
}
