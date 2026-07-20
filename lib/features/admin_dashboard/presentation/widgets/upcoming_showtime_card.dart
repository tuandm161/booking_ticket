import 'package:flutter/material.dart';

class UpcomingShowtimeCard extends StatelessWidget {
  const UpcomingShowtimeCard({super.key, required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.schedule),
      title: Text('$count suất chiếu'),
      subtitle: const Text('Trong 24 giờ tới'),
    ),
  );
}
