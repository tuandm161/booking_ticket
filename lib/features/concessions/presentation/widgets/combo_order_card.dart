import 'package:flutter/material.dart';
import '../../models/combo.dart';

class ComboOrderCard extends StatelessWidget {
  const ComboOrderCard({
    super.key,
    required this.combo,
    required this.quantity,
    required this.onChanged,
  });
  final Combo combo;
  final int quantity;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  combo.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('${combo.price} đ'),
                if (combo.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    combo.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: quantity == 0 ? null : () => onChanged(quantity - 1),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$quantity'),
              IconButton(
                onPressed: quantity >= 10
                    ? null
                    : () => onChanged(quantity + 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
