import '../../../core/utils/firestore_converters.dart';

enum MovieSource { manual, tmdb }

extension MovieSourceX on MovieSource {
  String get value => name;
  static MovieSource fromValue(Object? value) =>
      MovieSource.values.where((item) => item.value == value).firstOrNull ??
      MovieSource.manual;
}

enum MovieStatus { nowShowing, comingSoon, stopped }

extension MovieStatusX on MovieStatus {
  String get value => name;
  String get label => switch (this) {
    MovieStatus.nowShowing => 'Đang chiếu',
    MovieStatus.comingSoon => 'Sắp chiếu',
    MovieStatus.stopped => 'Ngừng chiếu',
  };
  static MovieStatus fromValue(Object? value) =>
      MovieStatus.values.where((item) => item.value == value).firstOrNull ??
      MovieStatus.stopped;
}

class Movie {
  const Movie({
    this.id = '',
    required this.source,
    this.tmdbId,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.backdropUrl,
    required this.durationMinutes,
    required this.genres,
    required this.releaseDate,
    required this.ageRating,
    required this.country,
    required this.director,
    required this.cast,
    required this.trailerUrl,
    required this.status,
    required this.isFeatured,
    required this.isActive,
    required this.bookingCount,
    this.createdAt,
    this.updatedAt,
  });
  final String id;
  final MovieSource source;
  final int? tmdbId;
  final String title;
  final String overview;
  final String posterUrl;
  final String backdropUrl;
  final int durationMinutes;
  final List<String> genres;
  final DateTime? releaseDate;
  final String ageRating;
  final String country;
  final String director;
  final List<String> cast;
  final String trailerUrl;
  final MovieStatus status;
  final bool isFeatured;
  final bool isActive;
  final int bookingCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  factory Movie.fromMap(String id, Map<String, Object?> map) => Movie(
    id: id,
    source: MovieSourceX.fromValue(map['source']),
    tmdbId: (map['tmdbId'] as num?)?.toInt(),
    title: map['title'] as String? ?? '',
    overview: map['overview'] as String? ?? '',
    posterUrl: map['posterUrl'] as String? ?? '',
    backdropUrl: map['backdropUrl'] as String? ?? '',
    durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
    genres: stringListFromFirestore(map['genres']),
    releaseDate: dateFromFirestore(map['releaseDate']),
    ageRating: map['ageRating'] as String? ?? '',
    country: map['country'] as String? ?? '',
    director: map['director'] as String? ?? '',
    cast: stringListFromFirestore(map['cast']),
    trailerUrl: map['trailerUrl'] as String? ?? '',
    status: MovieStatusX.fromValue(map['status']),
    isFeatured: map['isFeatured'] as bool? ?? false,
    isActive: map['isActive'] as bool? ?? true,
    bookingCount: (map['bookingCount'] as num?)?.toInt() ?? 0,
    createdAt: dateFromFirestore(map['createdAt']),
    updatedAt: dateFromFirestore(map['updatedAt']),
  );
  Map<String, Object?> toMap() => {
    'source': source.value,
    'tmdbId': tmdbId,
    'title': title,
    'overview': overview,
    'posterUrl': posterUrl,
    'backdropUrl': backdropUrl,
    'durationMinutes': durationMinutes,
    'genres': genres,
    'releaseDate': dateToFirestore(releaseDate),
    'ageRating': ageRating,
    'country': country,
    'director': director,
    'cast': cast,
    'trailerUrl': trailerUrl,
    'status': status.value,
    'isFeatured': isFeatured,
    'isActive': isActive,
    'bookingCount': bookingCount,
    'createdAt': dateToFirestore(createdAt),
    'updatedAt': dateToFirestore(updatedAt),
  };
  Movie copyWith({
    String? id,
    MovieSource? source,
    int? tmdbId,
    String? title,
    String? overview,
    String? posterUrl,
    String? backdropUrl,
    int? durationMinutes,
    List<String>? genres,
    DateTime? releaseDate,
    String? ageRating,
    String? country,
    String? director,
    List<String>? cast,
    String? trailerUrl,
    MovieStatus? status,
    bool? isFeatured,
    bool? isActive,
    int? bookingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Movie(
    id: id ?? this.id,
    source: source ?? this.source,
    tmdbId: tmdbId ?? this.tmdbId,
    title: title ?? this.title,
    overview: overview ?? this.overview,
    posterUrl: posterUrl ?? this.posterUrl,
    backdropUrl: backdropUrl ?? this.backdropUrl,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    genres: genres ?? this.genres,
    releaseDate: releaseDate ?? this.releaseDate,
    ageRating: ageRating ?? this.ageRating,
    country: country ?? this.country,
    director: director ?? this.director,
    cast: cast ?? this.cast,
    trailerUrl: trailerUrl ?? this.trailerUrl,
    status: status ?? this.status,
    isFeatured: isFeatured ?? this.isFeatured,
    isActive: isActive ?? this.isActive,
    bookingCount: bookingCount ?? this.bookingCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
