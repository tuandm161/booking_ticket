// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../vouchers/models/voucher.dart';
import '../../../vouchers/providers/voucher_apply_controller.dart';
import '../../../vouchers/providers/voucher_providers.dart';
import '../../../vouchers/presentation/widgets/applied_voucher_card.dart';
import '../../../vouchers/presentation/widgets/voucher_picker_sheet.dart';
import '../../providers/order_draft_provider.dart';
import '../../providers/order_totals_provider.dart';
import '../../providers/seat_hold_countdown_provider.dart';
import '../widgets/order_summary.dart';
import '../../../../shared/widgets/app_press_scale.dart';
import '../../../../app/app_theme.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final codeController = TextEditingController();
  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(orderDraftProvider);
    final totals = ref.watch(orderTotalsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (draft == null || totals == null)
      return const Scaffold(body: Center(child: Text('Chưa có order draft.')));

    final countdown = draft.holdExpiresAt == null
        ? null
        : ref.watch(seatHoldCountdownProvider(draft.holdExpiresAt!));
    final voucherState = ref.watch(voucherApplyControllerProvider);

    if (draft.appliedVoucher != null) {
      try {
        calculateDiscount(
          voucher: draft.appliedVoucher!,
          subtotal: totals.subtotal,
          now: ref.read(clockServiceProvider).now(),
        );
      } catch (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final current = ref.read(orderDraftProvider);
          if (current?.appliedVoucher?.id == draft.appliedVoucher?.id) {
            ref
                .read(orderDraftProvider.notifier)
                .setDraft(draft.clearVoucher());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Voucher đã tự gỡ vì đơn hàng không còn đủ điều kiện.',
                ),
              ),
            );
          }
        });
      }
    }

    final priceText = NumberFormat('#,###', 'vi')
        .format(totals.totalAmount)
        .replaceAll(',', '.');

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0E0E0E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF121212),
        title: const Text('Xác nhận đơn hàng'),
        bottom: countdown == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(32),
                child: countdown.when(
                  data: (d) => Container(
                    color: AppTheme.cgvRed.withValues(alpha: .1),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 14, color: AppTheme.cgvRed),
                        const SizedBox(width: 5),
                        Text(
                          'Còn: ${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: AppTheme.cgvRed,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () =>
                      const LinearProgressIndicator(color: AppTheme.cgvRed),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Order Summary card ────────────────────────
                OrderSummary(totals: totals),
                const SizedBox(height: 16),

                // ── Voucher section ───────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252525) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF3A3A3A)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cgvRed.withValues(alpha: .06),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_offer_outlined,
                              color: AppTheme.cgvRed,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'VOUCHER / KHUYẾN MÃI',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final available = ref
                                    .read(vouchersProvider)
                                    .maybeWhen(
                                      data: (items) => items.where((v) {
                                        final now =
                                            ref.read(clockServiceProvider).now();
                                        return v.isActive &&
                                            !now.isBefore(v.startDate) &&
                                            !now.isAfter(v.endDate) &&
                                            v.usedCount < v.usageLimit &&
                                            totals.subtotal >= v.minOrderValue;
                                      }).toList(),
                                      orElse: () => const <Voucher>[],
                                    );
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => VoucherPickerSheet(
                                    vouchers: available,
                                    onSelected: (voucher) {
                                      ref
                                          .read(voucherApplyControllerProvider
                                              .notifier)
                                          .setVoucher(voucher);
                                      ref
                                          .read(orderDraftProvider.notifier)
                                          .setDraft(draft.copyWith(
                                              appliedVoucher: voucher));
                                    },
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.cgvRed,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Chọn voucher',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Input area
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: codeController,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: const InputDecoration(
                                      hintText: 'Nhập mã voucher',
                                      prefixIcon: Icon(
                                        Icons.discount_outlined,
                                        size: 18,
                                        color: AppTheme.cgvRed,
                                      ),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 46,
                                  child: AppPressScale(
                                    child: FilledButton(
                                      onPressed: () async {
                                        final voucher = await ref
                                            .read(voucherApplyControllerProvider
                                                .notifier)
                                            .apply(codeController.text,
                                                subtotal: totals.subtotal);
                                        if (voucher != null)
                                          ref
                                              .read(orderDraftProvider.notifier)
                                              .setDraft(
                                                draft.copyWith(
                                                  appliedVoucher: voucher,
                                                  discount: totals.discountAmount,
                                                  total: totals.totalAmount,
                                                ),
                                              );
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppTheme.cgvRed,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        minimumSize: const Size(80, 46),
                                      ),
                                      child: const Text('Áp dụng'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (voucherState.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  voucherState.error.toString(),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (draft.appliedVoucher != null) ...[
                              const SizedBox(height: 10),
                              AppliedVoucherCard(
                                voucher: draft.appliedVoucher!,
                                onRemove: () {
                                  ref
                                      .read(voucherApplyControllerProvider
                                          .notifier)
                                      .clear();
                                  ref
                                      .read(orderDraftProvider.notifier)
                                      .setDraft(draft.clearVoucher());
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Sticky Bottom ─────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .12),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng thanh toán',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '$priceText đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppTheme.cgvRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: AppPressScale(
                    child: FilledButton(
                      onPressed: () => context.push('/user/payment-method'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.cgvRed,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'CHỌN PHƯƠNG THỨC THANH TOÁN',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
