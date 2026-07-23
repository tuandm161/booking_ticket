import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';

/// CGV-style seat legend with colour squares and labels.
class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 10,
        children: [
          _LegendItem(color: const Color(0xFFC0C0C0), label: 'Thường'),
          _LegendItem(color: const Color(0xFF8B1A1A), label: 'VIP'),
          _LegendItem(color: const Color(0xFFE91E63), label: 'Sweet Box'),
          _LegendItem(color: AppTheme.cgvRed, label: 'Đã chọn'),
          _LegendItem(color: const Color(0xFF4A4A4A), label: 'Đã bán'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70, // always readable on dark seat-selection bg
          ),
        ),
      ],
    );
  }
}
