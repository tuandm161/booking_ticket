import 'package:flutter/material.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.title,
    this.icon = Icons.inbox_outlined,
    this.action,
  });
  final String title;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48),
        const SizedBox(height: 8),
        Text(title),
        if (action != null) ...[const SizedBox(height: 12), action!],
      ],
    ),
  );
}
