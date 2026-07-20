import 'package:booking_cinema/features/rooms/data/room_repository.dart';
import 'package:booking_cinema/features/rooms/models/cinema_room.dart';
import 'package:booking_cinema/features/rooms/models/cinema_seat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('room draft preview regenerates expected layout', () {
    const draft = RoomDraft(
      name: 'Phòng demo',
      roomType: RoomType.standard,
      rowCount: 8,
      seatsPerRow: 10,
      vipRowStart: 6,
      coupleSeatCount: 4,
    );
    expect(draft.previewSeats.length, 74);
    expect(
      draft.previewSeats.where((seat) => seat.type.value == 'vip').length,
      20,
    );
    expect(
      draft.previewSeats.where((seat) => seat.type.value == 'couple').length,
      4,
    );
  });

  test('room draft copyWith preserves unspecified values', () {
    const draft = RoomDraft(
      name: 'A',
      roomType: RoomType.vip,
      rowCount: 5,
      seatsPerRow: 8,
      vipRowStart: 2,
      coupleSeatCount: 2,
    );
    final changed = draft.copyWith(name: 'B', isActive: false);
    expect(changed.name, 'B');
    expect(changed.roomType, RoomType.vip);
    expect(changed.rowCount, 5);
    expect(changed.isActive, isFalse);
  });
}
