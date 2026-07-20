import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../models/product.dart';

class ProductDraft {
  const ProductDraft({
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isAvailable = true,
  });
  final String name, description, imageUrl;
  final ProductCategory category;
  final int price;
  final bool isAvailable;
  ProductDraft copyWith({
    String? name,
    ProductCategory? category,
    String? description,
    String? imageUrl,
    int? price,
    bool? isAvailable,
  }) => ProductDraft(
    name: name ?? this.name,
    category: category ?? this.category,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    price: price ?? this.price,
    isAvailable: isAvailable ?? this.isAvailable,
  );
}

class ProductRepository {
  const ProductRepository(this._firestore);
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection(FirestorePaths.products);
  Stream<List<Product>> watchProducts({bool includeUnavailable = true}) =>
      _products
          .orderBy('name')
          .snapshots()
          .map(
            (s) => s.docs
                .map(
                  (d) => Product.fromMap(
                    d.id,
                    Map<String, Object?>.from(d.data()),
                  ),
                )
                .where((p) => includeUnavailable || p.isAvailable)
                .toList(),
          );
  Future<Product?> getProduct(String id) async {
    final d = await _products.doc(id).get();
    return d.exists && d.data() != null
        ? Product.fromMap(d.id, Map<String, Object?>.from(d.data()!))
        : null;
  }

  Future<String> createProduct(ProductDraft draft) async {
    _validate(draft);
    final now = Timestamp.now();
    final p = Product(
      name: draft.name.trim(),
      category: draft.category,
      description: draft.description.trim(),
      imageUrl: draft.imageUrl.trim(),
      price: draft.price,
      isAvailable: draft.isAvailable,
      createdAt: now.toDate(),
      updatedAt: now.toDate(),
    );
    try {
      return (await _products.add(p.toMap())).id;
    } on FirebaseException catch (e) {
      throw AppException(
        code: e.code,
        message: 'Không thể tạo sản phẩm.',
        cause: e,
      );
    }
  }

  Future<void> updateProduct(String id, ProductDraft draft) async {
    _validate(draft);
    final old = await getProduct(id);
    if (old == null)
      throw const AppException(
        code: 'not_found',
        message: 'Không tìm thấy sản phẩm.',
      );
    final p = Product(
      id: id,
      name: draft.name.trim(),
      category: draft.category,
      description: draft.description.trim(),
      imageUrl: draft.imageUrl.trim(),
      price: draft.price,
      isAvailable: draft.isAvailable,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
    );
    await _products.doc(id).set(p.toMap());
  }

  Future<void> setAvailable(String id, bool available) => _products
      .doc(id)
      .update({'isAvailable': available, 'updatedAt': Timestamp.now()});
  Future<bool> isUsedInBookingOrCombo(String id) async {
    final combo =
        (await _firestore
                .collection(FirestorePaths.combos)
                .where('items', arrayContains: {'productId': id})
                .limit(1)
                .get())
            .docs
            .isNotEmpty;
    final booking =
        (await _firestore
                .collection(FirestorePaths.bookings)
                .where('productItems', arrayContains: {'productId': id})
                .limit(1)
                .get())
            .docs
            .isNotEmpty;
    return combo || booking;
  }

  Future<void> deleteProduct(String id) async {
    if (await isUsedInBookingOrCombo(id))
      throw const AppException(
        code: 'product_referenced',
        message: 'Sản phẩm đã được sử dụng; hãy chuyển sang không khả dụng.',
      );
    await _products.doc(id).delete();
  }

  void _validate(ProductDraft d) {
    if (requiredText(d.name, field: 'Tên sản phẩm') != null ||
        d.price <= 0 ||
        urlValidator(d.imageUrl) != null)
      throw const AppException(
        code: 'validation',
        message: 'Thông tin sản phẩm chưa hợp lệ.',
      );
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
