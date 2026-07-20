class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
  final String productId, name;
  final int quantity, unitPrice, totalPrice;
  factory OrderItem.fromMap(Map<String, Object?> m) => OrderItem(
    productId: m['productId'] as String? ?? '',
    name: m['name'] as String? ?? '',
    quantity: (m['quantity'] as num?)?.toInt() ?? 0,
    unitPrice: (m['unitPrice'] as num?)?.toInt() ?? 0,
    totalPrice: (m['totalPrice'] as num?)?.toInt() ?? 0,
  );
  Map<String, Object?> toMap() => {
    'productId': productId,
    'name': name,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalPrice': totalPrice,
  };
}
