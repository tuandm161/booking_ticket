import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/app_theme.dart';
import '../../providers/order_totals_provider.dart';

/// CGV-style order summary with ticket info + price breakdown.
class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key, required this.totals});
  final OrderTotals totals;

  String _fmt(int amount) =>
      NumberFormat('#,###', 'vi').format(amount).replaceAll(',', '.');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.cgvRed.withValues(alpha: .08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.cgvRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'CHI TIẾT ĐƠN HÀNG',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Price lines ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (totals.seatSubtotal > 0)
                  _PriceLine(
                    label: 'Vé',
                    amount: '${_fmt(totals.seatSubtotal)} đ',
                  ),
                if (totals.productSubtotal > 0)
                  _PriceLine(
                    label: 'Sản phẩm',
                    amount: '${_fmt(totals.productSubtotal)} đ',
                  ),
                if (totals.comboSubtotal > 0)
                  _PriceLine(
                    label: 'Combo',
                    amount: '${_fmt(totals.comboSubtotal)} đ',
                  ),
                if (totals.discountAmount > 0)
                  _PriceLine(
                    label: 'Giảm giá',
                    amount: '-${_fmt(totals.discountAmount)} đ',
                    isDiscount: true,
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TỔNG THANH TOÁN',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${_fmt(totals.totalAmount)} đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppTheme.cgvRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.label,
    required this.amount,
    this.isDiscount = false,
  });
  final String label;
  final String amount;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDiscount ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
