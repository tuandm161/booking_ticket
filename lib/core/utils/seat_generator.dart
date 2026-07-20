import '../../features/rooms/models/cinema_seat.dart';

List<CinemaSeat> generateSeats({
  required int rowCount,
  required int seatsPerRow,
  required int vipRowStart,
  required int coupleSeatCount,
}) {
  if (rowCount <= 0 || rowCount > 20) {
    throw ArgumentError('rowCount phải từ 1 đến 20.');
  }
  if (seatsPerRow <= 0) {
    throw ArgumentError('seatsPerRow phải lớn hơn 0.');
  }
  if (coupleSeatCount < 0 || coupleSeatCount > seatsPerRow) {
    throw ArgumentError('coupleSeatCount không hợp lệ.');
  }
  if (vipRowStart < 0 || vipRowStart > rowCount) {
    throw ArgumentError('vipRowStart không hợp lệ.');
  }
  final seats = <CinemaSeat>[];
  for (var rowIndex = 1; rowIndex <= rowCount; rowIndex++) {
    final row = String.fromCharCode(64 + rowIndex);
    final isLast = rowIndex == rowCount;
    if (isLast && coupleSeatCount > 0) {
      for (var number = 1; number <= coupleSeatCount; number++) {
        seats.add(
          CinemaSeat(
            code: '$row$number',
            row: row,
            number: number,
            type: SeatType.couple,
            capacity: 2,
          ),
        );
      }
      continue;
    }
    final type = vipRowStart > 0 && rowIndex >= vipRowStart
        ? SeatType.vip
        : SeatType.standard;
    for (var number = 1; number <= seatsPerRow; number++) {
      seats.add(
        CinemaSeat(
          code: '$row$number',
          row: row,
          number: number,
          type: type,
          capacity: 1,
        ),
      );
    }
  }
  return seats;
}
