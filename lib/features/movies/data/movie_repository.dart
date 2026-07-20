import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../models/movie.dart';

class MovieDraft {
  const MovieDraft({
    required this.source,
    this.tmdbId,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.backdropUrl,
    required this.durationMinutes,
    required this.genres,
    this.releaseDate,
    required this.ageRating,
    required this.country,
    required this.director,
    required this.cast,
    required this.trailerUrl,
    required this.status,
    required this.isFeatured,
    required this.isActive,
  });
  final MovieSource source;
  final int? tmdbId;
  final String title, overview, posterUrl, backdropUrl;
  final int durationMinutes;
  final List<String> genres;
  final DateTime? releaseDate;
  final String ageRating, country, director, trailerUrl;
  final List<String> cast;
  final MovieStatus status;
  final bool isFeatured, isActive;
  MovieDraft copyWith({
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
  }) => MovieDraft(
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
  );
}

class MovieRepository {
  const MovieRepository(this._firestore);
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _movies =>
      _firestore.collection(FirestorePaths.movies);
  Stream<List<Movie>> watchAllMovies({bool includeInactive = true}) => _movies
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) =>
                  Movie.fromMap(doc.id, Map<String, Object?>.from(doc.data())),
            )
            .where((movie) => includeInactive || movie.isActive)
            .toList(),
      );
  Future<Movie?> getMovie(String id) async {
    final doc = await _movies.doc(id).get();
    return doc.exists && doc.data() != null
        ? Movie.fromMap(doc.id, Map<String, Object?>.from(doc.data()!))
        : null;
  }

  Future<String> createMovie(MovieDraft draft) async {
    _validate(draft);
    final now = Timestamp.now();
    final movie = Movie(
      source: draft.source,
      tmdbId: draft.tmdbId,
      title: draft.title.trim(),
      overview: draft.overview.trim(),
      posterUrl: draft.posterUrl.trim(),
      backdropUrl: draft.backdropUrl.trim(),
      durationMinutes: draft.durationMinutes,
      genres: draft.genres,
      releaseDate: draft.releaseDate,
      ageRating: draft.ageRating.trim(),
      country: draft.country.trim(),
      director: draft.director.trim(),
      cast: draft.cast.take(10).toList(),
      trailerUrl: draft.trailerUrl.trim(),
      status: draft.status,
      isFeatured: draft.isFeatured,
      isActive: draft.isActive,
      bookingCount: 0,
      createdAt: now.toDate(),
      updatedAt: now.toDate(),
    );
    try {
      return (await _movies.add(movie.toMap())).id;
    } on FirebaseException catch (error) {
      throw AppException(
        code: error.code,
        message: 'Không thể tạo phim.',
        cause: error,
      );
    }
  }

  Future<void> updateMovie(String id, MovieDraft draft) async {
    _validate(draft);
    final old = await getMovie(id);
    if (old == null)
      throw const AppException(
        code: 'not_found',
        message: 'Không tìm thấy phim.',
      );
    final movie = Movie(
      id: id,
      source: draft.source,
      tmdbId: draft.tmdbId,
      title: draft.title.trim(),
      overview: draft.overview.trim(),
      posterUrl: draft.posterUrl.trim(),
      backdropUrl: draft.backdropUrl.trim(),
      durationMinutes: draft.durationMinutes,
      genres: draft.genres,
      releaseDate: draft.releaseDate,
      ageRating: draft.ageRating.trim(),
      country: draft.country.trim(),
      director: draft.director.trim(),
      cast: draft.cast.take(10).toList(),
      trailerUrl: draft.trailerUrl.trim(),
      status: draft.status,
      isFeatured: draft.isFeatured,
      isActive: draft.isActive,
      bookingCount: old.bookingCount,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
    );
    await _movies.doc(id).set(movie.toMap());
  }

  Future<void> setMovieActive(String id, bool active) => _movies.doc(id).update(
    {'isActive': active, 'updatedAt': Timestamp.now()},
  );
  Future<bool> hasShowtimes(String movieId) async =>
      (await _firestore
              .collection(FirestorePaths.showtimes)
              .where('movieId', isEqualTo: movieId)
              .limit(1)
              .get())
          .docs
          .isNotEmpty;
  Future<bool> hasBookings(String movieId) async =>
      (await _firestore
              .collection(FirestorePaths.bookings)
              .where('movieId', isEqualTo: movieId)
              .limit(1)
              .get())
          .docs
          .isNotEmpty;
  Future<void> deleteMovie(String id) async {
    if (await hasShowtimes(id) || await hasBookings(id))
      throw const AppException(
        code: 'movie_referenced',
        message: 'Phim đã có suất chiếu hoặc booking; hãy ẩn phim thay vì xóa.',
      );
    await _movies.doc(id).delete();
  }

  void _validate(MovieDraft draft) {
    if (requiredText(draft.title, field: 'Tên phim') != null ||
        requiredText(draft.overview, field: 'Mô tả') != null ||
        urlValidator(draft.posterUrl) != null ||
        draft.durationMinutes <= 0)
      throw const AppException(
        code: 'validation',
        message: 'Thông tin phim chưa hợp lệ.',
      );
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
