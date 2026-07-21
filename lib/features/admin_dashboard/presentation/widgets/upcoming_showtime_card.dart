import 'package:flutter/material.dart';

class UpcomingShowtimeCard extends StatelessWidget {
  const UpcomingShowtimeCard({super.key, required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      leading: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: .16),
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.all(11),
          child: Icon(Icons.schedule_rounded),
        ),
      ),
      title: Text(
        '$count suất chiếu',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: const Text('Trong 24 giờ tới'),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
