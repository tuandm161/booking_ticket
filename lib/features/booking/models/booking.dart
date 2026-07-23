import '../../../core/utils/firestore_converters.dart';
import 'order_item.dart';
import 'seat_item.dart';

enum PaymentMethod { momo, zalopay, vnpay, card }

extension PaymentMethodX on PaymentMethod {
  String get value => name;
  static PaymentMethod fromValue(Object? value) =>
      PaymentMethod.values.where((item) => item.value == value).firstOrNull ??
      PaymentMethod.momo;
}

enum PaymentStatus { paid }

extension PaymentStatusX on PaymentStatus {
  String get value => name;
  static PaymentStatus fromValue(Object? value) =>
      PaymentStatus.values.where((item) => item.value == value).firstOrNull ??
      PaymentStatus.paid;
}

enum BookingStatus { confirmed }

extension BookingStatusX on BookingStatus {
  String get value => name;
  static BookingStatus fromValue(Object? value) =>
      BookingStatus.values.where((item) => item.value == value).firstOrNull ??
      BookingStatus.confirmed;
}

class Booking {
  const Booking({
    this.id = '',
    this.cinemaId = '',
    this.cinemaName = '',
    required this.bookingCode,
    required this.qrData,
    required this.userId,
    required this.userEmail,
    required this.movieId,
    required this.movieTitle,
    required this.moviePosterUrl,
    required this.showtimeId,
    required this.roomId,
    required this.roomName,
    required this.startTime,
    required this.seatItems,
    required this.productItems,
    required this.comboItems,
    this.voucherCode,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.createdAt,
  });

  final String id;
  final String cinemaId;
  final String cinemaName;
  final String bookingCode;
  final String qrData;
  final String userId;
  final String userEmail;
  final String movieId;
  final String movieTitle;
  final String moviePosterUrl;
  final String showtimeId;
  final String roomId;
  final String roomName;
  final DateTime startTime;
  final DateTime createdAt;
  final List<SeatItem> seatItems;
  final List<OrderItem> productItems;
  final List<OrderItem> comboItems;
  final String? voucherCode;
  final int subtotal;
  final int discountAmount;
  final int totalAmount;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final BookingStatus bookingStatus;

  factory Booking.fromMap(String id, Map<String, Object?> m) => Booking(
        id: id,
        cinemaId: m['cinemaId'] as String? ?? '',
        cinemaName: m['cinemaName'] as String? ?? '',
        bookingCode: m['bookingCode'] as String? ?? '',
        qrData: m['qrData'] as String? ?? '',
        userId: m['userId'] as String? ?? '',
        userEmail: m['userEmail'] as String? ?? '',
        movieId: m['movieId'] as String? ?? '',
        movieTitle: m['movieTitle'] as String? ?? '',
        moviePosterUrl: m['moviePosterUrl'] as String? ?? '',
        showtimeId: m['showtimeId'] as String? ?? '',
        roomId: m['roomId'] as String? ?? '',
        roomName: m['roomName'] as String? ?? '',
        startTime: dateFromFirestore(m['startTime']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        seatItems: _seatList(m['seatItems']),
        productItems: _orderList(m['productItems']),
        comboItems: _orderList(m['comboItems']),
        voucherCode: m['voucherCode'] as String?,
        subtotal: (m['subtotal'] as num?)?.toInt() ?? 0,
        discountAmount: (m['discountAmount'] as num?)?.toInt() ?? 0,
        totalAmount: (m['totalAmount'] as num?)?.toInt() ?? 0,
        paymentMethod: PaymentMethodX.fromValue(m['paymentMethod']),
        paymentStatus: PaymentStatusX.fromValue(m['paymentStatus']),
        bookingStatus: BookingStatusX.fromValue(m['bookingStatus']),
        createdAt: dateFromFirestore(m['createdAt']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  static List<SeatItem> _seatList(Object? value) => value is Iterable
      ? value
          .whereType<Map>()
          .map(
            (x) => SeatItem.fromMap(x.map((k, v) => MapEntry(k.toString(), v))),
          )
          .toList()
      : <SeatItem>[];

  static List<OrderItem> _orderList(Object? value) => value is Iterable
      ? value
          .whereType<Map>()
          .map(
            (x) => OrderItem.fromMap(x.map((k, v) => MapEntry(k.toString(), v))),
          )
          .toList()
      : <OrderItem>[];

  Map<String, Object?> toMap() => {
        'cinemaId': cinemaId,
        'cinemaName': cinemaName,
        'bookingCode': bookingCode,
        'qrData': qrData,
        'userId': userId,
        'userEmail': userEmail,
        'movieId': movieId,
        'movieTitle': movieTitle,
        'moviePosterUrl': moviePosterUrl,
        'showtimeId': showtimeId,
        'roomId': roomId,
        'roomName': roomName,
        'startTime': dateToFirestore(startTime),
        'seatItems': seatItems.map((e) => e.toMap()).toList(),
        'productItems': productItems.map((e) => e.toMap()).toList(),
        'comboItems': comboItems.map((e) => e.toMap()).toList(),
        'voucherCode': voucherCode,
        'subtotal': subtotal,
        'discountAmount': discountAmount,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod.value,
        'paymentStatus': paymentStatus.value,
        'bookingStatus': bookingStatus.value,
        'createdAt': dateToFirestore(createdAt),
      };
}
