import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/voucher_repository.dart';
import '../models/voucher.dart';

final voucherFormControllerProvider =
    NotifierProvider<VoucherFormController, VoucherDraft>(
      VoucherFormController.new,
    );

class VoucherFormController extends Notifier<VoucherDraft> {
  @override
  VoucherDraft build() => VoucherDraft(
    code: '',
    description: '',
    discountType: DiscountType.percentage,
    discountValue: 10,
    minOrderValue: 0,
    maxDiscount: 0,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 30)),
    usageLimit: 100,
  );
}
