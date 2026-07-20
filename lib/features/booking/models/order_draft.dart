import '../../movies/models/movie.dart';
import '../../rooms/models/cinema_room.dart';
import '../../rooms/models/cinema_seat.dart';
import '../../showtimes/models/showtime.dart';
import '../../vouchers/models/voucher.dart';

class OrderDraft {
  const OrderDraft({
    required this.movie,
    required this.showtime,
    required this.room,
    this.selectedSeats = const [],
    this.reservationId,
    this.holdExpiresAt,
    this.productQuantities = const {},
    this.comboQuantities = const {},
    this.appliedVoucher,
    this.seatSubtotal = 0,
    this.concessionSubtotal = 0,
    this.discount = 0,
    this.total = 0,
  });
  final Movie movie;
  final Showtime showtime;
  final CinemaRoom room;
  final List<CinemaSeat> selectedSeats;
  final String? reservationId;
  final DateTime? holdExpiresAt;
  final Map<String, int> productQuantities, comboQuantities;
  final Voucher? appliedVoucher;
  final int seatSubtotal, concessionSubtotal, discount, total;
  OrderDraft copyWith({
    Movie? movie,
    Showtime? showtime,
    CinemaRoom? room,
    List<CinemaSeat>? selectedSeats,
    String? reservationId,
    DateTime? holdExpiresAt,
    Map<String, int>? productQuantities,
    Map<String, int>? comboQuantities,
    Voucher? appliedVoucher,
    int? seatSubtotal,
    int? concessionSubtotal,
    int? discount,
    int? total,
  }) => OrderDraft(
    movie: movie ?? this.movie,
    showtime: showtime ?? this.showtime,
    room: room ?? this.room,
    selectedSeats: selectedSeats ?? this.selectedSeats,
    reservationId: reservationId ?? this.reservationId,
    holdExpiresAt: holdExpiresAt ?? this.holdExpiresAt,
    productQuantities: productQuantities ?? this.productQuantities,
    comboQuantities: comboQuantities ?? this.comboQuantities,
    appliedVoucher: appliedVoucher ?? this.appliedVoucher,
    seatSubtotal: seatSubtotal ?? this.seatSubtotal,
    concessionSubtotal: concessionSubtotal ?? this.concessionSubtotal,
    discount: discount ?? this.discount,
    total: total ?? this.total,
  );
  OrderDraft clearVoucher() => OrderDraft(
    movie: movie,
    showtime: showtime,
    room: room,
    selectedSeats: selectedSeats,
    reservationId: reservationId,
    holdExpiresAt: holdExpiresAt,
    productQuantities: productQuantities,
    comboQuantities: comboQuantities,
    appliedVoucher: null,
    seatSubtotal: seatSubtotal,
    concessionSubtotal: concessionSubtotal,
    discount: 0,
    total: total,
  );
}
