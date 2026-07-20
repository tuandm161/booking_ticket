// ignore_for_file: curly_braces_in_flow_control_structures, avoid_types_as_parameter_names
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/id_generator.dart';
import '../../concessions/models/combo.dart';
import '../../concessions/models/product.dart';
import '../../movies/models/movie.dart';
import '../../rooms/models/cinema_room.dart';
import '../../rooms/models/cinema_seat.dart';
import '../../showtimes/models/showtime.dart';
import '../../vouchers/models/voucher.dart';
import '../models/booking.dart';
import '../models/checkout_result.dart';
import '../models/order_draft.dart';
import '../models/order_item.dart';
import '../models/seat_item.dart';

void validateCheckoutDraft(OrderDraft draft, DateTime now) {
  if (draft.reservationId == null || draft.holdExpiresAt == null)
    throw const AppException(
      code: 'hold_missing',
      message: 'Không tìm thấy lượt giữ ghế.',
    );
  if (!draft.holdExpiresAt!.isAfter(now))
    throw const AppException(
      code: 'hold_expired',
      message: 'Thời gian giữ ghế đã hết.',
    );
  if (draft.selectedSeats.isEmpty)
    throw const AppException(code: 'no_seats', message: 'Chưa chọn ghế.');
}

class CheckoutRepository {
  const CheckoutRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Future<CheckoutResult> checkout({
    required OrderDraft draft,
    required String userId,
    required String userEmail,
    required PaymentMethod paymentMethod,
    required DateTime now,
  }) async {
    validateCheckoutDraft(draft, now);
    final reservationId = draft.reservationId!;
    final showtimeRef = _firestore
        .collection(FirestorePaths.showtimes)
        .doc(draft.showtime.id);
    final roomRef = _firestore
        .collection(FirestorePaths.rooms)
        .doc(draft.room.id);
    final movieRef = _firestore
        .collection(FirestorePaths.movies)
        .doc(draft.movie.id);
    final voucherRef = draft.appliedVoucher == null
        ? null
        : _firestore
              .collection(FirestorePaths.vouchers)
              .doc(draft.appliedVoucher!.id);
    final productRefs = draft.productQuantities.entries
        .where((e) => e.value > 0)
        .map(
          (e) => MapEntry(
            e.key,
            _firestore.collection(FirestorePaths.products).doc(e.key),
          ),
        )
        .toList();
    final comboRefs = draft.comboQuantities.entries
        .where((e) => e.value > 0)
        .map(
          (e) => MapEntry(
            e.key,
            _firestore.collection(FirestorePaths.combos).doc(e.key),
          ),
        )
        .toList();
    final bookingRef = _firestore.collection(FirestorePaths.bookings).doc();
    final notificationRef = _firestore
        .collection(FirestorePaths.notifications)
        .doc();
    final bookingCode = 'MV-${generateId(6)}';
    return _firestore.runTransaction((transaction) async {
      final showtimeDoc = await transaction.get(showtimeRef);
      final roomDoc = await transaction.get(roomRef);
      final movieDoc = await transaction.get(movieRef);
      final voucherDoc = voucherRef == null
          ? null
          : await transaction.get(voucherRef);
      final productDocs = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final entry in productRefs)
        productDocs[entry.key] = await transaction.get(entry.value);
      final comboDocs = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final entry in comboRefs)
        comboDocs[entry.key] = await transaction.get(entry.value);
      if (!showtimeDoc.exists ||
          showtimeDoc.data() == null ||
          !roomDoc.exists ||
          roomDoc.data() == null ||
          !movieDoc.exists ||
          movieDoc.data() == null)
        throw const AppException(
          code: 'checkout_not_found',
          message: 'Dữ liệu suất chiếu không còn tồn tại.',
        );
      final showtime = Showtime.fromMap(
        showtimeDoc.id,
        Map<String, Object?>.from(showtimeDoc.data()!),
      );
      final room = CinemaRoom.fromMap(
        roomDoc.id,
        Map<String, Object?>.from(roomDoc.data()!),
      );
      final movie = Movie.fromMap(
        movieDoc.id,
        Map<String, Object?>.from(movieDoc.data()!),
      );
      if (!showtime.isActive || !showtime.startTime.isAfter(now))
        throw const AppException(
          code: 'showtime_unavailable',
          message: 'Suất chiếu không còn khả dụng.',
        );
      if (!movie.isActive)
        throw const AppException(
          code: 'movie_unavailable',
          message: 'Phim không còn hoạt động.',
        );
      final selectedCodes = draft.selectedSeats
          .map((seat) => seat.code)
          .toList();
      final seatsByCode = {for (final seat in room.seats) seat.code: seat};
      if (selectedCodes.isEmpty ||
          selectedCodes.toSet().length != selectedCodes.length)
        throw const AppException(
          code: 'invalid_seat',
          message: 'Danh sách ghế không hợp lệ.',
        );
      final heldSeats = <String, HeldSeat>{...showtime.heldSeats};
      for (final code in selectedCodes) {
        final seat = seatsByCode[code];
        final hold = heldSeats[code];
        if (seat == null)
          throw const AppException(
            code: 'invalid_seat',
            message: 'Ghế không thuộc sơ đồ phòng.',
          );
        if (showtime.bookedSeatCodes.contains(code))
          throw const AppException(
            code: 'seat_unavailable',
            message: 'Ghế đã được đặt.',
          );
        if (hold == null ||
            hold.userId != userId ||
            hold.reservationId != reservationId ||
            !hold.expiresAt.isAfter(now))
          throw const AppException(
            code: 'hold_expired',
            message: 'Một hoặc nhiều ghế không còn được giữ.',
          );
      }
      final productItems = <OrderItem>[];
      for (final entry in productRefs) {
        final quantity = draft.productQuantities[entry.key] ?? 0;
        if (quantity < 1 ||
            quantity > 10 ||
            !productDocs[entry.key]!.exists ||
            productDocs[entry.key]!.data() == null)
          throw const AppException(
            code: 'product_unavailable',
            message: 'Sản phẩm không còn khả dụng.',
          );
        final product = Product.fromMap(
          entry.key,
          Map<String, Object?>.from(productDocs[entry.key]!.data()!),
        );
        if (!product.isAvailable)
          throw const AppException(
            code: 'product_unavailable',
            message: 'Sản phẩm không còn khả dụng.',
          );
        productItems.add(
          OrderItem(
            productId: product.id,
            name: product.name,
            quantity: quantity,
            unitPrice: product.price,
            totalPrice: product.price * quantity,
          ),
        );
      }
      final comboItems = <OrderItem>[];
      for (final entry in comboRefs) {
        final quantity = draft.comboQuantities[entry.key] ?? 0;
        if (quantity < 1 ||
            quantity > 10 ||
            !comboDocs[entry.key]!.exists ||
            comboDocs[entry.key]!.data() == null)
          throw const AppException(
            code: 'combo_unavailable',
            message: 'Combo không còn khả dụng.',
          );
        final combo = Combo.fromMap(
          entry.key,
          Map<String, Object?>.from(comboDocs[entry.key]!.data()!),
        );
        if (!combo.isAvailable)
          throw const AppException(
            code: 'combo_unavailable',
            message: 'Combo không còn khả dụng.',
          );
        comboItems.add(
          OrderItem(
            productId: combo.id,
            name: combo.name,
            quantity: quantity,
            unitPrice: combo.price,
            totalPrice: combo.price * quantity,
          ),
        );
      }
      Voucher? voucher;
      if (voucherRef != null) {
        if (voucherDoc == null ||
            !voucherDoc.exists ||
            voucherDoc.data() == null)
          throw const AppException(
            code: 'voucher_invalid',
            message: 'Voucher không còn tồn tại.',
          );
        voucher = Voucher.fromMap(
          voucherDoc.id,
          Map<String, Object?>.from(voucherDoc.data()!),
        );
      }
      final seatItems = selectedCodes.map((code) {
        final seat = seatsByCode[code]!;
        return SeatItem(
          code: code,
          type: seat.type,
          capacity: seat.capacity,
          unitPrice: seatPriceForCheckout(seat.type, showtime.basePrice),
        );
      }).toList();
      final seatSubtotal = seatItems.fold<int>(
        0,
        (sum, item) => sum + item.unitPrice,
      );
      final productSubtotal = productItems.fold<int>(
        0,
        (sum, item) => sum + item.totalPrice,
      );
      final comboSubtotal = comboItems.fold<int>(
        0,
        (sum, item) => sum + item.totalPrice,
      );
      final subtotal = seatSubtotal + productSubtotal + comboSubtotal;
      final discountAmount = voucher == null
          ? 0
          : calculateDiscount(voucher: voucher, subtotal: subtotal, now: now);
      final total = (subtotal - discountAmount).clamp(0, subtotal);
      final newHeld = <String, HeldSeat>{...heldSeats}
        ..removeWhere(
          (code, hold) =>
              selectedCodes.contains(code) || !hold.expiresAt.isAfter(now),
        );
      final booked = {...showtime.bookedSeatCodes, ...selectedCodes}.toList();
      final booking = Booking(
        id: bookingRef.id,
        bookingCode: bookingCode,
        qrData: 'booking:$bookingCode',
        userId: userId,
        userEmail: userEmail,
        movieId: movie.id,
        movieTitle: movie.title,
        moviePosterUrl: movie.posterUrl,
        showtimeId: showtime.id,
        roomId: room.id,
        roomName: room.name,
        startTime: showtime.startTime,
        seatItems: seatItems,
        productItems: productItems,
        comboItems: comboItems,
        voucherCode: voucher?.code,
        subtotal: subtotal,
        discountAmount: discountAmount,
        totalAmount: total,
        paymentMethod: paymentMethod,
        paymentStatus: PaymentStatus.paid,
        bookingStatus: BookingStatus.confirmed,
        createdAt: now,
      );
      transaction.update(showtimeRef, {
        'heldSeats': newHeld.map((key, value) => MapEntry(key, value.toMap())),
        'bookedSeatCodes': booked,
        'updatedAt': Timestamp.fromDate(now),
      });
      transaction.update(movieRef, {
        'bookingCount': FieldValue.increment(
          seatItems.fold<int>(0, (sum, item) => sum + item.capacity),
        ),
        'updatedAt': Timestamp.fromDate(now),
      });
      if (voucherRef != null)
        transaction.update(voucherRef, {
          'usedCount': FieldValue.increment(1),
          'updatedAt': Timestamp.fromDate(now),
        });
      transaction.set(bookingRef, booking.toMap());
      transaction.set(notificationRef, {
        'userId': userId,
        'title': 'Đặt vé thành công',
        'body': 'Mã vé $bookingCode',
        'bookingId': bookingRef.id,
        'isRead': false,
        'createdAt': Timestamp.fromDate(now),
      });
      return CheckoutResult(
        bookingId: bookingRef.id,
        bookingCode: bookingCode,
        totalAmount: total,
      );
    });
  }
}

int seatPriceForCheckout(SeatType type, int basePrice) => switch (type) {
  SeatType.standard => basePrice,
  SeatType.vip => basePrice + 20000,
  SeatType.couple => basePrice * 2 + 20000,
};
