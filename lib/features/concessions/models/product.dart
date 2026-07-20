import '../../../core/utils/firestore_converters.dart';

enum ProductCategory { popcorn, drink, snack }

extension ProductCategoryX on ProductCategory {
  String get value => name;
  String get label => switch (this) {
    ProductCategory.popcorn => 'Bắp',
    ProductCategory.drink => 'Nước',
    ProductCategory.snack => 'Snack',
  };
  static ProductCategory fromValue(Object? value) =>
      ProductCategory.values.where((item) => item.value == value).firstOrNull ??
      ProductCategory.snack;
}

class Product {
  const Product({
    this.id = '',
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });
  final String id, name, description, imageUrl;
  final ProductCategory category;
  final int price;
  final bool isAvailable;
  final DateTime? createdAt, updatedAt;
  factory Product.fromMap(String id, Map<String, Object?> m) => Product(
    id: id,
    name: m['name'] as String? ?? '',
    category: ProductCategoryX.fromValue(m['category']),
    description: m['description'] as String? ?? '',
    imageUrl: m['imageUrl'] as String? ?? '',
    price: (m['price'] as num?)?.toInt() ?? 0,
    isAvailable: m['isAvailable'] as bool? ?? true,
    createdAt: dateFromFirestore(m['createdAt']),
    updatedAt: dateFromFirestore(m['updatedAt']),
  );
  Map<String, Object?> toMap() => {
    'name': name,
    'category': category.value,
    'description': description,
    'imageUrl': imageUrl,
    'price': price,
    'isAvailable': isAvailable,
    'createdAt': dateToFirestore(createdAt),
    'updatedAt': dateToFirestore(updatedAt),
  };
  Product copyWith({
    String? id,
    String? name,
    ProductCategory? category,
    String? description,
    String? imageUrl,
    int? price,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    price: price ?? this.price,
    isAvailable: isAvailable ?? this.isAvailable,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
