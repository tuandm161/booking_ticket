import '../../rooms/models/cinema_seat.dart';

class SeatItem {
  const SeatItem({
    required this.code,
    required this.type,
    required this.capacity,
    required this.unitPrice,
  });
  final String code;
  final SeatType type;
  final int capacity, unitPrice;
  factory SeatItem.fromMap(Map<String, Object?> m) => SeatItem(
    code: m['code'] as String? ?? '',
    type: SeatTypeX.fromValue(m['type']),
    capacity: (m['capacity'] as num?)?.toInt() ?? 1,
    unitPrice: (m['unitPrice'] as num?)?.toInt() ?? 0,
  );
  Map<String, Object?> toMap() => {
    'code': code,
    'type': type.value,
    'capacity': capacity,
    'unitPrice': unitPrice,
  };
}
