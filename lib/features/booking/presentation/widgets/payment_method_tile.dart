import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/app_press_scale.dart';
import '../../models/booking.dart';

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  static String _label(PaymentMethod method) => switch (method) {
        PaymentMethod.momo => 'MoMo',
        PaymentMethod.zalopay => 'ZaloPay',
        PaymentMethod.vnpay => 'VNPay',
        PaymentMethod.card => 'Thẻ ngân hàng',
      };

  static IconData _icon(PaymentMethod method) => switch (method) {
        PaymentMethod.momo => Icons.account_balance_wallet_rounded,
        PaymentMethod.zalopay => Icons.wallet_rounded,
        PaymentMethod.vnpay => Icons.payments_rounded,
        PaymentMethod.card => Icons.credit_card_rounded,
      };

  static Color _iconColor(PaymentMethod method) => switch (method) {
        PaymentMethod.momo => const Color(0xFFD72E8B),
        PaymentMethod.zalopay => const Color(0xFF006AF5),
        PaymentMethod.vnpay => const Color(0xFF006AF5),
        PaymentMethod.card => const Color(0xFF4CAF50),
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppPressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? AppTheme.cgvRed.withValues(alpha: isDark ? 0.15 : 0.08)
              : Colors.transparent,
          border: Border.all(
            color: selected ? AppTheme.cgvRed : Colors.transparent,
            width: selected ? 1.5 : 0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.cgvRed.withValues(alpha: 0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Payment icon in coloured pill
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconColor(method).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _icon(method),
                color: _iconColor(method),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Label
            Expanded(
              child: Text(
                _label(method),
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 15,
                  color: selected
                      ? (isDark ? Colors.white : AppTheme.cgvRed)
                      : (isDark ? Colors.white : const Color(0xFF121212)),
                ),
              ),
            ),
            // Radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppTheme.cgvRed
                      : (isDark
                          ? const Color(0xFF5A5A5A)
                          : const Color(0xFFBDBDBD)),
                  width: 2,
                ),
                color: selected ? AppTheme.cgvRed : Colors.transparent,
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
