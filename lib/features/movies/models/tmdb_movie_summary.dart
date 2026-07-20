class TmdbMovieSummary {
  const TmdbMovieSummary({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
  });
  final int id;
  final String title, overview;
  final String? posterPath, releaseDate;
  factory TmdbMovieSummary.fromMap(Map<String, Object?> map) =>
      TmdbMovieSummary(
        id: (map['id'] as num?)?.toInt() ?? 0,
        title: map['title'] as String? ?? '',
        overview: map['overview'] as String? ?? '',
        posterPath: map['poster_path'] as String?,
        releaseDate: map['release_date'] as String?,
      );
  String? get posterUrl =>
      posterPath == null ? null : 'https://image.tmdb.org/t/p/w500$posterPath';
}
