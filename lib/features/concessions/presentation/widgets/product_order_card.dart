import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/app_press_scale.dart';
import '../../models/product.dart';

/// CGV-style product order card (popcorn, drinks, etc.) with dynamic glow/shadow & press scaling.
class ProductOrderCard extends StatelessWidget {
  const ProductOrderCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onChanged,
  });
  final Product product;
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceText = NumberFormat('#,###', 'vi')
        .format(product.price)
        .replaceAll(',', '.');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: quantity > 0
              ? AppTheme.cgvRed
              : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)),
          width: quantity > 0 ? 1.8 : 1,
        ),
        boxShadow: quantity > 0
            ? [
                BoxShadow(
                  color: AppTheme.cgvRed.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Left: real product image or icon fallback
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
            child: SizedBox(
              width: 90,
              height: 90,
              child: product.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => Container(
                        color: AppTheme.cgvRed.withValues(alpha: .08),
                        child: const Icon(Icons.local_bar_outlined,
                            color: AppTheme.cgvRed, size: 28),
                      ),
                      errorWidget: (ctx, url, err) => Container(
                        color: AppTheme.cgvRed.withValues(alpha: .08),
                        child: const Icon(Icons.local_bar_outlined,
                            color: AppTheme.cgvRed, size: 28),
                      ),
                    )
                  : Container(
                      color: AppTheme.cgvRed.withValues(alpha: .08),
                      child: const Icon(Icons.local_bar_outlined,
                          color: AppTheme.cgvRed, size: 28),
                    ),
            ),
          ),
          // Info + stepper
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$priceText đ',
                          style: const TextStyle(
                            color: AppTheme.cgvRed,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // CGV stepper
                  _CgvStepper(quantity: quantity, onChanged: onChanged),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CgvStepper extends StatelessWidget {
  const _CgvStepper({required this.quantity, required this.onChanged});
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: Icons.remove,
          onTap: quantity > 0 ? () => onChanged(quantity - 1) : null,
        ),
        Container(
          width: 32,
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          onTap: quantity < 10 ? () => onChanged(quantity + 1) : null,
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppPressScale(
      onTap: onTap,
      enabled: onTap != null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap != null
              ? AppTheme.cgvRed
              : Colors.grey.withValues(alpha: .3),
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
