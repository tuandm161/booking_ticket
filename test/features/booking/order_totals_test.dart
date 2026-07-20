import 'package:flutter_test/flutter_test.dart';
import 'package:booking_cinema/features/booking/providers/order_totals_provider.dart';
import 'package:booking_cinema/features/concessions/models/combo.dart';
import 'package:booking_cinema/features/concessions/models/product.dart';
import 'package:booking_cinema/features/rooms/models/cinema_seat.dart';
import 'package:booking_cinema/features/vouchers/models/voucher.dart';

void main() {
  final now = DateTime(2026, 1, 2);
  final products = [
    Product(
      id: 'p',
      name: 'Bắp',
      category: ProductCategory.popcorn,
      description: '',
      imageUrl: '',
      price: 50000,
      isAvailable: true,
    ),
  ];
  final combos = [
    Combo(
      id: 'c',
      name: 'Combo',
      description: '',
      imageUrl: '',
      price: 100000,
      items: const [],
      isAvailable: true,
    ),
  ];
  final seats = [
    const CinemaSeat(
      code: 'A1',
      row: 'A',
      number: 1,
      type: SeatType.standard,
      capacity: 1,
    ),
    const CinemaSeat(
      code: 'H1',
      row: 'H',
      number: 1,
      type: SeatType.couple,
      capacity: 2,
    ),
  ];
  test('totals include seat, product, combo and voucher discount', () {
    final voucher = Voucher(
      code: 'SAVE',
      description: '',
      discountType: DiscountType.percentage,
      discountValue: 10,
      minOrderValue: 1,
      maxDiscount: 0,
      startDate: now.subtract(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 1)),
      usageLimit: 10,
      usedCount: 0,
      isActive: true,
    );
    final totals = calculateOrderTotals(
      seats: seats,
      basePrice: 80000,
      products: products,
      productQuantities: const {'p': 2},
      combos: combos,
      comboQuantities: const {'c': 1},
      voucher: voucher,
      now: now,
    );
    expect(totals.seatSubtotal, 260000);
    expect(totals.productSubtotal, 100000);
    expect(totals.comboSubtotal, 100000);
    expect(totals.subtotal, 460000);
    expect(totals.discountAmount, 46000);
    expect(totals.totalAmount, 414000);
  });
  test('invalid voucher is revalidated as zero discount', () {
    final voucher = Voucher(
      code: 'MIN',
      description: '',
      discountType: DiscountType.fixedAmount,
      discountValue: 100000,
      minOrderValue: 999999,
      maxDiscount: 0,
      startDate: now.subtract(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 1)),
      usageLimit: 10,
      usedCount: 0,
      isActive: true,
    );
    expect(
      calculateOrderTotals(
        seats: seats,
        basePrice: 80000,
        products: const [],
        productQuantities: const {},
        combos: const [],
        comboQuantities: const {},
        voucher: voucher,
        now: now,
      ).discountAmount,
      0,
    );
  });
}
