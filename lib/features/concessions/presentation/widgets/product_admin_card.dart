import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductAdminCard extends StatelessWidget {
  const ProductAdminCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });
  final Product product;
  final VoidCallback onEdit, onToggle, onDelete;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(product.name),
      subtitle: Text(
        '${product.category.label} • ${product.price}₫${product.isAvailable ? '' : ' • Ẩn'}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) => switch (v) {
          'edit' => onEdit(),
          'toggle' => onToggle(),
          'delete' => onDelete(),
          _ => null,
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Sửa')),
          PopupMenuItem(
            value: 'toggle',
            child: Text(product.isAvailable ? 'Ẩn' : 'Kích hoạt'),
          ),
          const PopupMenuItem(value: 'delete', child: Text('Xóa')),
        ],
      ),
    ),
  );
}
