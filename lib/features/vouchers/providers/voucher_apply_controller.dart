// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../models/voucher.dart';
import '../../booking/providers/seat_hold_countdown_provider.dart';
import 'voucher_providers.dart';

final voucherApplyControllerProvider =
    NotifierProvider<VoucherApplyController, AsyncValue<Voucher?>>(
      VoucherApplyController.new,
    );

class VoucherApplyController extends Notifier<AsyncValue<Voucher?>> {
  @override
  AsyncValue<Voucher?> build() => const AsyncData(null);
  Future<Voucher?> apply(
    String code, {
    required int subtotal,
    DateTime? now,
  }) async {
    state = const AsyncLoading();
    try {
      final voucher = await ref
          .read(voucherRepositoryProvider)
          .findByCode(code);
      if (voucher == null)
        throw const AppException(
          code: 'voucher_not_found',
          message: 'Không tìm thấy mã voucher.',
        );
      calculateDiscount(
        voucher: voucher,
        subtotal: subtotal,
        now: now ?? ref.read(clockServiceProvider).now(),
      );
      state = AsyncData(voucher);
      return voucher;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      return null;
    }
  }

  void setVoucher(Voucher voucher) => state = AsyncData(voucher);
  void clear() => state = const AsyncData(null);
}
