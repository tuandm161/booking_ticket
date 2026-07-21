// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../booking/providers/order_draft_provider.dart';
import '../../../booking/providers/order_totals_provider.dart';
import '../../../booking/providers/seat_hold_countdown_provider.dart';
import '../../providers/user_concession_providers.dart';
import '../widgets/combo_order_card.dart';
import '../widgets/product_order_card.dart';

class UserConcessionScreen extends ConsumerWidget {
  const UserConcessionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(orderDraftProvider);
    if (draft == null)
      return const Scaffold(
        body: Center(child: Text('Chưa có order draft. Hãy chọn ghế trước.')),
      );
    final products = ref.watch(userProductsProvider);
    final combos = ref.watch(userCombosProvider);
    final totals = ref.watch(orderTotalsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bắp nước & Combo'),
        bottom: draft.holdExpiresAt == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(32),
                child: _HoldCountdownLabel(expiresAt: draft.holdExpiresAt!),
              ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    'Sản phẩm',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  products.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Không tải được sản phẩm.'),
                    data: (items) => Column(
                      children: items
                          .map(
                            (item) => ProductOrderCard(
                              product: item,
                              quantity: draft.productQuantities[item.id] ?? 0,
                              onChanged: (quantity) {
                                final map = {...draft.productQuantities};
                                if (quantity == 0)
                                  map.remove(item.id);
                                else
                                  map[item.id] = quantity;
                                ref
                                    .read(orderDraftProvider.notifier)
                                    .setDraft(
                                      draft.copyWith(productQuantities: map),
                                    );
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Combo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  combos.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Không tải được combo.'),
                    data: (items) => Column(
                      children: items
                          .map(
                            (item) => ComboOrderCard(
                              combo: item,
                              quantity: draft.comboQuantities[item.id] ?? 0,
                              onChanged: (quantity) {
                                final map = {...draft.comboQuantities};
                                if (quantity == 0)
                                  map.remove(item.id);
                                else
                                  map[item.id] = quantity;
                                ref
                                    .read(orderDraftProvider.notifier)
                                    .setDraft(
                                      draft.copyWith(comboQuantities: map),
                                    );
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tạm tính: ${totals?.totalAmount ?? draft.total} đ',
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/user/checkout'),
                  child: const Text('Bỏ qua'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
                  onPressed: () => context.push('/user/checkout'),
                  child: const Text('Tiếp tục'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rebuilds only the timer label instead of the complete concessions screen.
class _HoldCountdownLabel extends ConsumerWidget {
  const _HoldCountdownLabel({required this.expiresAt});
  final DateTime expiresAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = ref.watch(seatHoldCountdownProvider(expiresAt));
    return countdown.when(
      data: (duration) => Text(
        'Thời gian giữ ghế: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
        textAlign: TextAlign.center,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
