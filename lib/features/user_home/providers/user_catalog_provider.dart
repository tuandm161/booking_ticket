import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/services/firebase_providers.dart';
import '../../movies/models/movie.dart';
import '../../showtimes/models/showtime.dart';
import '../models/user_catalog.dart';

final userCatalogProvider = StreamProvider<UserCatalog>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final controller = StreamController<UserCatalog>();
  List<Movie> movies = [];
  List<Showtime> showtimes = [];
  var moviesReady = false;
  var showtimesReady = false;
  void emit() {
    if (!moviesReady || !showtimesReady) return;
    controller.add(
      aggregateUserCatalog(
        movies: movies,
        showtimes: showtimes,
        now: DateTime.now(),
      ),
    );
  }

  final msub = firestore.collection(FirestorePaths.movies).snapshots().listen((
    s,
  ) {
    moviesReady = true;
    movies = s.docs
        .map((d) => Movie.fromMap(d.id, Map<String, Object?>.from(d.data())))
        .toList();
    emit();
  }, onError: controller.addError);
  final ssub = firestore
      .collection(FirestorePaths.showtimes)
      .snapshots()
      .listen((s) {
        showtimesReady = true;
        showtimes = s.docs
            .map(
              (d) =>
                  Showtime.fromMap(d.id, Map<String, Object?>.from(d.data())),
            )
            .toList();
        emit();
      }, onError: controller.addError);
  ref.onDispose(() {
    msub.cancel();
    ssub.cancel();
    controller.close();
  });
  return controller.stream;
});
