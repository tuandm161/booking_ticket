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
    child: ListTile(
      title: Text(combo.name),
      subtitle: Text('${combo.price} đ\n${combo.description}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity == 0 ? null : () => onChanged(quantity - 1),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$quantity'),
          IconButton(
            onPressed: quantity >= 10 ? null : () => onChanged(quantity + 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    ),
  );
}
