import 'tmdb_movie_summary.dart';

class TmdbMovieDetails extends TmdbMovieSummary {
  const TmdbMovieDetails({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.releaseDate,
    required this.backdropPath,
    required this.runtime,
    required this.genres,
    required this.country,
    required this.director,
    required this.cast,
    required this.trailerUrl,
  });
  final String? backdropPath;
  final int? runtime;
  final List<String> genres, cast;
  final String country, director;
  final String? trailerUrl;
  factory TmdbMovieDetails.fromMap(Map<String, Object?> map) {
    final genreMaps = map['genres'] is Iterable
        ? map['genres'] as Iterable
        : const [];
    final countries = map['production_countries'] is Iterable
        ? map['production_countries'] as Iterable
        : const [];
    final credits = map['credits'] is Map
        ? Map<String, Object?>.from(map['credits'] as Map)
        : <String, Object?>{};
    final crew = credits['crew'] is Iterable
        ? credits['crew'] as Iterable
        : const [];
    final castItems = credits['cast'] is Iterable
        ? credits['cast'] as Iterable
        : const [];
    final videos = map['videos'] is Map
        ? Map<String, Object?>.from(map['videos'] as Map)['results']
        : null;
    String? trailer;
    if (videos is Iterable) {
      for (final video in videos.whereType<Map>()) {
        if (video['site'] == 'YouTube' && video['type'] == 'Trailer') {
          trailer = 'https://www.youtube.com/watch?v=${video['key']}';
          break;
        }
      }
    }
    final directorMap = crew
        .whereType<Map>()
        .where((item) => item['job'] == 'Director')
        .firstOrNull;
    return TmdbMovieDetails(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title'] as String? ?? '',
      overview: map['overview'] as String? ?? '',
      posterPath: map['poster_path'] as String?,
      releaseDate: map['release_date'] as String?,
      backdropPath: map['backdrop_path'] as String?,
      runtime: (map['runtime'] as num?)?.toInt(),
      genres: genreMaps
          .whereType<Map>()
          .map((item) => item['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      country:
          countries
              .whereType<Map>()
              .map((item) => item['name'] as String? ?? '')
              .firstOrNull ??
          '',
      director: directorMap?['name'] as String? ?? '',
      cast: castItems
          .whereType<Map>()
          .map((item) => item['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .take(10)
          .toList(),
      trailerUrl: trailer,
    );
  }
}
