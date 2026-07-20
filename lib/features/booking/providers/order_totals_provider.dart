import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../concessions/models/combo.dart';
import '../../concessions/models/product.dart';
import '../../concessions/providers/user_concession_providers.dart';
import '../../rooms/models/cinema_seat.dart';
import '../../vouchers/models/voucher.dart';
import '../models/seat_hold.dart';
import 'order_draft_provider.dart';
import 'seat_hold_countdown_provider.dart';

class OrderTotals {
  const OrderTotals({
    required this.seatSubtotal,
    required this.productSubtotal,
    required this.comboSubtotal,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
  });
  final int seatSubtotal,
      productSubtotal,
      comboSubtotal,
      subtotal,
      discountAmount,
      totalAmount;
}

OrderTotals calculateOrderTotals({
  required List<CinemaSeat> seats,
  required int basePrice,
  required List<Product> products,
  required Map<String, int> productQuantities,
  required List<Combo> combos,
  required Map<String, int> comboQuantities,
  Voucher? voucher,
  required DateTime now,
}) {
  final seatSubtotal = seats.fold<int>(
    0,
    (sum, seat) => sum + seatPrice(seat.type, basePrice),
  );
  final productSubtotal = products.fold<int>(
    0,
    (sum, item) => sum + item.price * (productQuantities[item.id] ?? 0),
  );
  final comboSubtotal = combos.fold<int>(
    0,
    (sum, item) => sum + item.price * (comboQuantities[item.id] ?? 0),
  );
  final subtotal = seatSubtotal + productSubtotal + comboSubtotal;
  var discountAmount = 0;
  if (voucher != null) {
    try {
      discountAmount = calculateDiscount(
        voucher: voucher,
        subtotal: subtotal,
        now: now,
      );
    } catch (_) {
      discountAmount = 0;
    }
  }
  return OrderTotals(
    seatSubtotal: seatSubtotal,
    productSubtotal: productSubtotal,
    comboSubtotal: comboSubtotal,
    subtotal: subtotal,
    discountAmount: discountAmount,
    totalAmount: (subtotal - discountAmount).clamp(0, subtotal),
  );
}

final orderTotalsProvider = Provider<OrderTotals?>((ref) {
  final draft = ref.watch(orderDraftProvider);
  if (draft == null) return null;
  final products = ref
      .watch(userProductsProvider)
      .maybeWhen(data: (items) => items, orElse: () => const <Product>[]);
  final combos = ref
      .watch(userCombosProvider)
      .maybeWhen(data: (items) => items, orElse: () => const <Combo>[]);
  return calculateOrderTotals(
    seats: draft.selectedSeats,
    basePrice: draft.showtime.basePrice,
    products: products,
    productQuantities: draft.productQuantities,
    combos: combos,
    comboQuantities: draft.comboQuantities,
    voucher: draft.appliedVoucher,
    now: ref.watch(clockServiceProvider).now(),
  );
});
