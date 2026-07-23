// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../booking/providers/order_draft_provider.dart';
import '../../../booking/providers/order_totals_provider.dart';
import '../../../booking/providers/seat_hold_countdown_provider.dart';
import '../../providers/user_concession_providers.dart';
import '../widgets/combo_order_card.dart';
import '../widgets/product_order_card.dart';
import '../../../../shared/widgets/app_press_scale.dart';
import '../../../../app/app_theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalAmount = totals?.totalAmount ?? draft.total;
    final priceText = NumberFormat('#,###', 'vi')
        .format(totalAmount)
        .replaceAll(',', '.');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0E0E0E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF121212),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section header: Sản phẩm ─────────────────
                  _SectionHeader(label: 'SẢN PHẨM'),
                  const SizedBox(height: 10),
                  products.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppTheme.cgvRed),
                    ),
                    error: (_, __) =>
                        const Text('Không tải được sản phẩm.'),
                    data: (items) => items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Không có sản phẩm.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : Column(
                            children: items
                                .map(
                                  (item) => ProductOrderCard(
                                    product: item,
                                    quantity:
                                        draft.productQuantities[item.id] ?? 0,
                                    onChanged: (quantity) {
                                      final map = {
                                        ...draft.productQuantities,
                                      };
                                      if (quantity == 0)
                                        map.remove(item.id);
                                      else
                                        map[item.id] = quantity;
                                      ref
                                          .read(orderDraftProvider.notifier)
                                          .setDraft(
                                            draft.copyWith(
                                                productQuantities: map),
                                          );
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // ── Section header: Combo ─────────────────────
                  _SectionHeader(label: 'COMBO'),
                  const SizedBox(height: 10),
                  combos.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppTheme.cgvRed),
                    ),
                    error: (_, __) =>
                        const Text('Không tải được combo.'),
                    data: (items) => items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Không có combo.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : Column(
                            children: items
                                .map(
                                  (item) => ComboOrderCard(
                                    combo: item,
                                    quantity:
                                        draft.comboQuantities[item.id] ?? 0,
                                    onChanged: (quantity) {
                                      final map = {
                                        ...draft.comboQuantities,
                                      };
                                      if (quantity == 0)
                                        map.remove(item.id);
                                      else
                                        map[item.id] = quantity;
                                      ref
                                          .read(orderDraftProvider.notifier)
                                          .setDraft(
                                            draft.copyWith(
                                                comboQuantities: map),
                                          );
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Sticky Bottom Bar ─────────────────────────────────
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        '$priceText đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppTheme.cgvRed,
                        ),
                      ),
                    ],
                  ),
                ),
                // Skip button
                TextButton(
                  onPressed: () => context.push('/user/checkout'),
                  child: const Text(
                    'Bỏ qua',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                // Continue button
                AppPressScale(
                  child: FilledButton(
                    onPressed: () => context.push('/user/checkout'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.cgvRed,
                      minimumSize: const Size(110, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'TIẾP TỤC',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
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

/// Section header with CGV red left border.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.cgvRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
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
      data: (duration) => Container(
        color: AppTheme.cgvRed.withValues(alpha: .12),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_outlined, size: 14, color: AppTheme.cgvRed),
            const SizedBox(width: 5),
            Text(
              'Còn: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: AppTheme.cgvRed,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      loading: () => const LinearProgressIndicator(color: AppTheme.cgvRed),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
