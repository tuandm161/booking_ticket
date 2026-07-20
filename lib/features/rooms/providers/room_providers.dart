import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_providers.dart';
import '../data/room_repository.dart';
import '../models/cinema_room.dart';

final roomRepositoryProvider = Provider<RoomRepository>(
  (ref) => RoomRepository(ref.watch(firestoreProvider)),
);
final roomsProvider = StreamProvider<List<CinemaRoom>>(
  (ref) => ref.watch(roomRepositoryProvider).watchRooms(),
);
