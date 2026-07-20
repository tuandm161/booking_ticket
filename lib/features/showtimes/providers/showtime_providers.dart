import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_providers.dart';
import '../../movies/providers/movie_providers.dart';
import '../../rooms/providers/room_providers.dart';
import '../data/showtime_repository.dart';
import '../models/showtime.dart';

final showtimeRepositoryProvider = Provider<ShowtimeRepository>(
  (ref) => ShowtimeRepository(ref.watch(firestoreProvider)),
);
final showtimesProvider = StreamProvider<List<Showtime>>(
  (ref) => ref.watch(showtimeRepositoryProvider).watchShowtimes(),
);
final activeMoviesProvider = FutureProvider(
  (ref) => ref
      .watch(movieRepositoryProvider)
      .watchAllMovies(includeInactive: false)
      .first,
);
final activeRoomsProvider = FutureProvider(
  (ref) => ref
      .watch(roomRepositoryProvider)
      .watchRooms(includeInactive: false)
      .first,
);
