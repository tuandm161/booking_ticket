import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_paths.dart';
import '../utils/seat_generator.dart';
import '../../features/rooms/models/cinema_room.dart';

class SeedResult {
  const SeedResult({required this.createdCount, required this.skipped});
  final int createdCount;
  final bool skipped;
}

class SeedService {
  const SeedService(this._firestore);
  final FirebaseFirestore _firestore;

  Future<SeedResult> seedDefaultRooms() async {
    final rooms = _firestore.collection(FirestorePaths.rooms);
    final existing = await rooms.limit(1).get();
    if (existing.docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }
    const definitions = [
      ('Phòng 1', RoomType.standard, 8, 10, 6, 4),
      ('Phòng 2', RoomType.standard, 7, 10, 5, 4),
      ('Phòng 3', RoomType.vip, 7, 8, 3, 4),
      ('Phòng 4', RoomType.threeD, 8, 10, 5, 4),
      ('Phòng 5', RoomType.vip, 6, 8, 2, 3),
      ('Phòng 6', RoomType.standard, 6, 8, 5, 3),
    ];
    final now = Timestamp.now();
    final batch = _firestore.batch();
    for (final item in definitions) {
      final ref = rooms.doc();
      final seats = generateSeats(
        rowCount: item.$3,
        seatsPerRow: item.$4,
        vipRowStart: item.$5,
        coupleSeatCount: item.$6,
      );
      final room = CinemaRoom(
        name: item.$1,
        roomType: item.$2,
        rowCount: item.$3,
        seatsPerRow: item.$4,
        vipRowStart: item.$5,
        coupleSeatCount: item.$6,
        seats: seats,
        isActive: true,
        createdAt: now.toDate(),
        updatedAt: now.toDate(),
      );
      batch.set(ref, room.toMap());
    }
    await batch.commit();
    return const SeedResult(createdCount: 6, skipped: false);
  }
}
