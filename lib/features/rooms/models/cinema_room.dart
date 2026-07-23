import '../../../core/utils/firestore_converters.dart';
import 'cinema_seat.dart';

enum RoomType { standard, vip, threeD }

extension RoomTypeX on RoomType {
  String get value => this == RoomType.threeD ? 'threeD' : name;
  String get label => switch (this) {
        RoomType.standard => 'Standard',
        RoomType.vip => 'VIP',
        RoomType.threeD => '3D',
      };
  static RoomType fromValue(Object? value) =>
      RoomType.values.where((item) => item.value == value).firstOrNull ??
      RoomType.standard;
}

class CinemaRoom {
  const CinemaRoom({
    this.id = '',
    this.cinemaId = '',
    this.cinemaName = '',
    required this.name,
    required this.roomType,
    required this.rowCount,
    required this.seatsPerRow,
    required this.vipRowStart,
    required this.coupleSeatCount,
    required this.seats,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String cinemaId;
  final String cinemaName;
  final String name;
  final RoomType roomType;
  final int rowCount;
  final int seatsPerRow;
  final int vipRowStart;
  final int coupleSeatCount;
  final List<CinemaSeat> seats;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CinemaRoom.fromMap(String id, Map<String, Object?> map) => CinemaRoom(
        id: id,
        cinemaId: map['cinemaId'] as String? ?? '',
        cinemaName: map['cinemaName'] as String? ?? '',
        name: map['name'] as String? ?? '',
        roomType: RoomTypeX.fromValue(map['roomType']),
        rowCount: (map['rowCount'] as num?)?.toInt() ?? 0,
        seatsPerRow: (map['seatsPerRow'] as num?)?.toInt() ?? 0,
        vipRowStart: (map['vipRowStart'] as num?)?.toInt() ?? 0,
        coupleSeatCount: (map['coupleSeatCount'] as num?)?.toInt() ?? 0,
        seats: (map['seats'] is Iterable
            ? (map['seats'] as Iterable)
                .whereType<Map>()
                .map(
                  (item) => CinemaSeat.fromMap(
                    item.map((k, v) => MapEntry(k.toString(), v)),
                  ),
                )
                .toList()
            : <CinemaSeat>[]),
        isActive: map['isActive'] as bool? ?? true,
        createdAt: dateFromFirestore(map['createdAt']),
        updatedAt: dateFromFirestore(map['updatedAt']),
      );

  Map<String, Object?> toMap() => {
        'cinemaId': cinemaId,
        'cinemaName': cinemaName,
        'name': name,
        'roomType': roomType.value,
        'rowCount': rowCount,
        'seatsPerRow': seatsPerRow,
        'vipRowStart': vipRowStart,
        'coupleSeatCount': coupleSeatCount,
        'seats': seats.map((seat) => seat.toMap()).toList(),
        'isActive': isActive,
        'createdAt': dateToFirestore(createdAt),
        'updatedAt': dateToFirestore(updatedAt),
      };

  CinemaRoom copyWith({
    String? id,
    String? cinemaId,
    String? cinemaName,
    String? name,
    RoomType? roomType,
    int? rowCount,
    int? seatsPerRow,
    int? vipRowStart,
    int? coupleSeatCount,
    List<CinemaSeat>? seats,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      CinemaRoom(
        id: id ?? this.id,
        cinemaId: cinemaId ?? this.cinemaId,
        cinemaName: cinemaName ?? this.cinemaName,
        name: name ?? this.name,
        roomType: roomType ?? this.roomType,
        rowCount: rowCount ?? this.rowCount,
        seatsPerRow: seatsPerRow ?? this.seatsPerRow,
        vipRowStart: vipRowStart ?? this.vipRowStart,
        coupleSeatCount: coupleSeatCount ?? this.coupleSeatCount,
        seats: seats ?? this.seats,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
