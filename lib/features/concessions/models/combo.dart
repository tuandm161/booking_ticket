import '../../../core/utils/firestore_converters.dart';

class ComboItem {
  const ComboItem({
    required this.productId,
    required this.productName,
    required this.quantity,
  });
  final String productId, productName;
  final int quantity;
  factory ComboItem.fromMap(Map<String, Object?> m) => ComboItem(
    productId: m['productId'] as String? ?? '',
    productName: m['productName'] as String? ?? '',
    quantity: (m['quantity'] as num?)?.toInt() ?? 0,
  );
  Map<String, Object?> toMap() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
  };
}

class Combo {
  const Combo({
    this.id = '',
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.items,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });
  final String id, name, description, imageUrl;
  final int price;
  final List<ComboItem> items;
  final bool isAvailable;
  final DateTime? createdAt, updatedAt;
  factory Combo.fromMap(String id, Map<String, Object?> m) => Combo(
    id: id,
    name: m['name'] as String? ?? '',
    description: m['description'] as String? ?? '',
    imageUrl: m['imageUrl'] as String? ?? '',
    price: (m['price'] as num?)?.toInt() ?? 0,
    items: (m['items'] is Iterable
        ? (m['items'] as Iterable)
              .whereType<Map>()
              .map(
                (x) => ComboItem.fromMap(
                  x.map((k, v) => MapEntry(k.toString(), v)),
                ),
              )
              .toList()
        : <ComboItem>[]),
    isAvailable: m['isAvailable'] as bool? ?? true,
    createdAt: dateFromFirestore(m['createdAt']),
    updatedAt: dateFromFirestore(m['updatedAt']),
  );
  Map<String, Object?> toMap() => {
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'price': price,
    'items': items.map((e) => e.toMap()).toList(),
    'isAvailable': isAvailable,
    'createdAt': dateToFirestore(createdAt),
    'updatedAt': dateToFirestore(updatedAt),
  };
  Combo copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? price,
    List<ComboItem>? items,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Combo(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    price: price ?? this.price,
    items: items ?? this.items,
    isAvailable: isAvailable ?? this.isAvailable,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
