import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/constants/pricing_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../movies/models/movie.dart';
import '../../rooms/models/cinema_room.dart';
import '../models/showtime.dart';

bool showtimesOverlap(
  DateTime newStart,
  DateTime newEnd,
  DateTime oldStart,
  DateTime oldEnd,
) => newStart.isBefore(oldEnd) && newEnd.isAfter(oldStart);

class ShowtimeDraft {
  const ShowtimeDraft({
    required this.movieId,
    required this.roomId,
    required this.startTime,
    required this.basePrice,
    this.isActive = true,
  });
  final String movieId, roomId;
  final DateTime startTime;
  final int basePrice;
  final bool isActive;
  ShowtimeDraft copyWith({
    String? movieId,
    String? roomId,
    DateTime? startTime,
    int? basePrice,
    bool? isActive,
  }) => ShowtimeDraft(
    movieId: movieId ?? this.movieId,
    roomId: roomId ?? this.roomId,
    startTime: startTime ?? this.startTime,
    basePrice: basePrice ?? this.basePrice,
    isActive: isActive ?? this.isActive,
  );
}

class ShowtimeRepository {
  const ShowtimeRepository(this._firestore);
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _showtimes =>
      _firestore.collection(FirestorePaths.showtimes);
  Stream<List<Showtime>> watchShowtimes({
    DateTime? from,
    DateTime? to,
    bool includeInactive = true,
  }) => _showtimes
      .orderBy('startTime')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Showtime.fromMap(
                doc.id,
                Map<String, Object?>.from(doc.data()),
              ),
            )
            .where(
              (showtime) =>
                  (includeInactive || showtime.isActive) &&
                  (from == null || !showtime.startTime.isBefore(from)) &&
                  (to == null || showtime.startTime.isBefore(to)),
            )
            .toList(),
      );
  Stream<List<Showtime>> watchFutureShowtimesForMovie(String movieId) =>
      watchShowtimes(from: DateTime.now()).map(
        (items) => items
            .where(
              (showtime) => showtime.movieId == movieId && showtime.isActive,
            )
            .toList(),
      );
  Future<Showtime?> getShowtime(String id) async {
    final doc = await _showtimes.doc(id).get();
    return doc.exists && doc.data() != null
        ? Showtime.fromMap(doc.id, Map<String, Object?>.from(doc.data()!))
        : null;
  }

  Future<String> createShowtime(ShowtimeDraft draft) async {
    final context = await _loadContext(draft);
    final end = draft.startTime.add(
      Duration(minutes: context.movie.durationMinutes) +
          PricingConstants.cleaningBuffer,
    );
    await _validate(draft, end, context.movie);
    final now = Timestamp.now();
    final showtime = Showtime(
      movieId: context.movie.id,
      movieTitle: context.movie.title,
      moviePosterUrl: context.movie.posterUrl,
      roomId: context.room.id,
      roomName: context.room.name,
      startTime: draft.startTime,
      endTime: end,
      basePrice: draft.basePrice,
      isActive: draft.isActive,
      bookedSeatCodes: const [],
      heldSeats: const {},
      createdAt: now.toDate(),
      updatedAt: now.toDate(),
    );
    return (await _showtimes.add(showtime.toMap())).id;
  }

  Future<void> updateShowtime(String id, ShowtimeDraft draft) async {
    final old = await getShowtime(id);
    if (old == null)
      throw const AppException(
        code: 'not_found',
        message: 'Không tìm thấy suất chiếu.',
      );
    final locked =
        old.bookedSeatCodes.isNotEmpty ||
        old.heldSeats.values.any(
          (hold) => hold.expiresAt.isAfter(DateTime.now()),
        ) ||
        await hasBookings(id);
    final changed =
        old.movieId != draft.movieId ||
        old.roomId != draft.roomId ||
        old.startTime != draft.startTime ||
        old.basePrice != draft.basePrice;
    if (locked && changed)
      throw const AppException(
        code: 'showtime_locked',
        message:
            'Suất chiếu đã có ghế hoặc booking, chỉ được thay đổi trạng thái.',
      );
    final context = await _loadContext(draft);
    final end = draft.startTime.add(
      Duration(minutes: context.movie.durationMinutes) +
          PricingConstants.cleaningBuffer,
    );
    await _validate(
      draft,
      end,
      context.movie,
      excludingId: id,
      validateFuture: false,
    );
    final updated = old.copyWith(
      movieId: context.movie.id,
      movieTitle: context.movie.title,
      moviePosterUrl: context.movie.posterUrl,
      roomId: context.room.id,
      roomName: context.room.name,
      startTime: draft.startTime,
      endTime: end,
      basePrice: draft.basePrice,
      isActive: draft.isActive,
      updatedAt: DateTime.now(),
    );
    await _showtimes.doc(id).set(updated.toMap());
  }

  Future<void> setShowtimeActive(String id, bool active) => _showtimes
      .doc(id)
      .update({'isActive': active, 'updatedAt': Timestamp.now()});
  Future<bool> hasBookings(String showtimeId) async =>
      (await _firestore
              .collection(FirestorePaths.bookings)
              .where('showtimeId', isEqualTo: showtimeId)
              .limit(1)
              .get())
          .docs
          .isNotEmpty;
  Future<void> deleteShowtime(String id) async {
    final showtime = await getShowtime(id);
    if (showtime == null) return;
    if (showtime.bookedSeatCodes.isNotEmpty || await hasBookings(id))
      throw const AppException(
        code: 'showtime_referenced',
        message: 'Suất chiếu đã có ghế/booking; hãy ẩn suất chiếu.',
      );
    await _showtimes.doc(id).delete();
  }

  Future<bool> hasRoomConflict({
    required String roomId,
    required DateTime start,
    required DateTime end,
    String? excludingShowtimeId,
  }) async {
    final snapshot = await _showtimes
        .where('roomId', isEqualTo: roomId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.any((doc) {
      if (doc.id == excludingShowtimeId) return false;
      final item = Showtime.fromMap(
        doc.id,
        Map<String, Object?>.from(doc.data()),
      );
      return showtimesOverlap(start, end, item.startTime, item.endTime);
    });
  }

  Future<({Movie movie, CinemaRoom room})> _loadContext(
    ShowtimeDraft draft,
  ) async {
    final movieDoc = await _firestore
        .collection(FirestorePaths.movies)
        .doc(draft.movieId)
        .get();
    final roomDoc = await _firestore
        .collection(FirestorePaths.rooms)
        .doc(draft.roomId)
        .get();
    if (!movieDoc.exists || movieDoc.data() == null)
      throw const AppException(
        code: 'not_found',
        message: 'Không tìm thấy phim.',
      );
    if (!roomDoc.exists || roomDoc.data() == null)
      throw const AppException(
        code: 'not_found',
        message: 'Không tìm thấy phòng.',
      );
    final movie = Movie.fromMap(
      movieDoc.id,
      Map<String, Object?>.from(movieDoc.data()!),
    );
    final room = CinemaRoom.fromMap(
      roomDoc.id,
      Map<String, Object?>.from(roomDoc.data()!),
    );
    if (!movie.isActive || !room.isActive)
      throw const AppException(
        code: 'validation',
        message: 'Chỉ được chọn phim và phòng đang hoạt động.',
      );
    return (movie: movie, room: room);
  }

  Future<void> _validate(
    ShowtimeDraft draft,
    DateTime end,
    Movie movie, {
    String? excludingId,
    bool validateFuture = true,
  }) async {
    if (draft.basePrice <= 0)
      throw const AppException(
        code: 'validation',
        message: 'Giá vé phải lớn hơn 0.',
      );
    if (movie.durationMinutes <= 0)
      throw const AppException(
        code: 'validation',
        message: 'Thời lượng phim không hợp lệ.',
      );
    if (validateFuture && draft.startTime.isBefore(DateTime.now()))
      throw const AppException(
        code: 'validation',
        message: 'Suất chiếu phải ở tương lai.',
      );
    if (await hasRoomConflict(
      roomId: draft.roomId,
      start: draft.startTime,
      end: end,
      excludingShowtimeId: excludingId,
    ))
      throw const AppException(
        code: 'showtime_conflict',
        message: 'Phòng đã có suất chiếu trùng thời gian.',
      );
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
