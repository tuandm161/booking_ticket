import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/app_press_scale.dart';
import '../../models/showtime.dart';

/// CGV-style showtime time chip: hình chữ nhật bo góc nhẹ, khi bấm chọn
/// viền đỏ nổi bật + dynamic glow shadow.
class ShowtimeChip extends StatelessWidget {
  const ShowtimeChip({
    super.key,
    required this.showtime,
    required this.onTap,
    this.isSelected = false,
  });

  final Showtime showtime;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = showtime.startTime.hour.toString().padLeft(2, '0');
    final minute = showtime.startTime.minute.toString().padLeft(2, '0');

    return AppPressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.cgvRed
                : (isDark
                    ? const Color(0xFF424242)
                    : const Color(0xFFBDBDBD)),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppTheme.cgvRed.withValues(alpha: .15)
              : (isDark ? const Color(0xFF252525) : Colors.white),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.cgvRed.withValues(alpha: 0.4),
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
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? AppTheme.cgvRed
                : (isDark ? Colors.white : const Color(0xFF212121)),
          ),
          child: Text('$hour:$minute'),
        ),
      ),
    );
  }
}
