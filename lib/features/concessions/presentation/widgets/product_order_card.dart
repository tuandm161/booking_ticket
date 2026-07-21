import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductOrderCard extends StatelessWidget {
  const ProductOrderCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onChanged,
  });
  final Product product;
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
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('${product.price} đ'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _QuantityControl(quantity: quantity, onChanged: onChanged),
        ],
      ),
    ),
  );
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.quantity, required this.onChanged});
  final int quantity;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(
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
  );
}
