// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/constants/pricing_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../rooms/models/cinema_room.dart';
import '../../showtimes/models/showtime.dart';

Map<String, HeldSeat> mergeHeldSeats({
  required CinemaRoom room,
  required Showtime showtime,
  required List<String> selectedSeatCodes,
  required String userId,
  required String reservationId,
  required DateTime now,
  required DateTime expiresAt,
}) {
  final unique = selectedSeatCodes.toSet();
  if (unique.length > PricingConstants.maxSeatUnitsPerBooking)
    throw const AppException(
      code: 'too_many_seats',
      message: 'Bạn chỉ có thể chọn tối đa 8 ghế.',
    );
  final validCodes = room.seats.map((seat) => seat.code).toSet();
  if (unique.isEmpty ||
      unique.length != selectedSeatCodes.length ||
      unique.any((code) => !validCodes.contains(code)))
    throw const AppException(
      code: 'invalid_seat',
      message: 'Ghế đã chọn không thuộc sơ đồ phòng.',
    );
  final holds = <String, HeldSeat>{...showtime.heldSeats}
    ..removeWhere((_, hold) => !hold.expiresAt.isAfter(now));
  for (final code in unique) {
    if (showtime.bookedSeatCodes.contains(code))
      throw const AppException(
        code: 'seat_booked',
        message: 'Có ghế vừa được đặt bởi người khác.',
      );
    final current = holds[code];
    if (current != null &&
        current.expiresAt.isAfter(now) &&
        current.userId != userId)
      throw const AppException(
        code: 'seat_held',
        message: 'Có ghế đang được người khác giữ.',
      );
  }
  for (final code in unique)
    holds[code] = HeldSeat(
      userId: userId,
      reservationId: reservationId,
      expiresAt: expiresAt,
    );
  return holds;
}

Map<String, HeldSeat> releaseMatchingHolds({
  required Map<String, HeldSeat> source,
  required String userId,
  required String reservationId,
  required DateTime now,
}) => <String, HeldSeat>{...source}
  ..removeWhere(
    (_, hold) =>
        (hold.userId == userId && hold.reservationId == reservationId) ||
        !hold.expiresAt.isAfter(now),
  );

class SeatHoldRepository {
  const SeatHoldRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Future<DateTime> holdSeats({
    required String showtimeId,
    required String userId,
    required List<String> selectedSeatCodes,
    required String reservationId,
    required DateTime now,
    required DateTime expiresAt,
  }) async {
    if (selectedSeatCodes.isEmpty)
      throw const AppException(
        code: 'no_seats',
        message: 'Hãy chọn ít nhất một ghế.',
      );
    if (expiresAt.isBefore(now) || !expiresAt.isAfter(now))
      throw const AppException(
        code: 'hold_expired',
        message: 'Thời gian giữ ghế không hợp lệ.',
      );
    final ref = _firestore.collection(FirestorePaths.showtimes).doc(showtimeId);
    return _firestore.runTransaction((transaction) async {
      final showtimeDoc = await transaction.get(ref);
      if (!showtimeDoc.exists || showtimeDoc.data() == null)
        throw const AppException(
          code: 'not_found',
          message: 'Không tìm thấy suất chiếu.',
        );
      final showtime = Showtime.fromMap(
        showtimeId,
        Map<String, Object?>.from(showtimeDoc.data()!),
      );
      if (!showtime.isActive || !showtime.startTime.isAfter(now))
        throw const AppException(
          code: 'showtime_unavailable',
          message: 'Suất chiếu không còn khả dụng.',
        );
      final roomDoc = await transaction.get(
        _firestore.collection(FirestorePaths.rooms).doc(showtime.roomId),
      );
      if (!roomDoc.exists || roomDoc.data() == null)
        throw const AppException(
          code: 'room_not_found',
          message: 'Không tìm thấy sơ đồ phòng.',
        );
      final room = CinemaRoom.fromMap(
        showtime.roomId,
        Map<String, Object?>.from(roomDoc.data()!),
      );
      final holds = mergeHeldSeats(
        room: room,
        showtime: showtime,
        selectedSeatCodes: selectedSeatCodes,
        userId: userId,
        reservationId: reservationId,
        now: now,
        expiresAt: expiresAt,
      );
      transaction.update(ref, {
        'heldSeats': holds.map((key, value) => MapEntry(key, value.toMap())),
        'updatedAt': Timestamp.fromDate(now),
      });
      return expiresAt;
    });
  }

  Future<void> releaseHeldSeats({
    required String showtimeId,
    required String userId,
    required String reservationId,
    required DateTime now,
  }) async {
    final ref = _firestore.collection(FirestorePaths.showtimes).doc(showtimeId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists || doc.data() == null) return;
      final showtime = Showtime.fromMap(
        showtimeId,
        Map<String, Object?>.from(doc.data()!),
      );
      final holds = releaseMatchingHolds(
        source: showtime.heldSeats,
        userId: userId,
        reservationId: reservationId,
        now: now,
      );
      transaction.update(ref, {
        'heldSeats': holds.map((key, value) => MapEntry(key, value.toMap())),
        'updatedAt': Timestamp.fromDate(now),
      });
    });
  }
}
