import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/movie_repository.dart';
import '../models/movie.dart';

final movieFormControllerProvider =
    NotifierProvider<MovieFormController, MovieDraft>(MovieFormController.new);

class MovieFormController extends Notifier<MovieDraft> {
  @override
  MovieDraft build() => const MovieDraft(
    source: MovieSource.manual,
    title: '',
    overview: '',
    posterUrl: '',
    backdropUrl: '',
    durationMinutes: 120,
    genres: [],
    ageRating: '',
    country: '',
    director: '',
    cast: [],
    trailerUrl: '',
    status: MovieStatus.comingSoon,
    isFeatured: false,
    isActive: true,
  );
  void setDraft(MovieDraft draft) => state = draft;
}
