import '../../../core/utils/firestore_converters.dart';

class HeldSeat {
  const HeldSeat({
    required this.userId,
    required this.reservationId,
    required this.expiresAt,
  });
  final String userId;
  final String reservationId;
  final DateTime expiresAt;
  factory HeldSeat.fromMap(Map<String, Object?> map) => HeldSeat(
        userId: map['userId'] as String? ?? '',
        reservationId: map['reservationId'] as String? ?? '',
        expiresAt: dateFromFirestore(map['expiresAt']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
  Map<String, Object?> toMap() => {
        'userId': userId,
        'reservationId': reservationId,
        'expiresAt': dateToFirestore(expiresAt),
      };
}

class Showtime {
  const Showtime({
    this.id = '',
    this.cinemaId = '',
    this.cinemaName = '',
    required this.movieId,
    required this.movieTitle,
    required this.moviePosterUrl,
    required this.roomId,
    required this.roomName,
    required this.startTime,
    required this.endTime,
    required this.basePrice,
    required this.isActive,
    required this.bookedSeatCodes,
    required this.heldSeats,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String cinemaId;
  final String cinemaName;
  final String movieId;
  final String movieTitle;
  final String moviePosterUrl;
  final String roomId;
  final String roomName;
  final DateTime startTime;
  final DateTime endTime;
  final int basePrice;
  final bool isActive;
  final List<String> bookedSeatCodes;
  final Map<String, HeldSeat> heldSeats;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Showtime.fromMap(String id, Map<String, Object?> map) {
    final raw = map['heldSeats'] is Map ? map['heldSeats'] as Map : const {};
    return Showtime(
      id: id,
      cinemaId: map['cinemaId'] as String? ?? '',
      cinemaName: map['cinemaName'] as String? ?? '',
      movieId: map['movieId'] as String? ?? '',
      movieTitle: map['movieTitle'] as String? ?? '',
      moviePosterUrl: map['moviePosterUrl'] as String? ?? '',
      roomId: map['roomId'] as String? ?? '',
      roomName: map['roomName'] as String? ?? '',
      startTime: dateFromFirestore(map['startTime']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endTime: dateFromFirestore(map['endTime']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      basePrice: (map['basePrice'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      bookedSeatCodes: stringListFromFirestore(map['bookedSeatCodes']),
      heldSeats: raw.map(
        (key, value) => MapEntry(
            key.toString(), HeldSeat.fromMap(mapFromFirestore(value))),
      ),
      createdAt: dateFromFirestore(map['createdAt']),
      updatedAt: dateFromFirestore(map['updatedAt']),
    );
  }

  Map<String, Object?> toMap() => {
        'cinemaId': cinemaId,
        'cinemaName': cinemaName,
        'movieId': movieId,
        'movieTitle': movieTitle,
        'moviePosterUrl': moviePosterUrl,
        'roomId': roomId,
        'roomName': roomName,
        'startTime': dateToFirestore(startTime),
        'endTime': dateToFirestore(endTime),
        'basePrice': basePrice,
        'isActive': isActive,
        'bookedSeatCodes': bookedSeatCodes,
        'heldSeats': heldSeats.map((key, value) => MapEntry(key, value.toMap())),
        'createdAt': dateToFirestore(createdAt),
        'updatedAt': dateToFirestore(updatedAt),
      };

  Showtime copyWith({
    String? id,
    String? cinemaId,
    String? cinemaName,
    String? movieId,
    String? movieTitle,
    String? moviePosterUrl,
    String? roomId,
    String? roomName,
    DateTime? startTime,
    DateTime? endTime,
    int? basePrice,
    bool? isActive,
    List<String>? bookedSeatCodes,
    Map<String, HeldSeat>? heldSeats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Showtime(
        id: id ?? this.id,
        cinemaId: cinemaId ?? this.cinemaId,
        cinemaName: cinemaName ?? this.cinemaName,
        movieId: movieId ?? this.movieId,
        movieTitle: movieTitle ?? this.movieTitle,
        moviePosterUrl: moviePosterUrl ?? this.moviePosterUrl,
        roomId: roomId ?? this.roomId,
        roomName: roomName ?? this.roomName,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        basePrice: basePrice ?? this.basePrice,
        isActive: isActive ?? this.isActive,
        bookedSeatCodes: bookedSeatCodes ?? this.bookedSeatCodes,
        heldSeats: heldSeats ?? this.heldSeats,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
