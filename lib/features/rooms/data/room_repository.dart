import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/seat_generator.dart';
import '../models/cinema_room.dart';
import '../models/cinema_seat.dart';

class RoomDraft {
  const RoomDraft({
    this.cinemaId = '',
    this.cinemaName = '',
    required this.name,
    required this.roomType,
    required this.rowCount,
    required this.seatsPerRow,
    required this.vipRowStart,
    required this.coupleSeatCount,
    this.isActive = true,
  });
  final String cinemaId;
  final String cinemaName;
  final String name;
  final RoomType roomType;
  final int rowCount, seatsPerRow, vipRowStart, coupleSeatCount;
  final bool isActive;
  List<CinemaSeat> get previewSeats => generateSeats(
        rowCount: rowCount,
        seatsPerRow: seatsPerRow,
        vipRowStart: vipRowStart,
        coupleSeatCount: coupleSeatCount,
      );
  RoomDraft copyWith({
    String? cinemaId,
    String? cinemaName,
    String? name,
    RoomType? roomType,
    int? rowCount,
    int? seatsPerRow,
    int? vipRowStart,
    int? coupleSeatCount,
    bool? isActive,
  }) =>
      RoomDraft(
        cinemaId: cinemaId ?? this.cinemaId,
        cinemaName: cinemaName ?? this.cinemaName,
        name: name ?? this.name,
        roomType: roomType ?? this.roomType,
        rowCount: rowCount ?? this.rowCount,
        seatsPerRow: seatsPerRow ?? this.seatsPerRow,
        vipRowStart: vipRowStart ?? this.vipRowStart,
        coupleSeatCount: coupleSeatCount ?? this.coupleSeatCount,
        isActive: isActive ?? this.isActive,
      );
}

class RoomRepository {
  const RoomRepository(this._firestore);
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection(FirestorePaths.rooms);

  Stream<List<CinemaRoom>> watchRooms({bool includeInactive = true}) => _rooms
      .orderBy('name')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => CinemaRoom.fromMap(
                doc.id,
                Map<String, Object?>.from(doc.data()),
              ),
            )
            .where((room) => includeInactive || room.isActive)
            .toList(),
      );
  Future<CinemaRoom?> getRoom(String roomId) async {
    final doc = await _rooms.doc(roomId).get();
    return doc.exists && doc.data() != null
        ? CinemaRoom.fromMap(doc.id, Map<String, Object?>.from(doc.data()!))
        : null;
  }

  Future<String> createRoom(RoomDraft draft) async {
    await _ensureValidName(draft.name);
    final now = Timestamp.now();
    final room = CinemaRoom(
      name: draft.name.trim(),
      cinemaId: draft.cinemaId,
      cinemaName: draft.cinemaName,
      roomType: draft.roomType,
      rowCount: draft.rowCount,
      seatsPerRow: draft.seatsPerRow,
      vipRowStart: draft.vipRowStart,
      coupleSeatCount: draft.coupleSeatCount,
      seats: draft.previewSeats.cast(),
      isActive: draft.isActive,
      createdAt: now.toDate(),
      updatedAt: now.toDate(),
    );
    try {
      return (await _rooms.add(room.toMap())).id;
    } on FirebaseException catch (error) {
      throw AppException(
        code: error.code,
        message: 'Không thể tạo phòng.',
        cause: error,
      );
    }
  }

  Future<void> updateRoom(String roomId, RoomDraft draft) async {
    final old = await getRoom(roomId);
    if (old == null) {
      throw const AppException(
        code: 'not_found',
        message: 'Không tìm thấy phòng.',
      );
    }
    await _ensureValidName(draft.name, excludingId: roomId);
    final layoutChanged =
        old.rowCount != draft.rowCount ||
        old.seatsPerRow != draft.seatsPerRow ||
        old.vipRowStart != draft.vipRowStart ||
        old.coupleSeatCount != draft.coupleSeatCount;
    if (layoutChanged && await hasFutureShowtime(roomId)) {
      throw const AppException(
        code: 'room_layout_locked',
        message:
            'Không thể đổi sơ đồ ghế khi phòng đã có suất chiếu tương lai.',
      );
    }
    final now = Timestamp.now();
    final room = CinemaRoom(
      id: roomId,
      cinemaId: draft.cinemaId.isNotEmpty ? draft.cinemaId : old.cinemaId,
      cinemaName: draft.cinemaName.isNotEmpty ? draft.cinemaName : old.cinemaName,
      name: draft.name.trim(),
      roomType: draft.roomType,
      rowCount: draft.rowCount,
      seatsPerRow: draft.seatsPerRow,
      vipRowStart: draft.vipRowStart,
      coupleSeatCount: draft.coupleSeatCount,
      seats: draft.previewSeats.cast(),
      isActive: draft.isActive,
      createdAt: old.createdAt,
      updatedAt: now.toDate(),
    );
    try {
      await _rooms.doc(roomId).set(room.toMap());
    } on FirebaseException catch (error) {
      throw AppException(
        code: error.code,
        message: 'Không thể cập nhật phòng.',
        cause: error,
      );
    }
  }

  Future<void> setRoomActive(String roomId, bool isActive) => _rooms
      .doc(roomId)
      .update({'isActive': isActive, 'updatedAt': Timestamp.now()});
  Future<bool> hasAnyShowtime(String roomId) async =>
      (await _firestore
              .collection(FirestorePaths.showtimes)
              .where('roomId', isEqualTo: roomId)
              .limit(1)
              .get())
          .docs
          .isNotEmpty;
  Future<bool> hasFutureShowtime(String roomId) async =>
      (await _firestore
              .collection(FirestorePaths.showtimes)
              .where('roomId', isEqualTo: roomId)
              .where('startTime', isGreaterThan: Timestamp.now())
              .limit(1)
              .get())
          .docs
          .isNotEmpty;
  Future<void> deleteRoom(String roomId) async {
    if (await hasAnyShowtime(roomId)) {
      throw const AppException(
        code: 'room_referenced',
        message:
            'Phòng đã được tham chiếu bởi suất chiếu; hãy chuyển sang ngừng hoạt động.',
      );
    }
    await _rooms.doc(roomId).delete();
  }

  Future<void> _ensureValidName(String name, {String? excludingId}) async {
    if (name.trim().isEmpty) {
      throw const AppException(
        code: 'validation',
        message: 'Tên phòng không được để trống.',
      );
    }
    final snapshot = await _rooms.get();
    final duplicate = snapshot.docs.any(
      (doc) =>
          doc.id != excludingId &&
          ((doc.data()['name'] as String?) ?? '').trim().toLowerCase() ==
              name.trim().toLowerCase(),
    );
    if (duplicate) {
      throw const AppException(
        code: 'validation',
        message: 'Tên phòng đã tồn tại.',
      );
    }
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
