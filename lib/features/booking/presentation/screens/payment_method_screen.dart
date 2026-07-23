import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/app_press_scale.dart';
import '../../models/booking.dart';
import '../widgets/payment_method_tile.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});
  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentMethod selected = PaymentMethod.momo;
  bool simulateFailure = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0E0E0E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF121212),
        title: const Text('Phương thức thanh toán'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Section header ─────────────────────────────
                _SectionHeader(
                  icon: Icons.payment_rounded,
                  label: 'CHỌN PHƯƠNG THỨC THANH TOÁN',
                ),
                const SizedBox(height: 12),
                // ── Payment options ────────────────────────────
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
                      for (int i = 0; i < PaymentMethod.values.length; i++) ...[
                        PaymentMethodTile(
                          method: PaymentMethod.values[i],
                          selected: selected == PaymentMethod.values[i],
                          onTap: () => setState(
                              () => selected = PaymentMethod.values[i]),
                        ),
                        if (i < PaymentMethod.values.length - 1)
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: isDark
                                ? const Color(0xFF3A3A3A)
                                : const Color(0xFFE0E0E0),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // ── Debug toggle ───────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252525) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF3A3A3A)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Mô phỏng thất bại (debug)',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: simulateFailure,
                    onChanged: (value) =>
                        setState(() => simulateFailure = value),
                    activeThumbColor: AppTheme.cgvRed,
                    activeTrackColor: AppTheme.cgvRed.withValues(alpha: .4),
                  ),
                ),
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
            child: AppPressScale(
              child: FilledButton(
                onPressed: () {
                  final suffix = simulateFailure ? '?fail=true' : '';
                  context.push(
                    selected == PaymentMethod.card
                        ? '/user/card-payment$suffix'
                        : '/user/payment-processing/${selected.value}$suffix',
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.cgvRed,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'TÔI ĐỒNG Ý VÀ TIẾP TỤC',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.cgvRed, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 0.5,
            color: AppTheme.cgvRed,
          ),
        ),
      ],
    );
  }
}
