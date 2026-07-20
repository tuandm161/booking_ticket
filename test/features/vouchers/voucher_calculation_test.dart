import 'package:booking_cinema/features/vouchers/models/voucher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 1, 10);
  Voucher voucher({
    DiscountType type = DiscountType.percentage,
    int value = 20,
    int max = 50000,
    int used = 0,
    bool active = true,
  }) => Voucher(
    id: 'v',
    code: 'MOVIE20',
    description: '',
    discountType: type,
    discountValue: value,
    minOrderValue: 100000,
    maxDiscount: max,
    startDate: DateTime.utc(2026, 1, 1),
    endDate: DateTime.utc(2026, 1, 31),
    usageLimit: 10,
    usedCount: used,
    isActive: active,
  );

  test('calculates percentage and applies max discount', () {
    expect(
      calculateDiscount(voucher: voucher(), subtotal: 200000, now: now),
      40000,
    );
    expect(
      calculateDiscount(voucher: voucher(), subtotal: 500000, now: now),
      50000,
    );
  });

  test('calculates fixed amount and rejects invalid voucher', () {
    expect(
      calculateDiscount(
        voucher: voucher(type: DiscountType.fixedAmount, value: 120000),
        subtotal: 100000,
        now: now,
      ),
      100000,
    );
    expect(
      () => calculateDiscount(
        voucher: voucher(active: false),
        subtotal: 200000,
        now: now,
      ),
      throwsA(isA<Exception>()),
    );
    expect(
      () => calculateDiscount(
        voucher: voucher(used: 10),
        subtotal: 200000,
        now: now,
      ),
      throwsA(isA<Exception>()),
    );
  });
}
