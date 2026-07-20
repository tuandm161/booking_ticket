// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 72,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: days.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final day = days[i];
        final active =
            day.year == selected.year &&
            day.month == selected.month &&
            day.day == selected.day;
        return ChoiceChip(
          label: Text(
            '${day.day}/${day.month}\n${['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][day.weekday - 1]}',
          ),
          selected: active,
          onSelected: (_) => onSelected(day),
        );
      },
    ),
  );
}
