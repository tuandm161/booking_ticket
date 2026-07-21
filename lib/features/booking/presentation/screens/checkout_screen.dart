// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../vouchers/models/voucher.dart';
import '../../../vouchers/providers/voucher_apply_controller.dart';
import '../../../vouchers/providers/voucher_providers.dart';
import '../../../vouchers/presentation/widgets/applied_voucher_card.dart';
import '../../../vouchers/presentation/widgets/voucher_picker_sheet.dart';
import '../../providers/order_draft_provider.dart';
import '../../providers/order_totals_provider.dart';
import '../../providers/seat_hold_countdown_provider.dart';
import '../widgets/order_summary.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận đơn hàng'),
        bottom: countdown == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: countdown.when(
                  data: (d) => Text(
                    'Giữ ghế còn ${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}',
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OrderSummary(totals: totals),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Mã voucher'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
                onPressed: () async {
                  final voucher = await ref
                      .read(voucherApplyControllerProvider.notifier)
                      .apply(codeController.text, subtotal: totals.subtotal);
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
                child: const Text('Áp dụng'),
              ),
            ],
          ),
          if (voucherState.hasError)
            Text(
              voucherState.error.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (draft.appliedVoucher != null)
            AppliedVoucherCard(
              voucher: draft.appliedVoucher!,
              onRemove: () {
                ref.read(voucherApplyControllerProvider.notifier).clear();
                ref
                    .read(orderDraftProvider.notifier)
                    .setDraft(draft.clearVoucher());
              },
            ),
          OutlinedButton.icon(
            onPressed: () {
              final available = ref
                  .read(vouchersProvider)
                  .maybeWhen(
                    data: (items) => items.where((v) {
                      final now = ref.read(clockServiceProvider).now();
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
                builder: (_) => VoucherPickerSheet(
                  vouchers: available,
                  onSelected: (voucher) {
                    ref
                        .read(voucherApplyControllerProvider.notifier)
                        .setVoucher(voucher);
                    ref
                        .read(orderDraftProvider.notifier)
                        .setDraft(draft.copyWith(appliedVoucher: voucher));
                  },
                ),
              );
            },
            icon: const Icon(Icons.local_offer_outlined),
            label: const Text('Voucher khả dụng'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push('/user/payment-method'),
            child: const Text('Chọn phương thức thanh toán'),
          ),
        ],
      ),
    );
  }
}
