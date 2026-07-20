import 'package:flutter/material.dart';

class ShowtimeDateFilter extends StatelessWidget {
  const ShowtimeDateFilter({
    super.key,
    required this.date,
    required this.onChanged,
  });
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.calendar_month),
    title: Text(
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) onChanged(picked);
    },
  );
}
