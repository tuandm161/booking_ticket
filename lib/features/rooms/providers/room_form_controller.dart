import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/room_repository.dart';
import '../models/cinema_room.dart';

final roomFormControllerProvider =
    NotifierProvider<RoomFormController, RoomDraft>(RoomFormController.new);

class RoomFormController extends Notifier<RoomDraft> {
  @override
  RoomDraft build() => const RoomDraft(
    name: '',
    roomType: RoomType.standard,
    rowCount: 8,
    seatsPerRow: 10,
    vipRowStart: 0,
    coupleSeatCount: 0,
  );
  void setDraft(RoomDraft draft) => state = draft;
  void update({
    String? name,
    RoomType? roomType,
    int? rowCount,
    int? seatsPerRow,
    int? vipRowStart,
    int? coupleSeatCount,
    bool? isActive,
  }) => state = state.copyWith(
    name: name,
    roomType: roomType,
    rowCount: rowCount,
    seatsPerRow: seatsPerRow,
    vipRowStart: vipRowStart,
    coupleSeatCount: coupleSeatCount,
    isActive: isActive,
  );
}
