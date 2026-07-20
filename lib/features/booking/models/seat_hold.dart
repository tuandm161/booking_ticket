// ignore_for_file: curly_braces_in_flow_control_structures
import '../../rooms/models/cinema_seat.dart';
import '../../../core/utils/firestore_converters.dart';

class SeatHold {
  const SeatHold({
    required this.userId,
    required this.reservationId,
    required this.expiresAt,
  });
  final String userId;
  final String reservationId;
  final DateTime expiresAt;
  bool isActiveAt(DateTime now) => expiresAt.isAfter(now);
  factory SeatHold.fromMap(Map<String, Object?> map) => SeatHold(
    userId: map['userId'] as String? ?? '',
    reservationId: map['reservationId'] as String? ?? '',
    expiresAt:
        dateFromFirestore(map['expiresAt']) ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
  Map<String, Object?> toMap() => {
    'userId': userId,
    'reservationId': reservationId,
    'expiresAt': dateToFirestore(expiresAt),
  };
}

enum SeatAvailability { available, selected, heldByMe, heldByOther, booked }

SeatAvailability seatAvailability({
  required CinemaSeat seat,
  required Set<String> selectedCodes,
  required Set<String> bookedCodes,
  required Map<String, SeatHold> holds,
  required String? userId,
  required String? reservationId,
  required DateTime now,
}) {
  if (bookedCodes.contains(seat.code)) return SeatAvailability.booked;
  final hold = holds[seat.code];
  if (hold != null && hold.isActiveAt(now)) {
    if (hold.userId == userId &&
        hold.reservationId == reservationId &&
        selectedCodes.contains(seat.code))
      return SeatAvailability.selected;
    return hold.userId == userId && hold.reservationId == reservationId
        ? SeatAvailability.heldByMe
        : SeatAvailability.heldByOther;
  }
  return selectedCodes.contains(seat.code)
      ? SeatAvailability.selected
      : SeatAvailability.available;
}

int seatPrice(SeatType type, int basePrice) => switch (type) {
  SeatType.standard => basePrice,
  SeatType.vip => basePrice + 20000,
  SeatType.couple => basePrice * 2 + 20000,
};
