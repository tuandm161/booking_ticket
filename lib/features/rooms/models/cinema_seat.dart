enum SeatType { standard, vip, couple }

extension SeatTypeX on SeatType {
  String get value => name;
  String get label => switch (this) {
    SeatType.standard => 'Standard',
    SeatType.vip => 'VIP',
    SeatType.couple => 'Couple',
  };
  static SeatType fromValue(Object? value) =>
      SeatType.values.where((item) => item.value == value).firstOrNull ??
      SeatType.standard;
}

class CinemaSeat {
  const CinemaSeat({
    required this.code,
    required this.row,
    required this.number,
    required this.type,
    required this.capacity,
  });
  final String code;
  final String row;
  final int number;
  final SeatType type;
  final int capacity;
  factory CinemaSeat.fromMap(Map<String, Object?> map) => CinemaSeat(
    code: map['code'] as String? ?? '',
    row: map['row'] as String? ?? '',
    number: (map['number'] as num?)?.toInt() ?? 0,
    type: SeatTypeX.fromValue(map['type']),
    capacity: (map['capacity'] as num?)?.toInt() ?? 1,
  );
  Map<String, Object?> toMap() => {
    'code': code,
    'row': row,
    'number': number,
    'type': type.value,
    'capacity': capacity,
  };
  CinemaSeat copyWith({
    String? code,
    String? row,
    int? number,
    SeatType? type,
    int? capacity,
  }) => CinemaSeat(
    code: code ?? this.code,
    row: row ?? this.row,
    number: number ?? this.number,
    type: type ?? this.type,
    capacity: capacity ?? this.capacity,
  );
}
