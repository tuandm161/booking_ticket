import 'package:flutter/material.dart';

class RevenueSummaryCard extends StatelessWidget {
  const RevenueSummaryCard({
    super.key,
    required this.today,
    required this.total,
  });
  final int today, total;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments_rounded, color: colors.secondary),
                const SizedBox(width: 8),
                const Text(
                  'Doanh thu',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Amount(label: 'Hôm nay', amount: today),
                ),
                Expanded(
                  child: _Amount(label: 'Tổng cộng', amount: total),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.label, required this.amount});
  final String label;
  final int amount;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(
        '$amount đ',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
    ],
  );
}
