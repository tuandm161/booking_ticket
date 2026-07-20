import 'package:flutter/material.dart';
import '../../models/combo.dart';
import '../../models/product.dart';

class ComboItemEditor extends StatelessWidget {
  const ComboItemEditor({
    super.key,
    required this.items,
    required this.products,
    required this.onChanged,
  });
  final List<ComboItem> items;
  final List<Product> products;
  final ValueChanged<List<ComboItem>> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ...items.map(
        (item) => ListTile(
          title: Text(item.productName),
          subtitle: Text('Số lượng: ${item.quantity}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _change(item, -1),
                icon: const Icon(Icons.remove),
              ),
              IconButton(
                onPressed: () => _change(item, 1),
                icon: const Icon(Icons.add),
              ),
              IconButton(
                onPressed: () => onChanged(
                  items.where((x) => x.productId != item.productId).toList(),
                ),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
      DropdownButtonFormField<String>(
        initialValue: null,
        decoration: const InputDecoration(labelText: 'Thêm sản phẩm'),
        items: products
            .where((p) => !items.any((i) => i.productId == p.id))
            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
            .toList(),
        onChanged: (id) {
          if (id == null) {
            return;
          }
          final p = products.firstWhere((x) => x.id == id);
          onChanged([
            ...items,
            ComboItem(productId: p.id, productName: p.name, quantity: 1),
          ]);
        },
      ),
    ],
  );
  void _change(ComboItem item, int delta) {
    final q = item.quantity + delta;
    if (q < 1) {
      return;
    }
    onChanged(
      items
          .map(
            (x) => x.productId == item.productId
                ? ComboItem(
                    productId: x.productId,
                    productName: x.productName,
                    quantity: q,
                  )
                : x,
          )
          .toList(),
    );
  }
}
