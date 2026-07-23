import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_providers.dart';
import '../data/cinema_repository.dart';
import '../models/cinema.dart';

final cinemaRepositoryProvider = Provider<CinemaRepository>(
  (ref) => CinemaRepository(ref.watch(firestoreProvider)),
);

final cinemasProvider = StreamProvider<List<Cinema>>((ref) {
  return ref.watch(cinemaRepositoryProvider).watchCinemas(includeInactive: true);
});

final activeCinemasProvider = StreamProvider<List<Cinema>>((ref) {
  return ref.watch(cinemaRepositoryProvider).watchCinemas(includeInactive: false);
});
