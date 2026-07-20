import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_providers.dart';
import '../../../core/services/dio_provider.dart';
import '../data/movie_repository.dart';
import '../data/tmdb_api.dart';
import '../models/movie.dart';

final movieRepositoryProvider = Provider<MovieRepository>(
  (ref) => MovieRepository(ref.watch(firestoreProvider)),
);
final moviesProvider = StreamProvider<List<Movie>>(
  (ref) => ref.watch(movieRepositoryProvider).watchAllMovies(),
);
final tmdbApiProvider = Provider<TmdbApi>(
  (ref) => TmdbApi(ref.watch(dioProvider)),
);
