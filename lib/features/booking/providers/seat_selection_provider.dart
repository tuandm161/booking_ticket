// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/pricing_constants.dart';
import '../../rooms/models/cinema_seat.dart';

const maxSeatUnitsPerBooking = PricingConstants.maxSeatUnitsPerBooking;
final seatSelectionProvider =
    NotifierProvider<SeatSelectionController, Set<String>>(
      SeatSelectionController.new,
    );

class SeatSelectionController extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};
  String? toggle(CinemaSeat seat) {
    final next = {...state};
    if (next.contains(seat.code)) {
      next.remove(seat.code);
      state = next;
      return null;
    }
    if (next.length >= maxSeatUnitsPerBooking)
      return 'Bạn chỉ có thể chọn tối đa $maxSeatUnitsPerBooking ghế.';
    next.add(seat.code);
    state = next;
    return null;
  }

  void clear() => state = <String>{};
  void setCodes(Iterable<String> codes) => state = codes.toSet();
}
