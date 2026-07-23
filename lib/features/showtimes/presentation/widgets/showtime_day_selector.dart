import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/app_press_scale.dart';

/// CGV-style horizontal date selector.
/// Selected day has a red circle with dynamic glow shadow + press scaling. Nền tối.
class ShowtimeDaySelector extends StatelessWidget {
  const ShowtimeDaySelector({
    super.key,
    required this.days,
    required this.selected,
    required this.onSelected,
  });

  final List<DateTime> days;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  static const _weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  bool _isSame(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return _isSame(d, now);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF1A1A1A),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, i) {
                final day = days[i];
                final isSelected = _isSame(day, selected);
                final isToday = _isToday(day);

                return AppPressScale(
                  onTap: () => onSelected(day),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 52,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Weekday label
                        Text(
                          isToday ? 'Hôm nay' : _weekdays[day.weekday - 1],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.cgvRed
                                : Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Day number in circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppTheme.cgvRed
                                : Colors.transparent,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.cgvRed.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Selected date label
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _formatFullDate(selected),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime d) {
    const vn = ['', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    return '${vn[d.weekday]} ${d.day} tháng ${d.month}, ${d.year}';
  }
}
