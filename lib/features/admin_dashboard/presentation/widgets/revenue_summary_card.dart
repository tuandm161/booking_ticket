import 'package:flutter/material.dart';

class RevenueSummaryCard extends StatelessWidget {
  const RevenueSummaryCard({
    super.key,
    required this.today,
    required this.total,
  });
  final int today, total;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Hôm nay: $today đ'),
          Text('Tổng: $total đ'),
        ],
      ),
    ),
  );
}
