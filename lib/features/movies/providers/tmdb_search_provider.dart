import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tmdb_movie_summary.dart';
import 'movie_providers.dart';

final tmdbSearchProvider = FutureProvider.autoDispose
    .family<List<TmdbMovieSummary>, String>(
      (ref, query) => ref.watch(tmdbApiProvider).searchMovies(query),
    );
