import 'package:booking_cinema/features/vouchers/data/voucher_repository.dart';
import 'package:booking_cinema/features/vouchers/models/voucher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('voucher draft supports percentage constraints', () {
    final draft = VoucherDraft(
      code: 'MOVIE20',
      description: '',
      discountType: DiscountType.percentage,
      discountValue: 20,
      minOrderValue: 100000,
      maxDiscount: 50000,
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 2, 1),
      usageLimit: 100,
    );
    expect(draft.code, 'MOVIE20');
    expect(draft.discountValue, 20);
    expect(draft.usageLimit, 100);
  });
}
