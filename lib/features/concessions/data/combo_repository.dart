import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/app_exception.dart';
import '../models/combo.dart';
import '../models/product.dart';

class ComboDraft {
  const ComboDraft({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.items,
    this.isAvailable = true,
  });
  final String name, description, imageUrl;
  final int price;
  final List<ComboItem> items;
  final bool isAvailable;
  ComboDraft copyWith({
    String? name,
    String? description,
    String? imageUrl,
    int? price,
    List<ComboItem>? items,
    bool? isAvailable,
  }) => ComboDraft(
    name: name ?? this.name,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    price: price ?? this.price,
    items: items ?? this.items,
    isAvailable: isAvailable ?? this.isAvailable,
  );
}

class ComboRepository {
  const ComboRepository(this._firestore);
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _combos =>
      _firestore.collection(FirestorePaths.combos);
  Stream<List<Combo>> watchCombos({bool includeUnavailable = true}) => _combos
      .orderBy('name')
      .snapshots()
      .map(
        (s) => s.docs
            .map(
              (d) => Combo.fromMap(d.id, Map<String, Object?>.from(d.data())),
            )
            .where((c) => includeUnavailable || c.isAvailable)
            .toList(),
      );
  Future<Combo?> getCombo(String id) async {
    final d = await _combos.doc(id).get();
    return d.exists && d.data() != null
        ? Combo.fromMap(d.id, Map<String, Object?>.from(d.data()!))
        : null;
  }

  Future<String> createCombo(ComboDraft d) async {
    _validate(d);
    final items = await _snapshotItems(d.items);
    final now = Timestamp.now();
    final c = Combo(
      name: d.name.trim(),
      description: d.description.trim(),
      imageUrl: d.imageUrl.trim(),
      price: d.price,
      items: items,
      isAvailable: d.isAvailable,
      createdAt: now.toDate(),
      updatedAt: now.toDate(),
    );
    return (await _combos.add(c.toMap())).id;
  }

  Future<void> updateCombo(String id, ComboDraft d) async {
    _validate(d);
    final old = await getCombo(id);
    if (old == null)
      throw const AppException(
        code: 'not_found',
        message: 'Không tìm thấy combo.',
      );
    final c = Combo(
      id: id,
      name: d.name.trim(),
      description: d.description.trim(),
      imageUrl: d.imageUrl.trim(),
      price: d.price,
      items: await _snapshotItems(d.items),
      isAvailable: d.isAvailable,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
    );
    await _combos.doc(id).set(c.toMap());
  }

  Future<void> setAvailable(String id, bool available) => _combos
      .doc(id)
      .update({'isAvailable': available, 'updatedAt': Timestamp.now()});
  Future<bool> isUsedInBooking(String id) async =>
      (await _firestore
              .collection(FirestorePaths.bookings)
              .where('comboItems', arrayContains: {'comboId': id})
              .limit(1)
              .get())
          .docs
          .isNotEmpty;
  Future<void> deleteCombo(String id) async {
    if (await isUsedInBooking(id))
      throw const AppException(
        code: 'combo_referenced',
        message: 'Combo đã được sử dụng; hãy chuyển sang không khả dụng.',
      );
    await _combos.doc(id).delete();
  }

  Future<List<ComboItem>> _snapshotItems(List<ComboItem> items) async {
    final result = <ComboItem>[];
    for (final item in items) {
      final d = await _firestore
          .collection(FirestorePaths.products)
          .doc(item.productId)
          .get();
      if (!d.exists || d.data() == null)
        throw const AppException(
          code: 'not_found',
          message: 'Sản phẩm trong combo không tồn tại.',
        );
      final p = Product.fromMap(d.id, Map<String, Object?>.from(d.data()!));
      if (!p.isAvailable)
        throw const AppException(
          code: 'validation',
          message: 'Sản phẩm trong combo không khả dụng.',
        );
      result.add(
        ComboItem(
          productId: p.id,
          productName: p.name,
          quantity: item.quantity,
        ),
      );
    }
    return result;
  }

  void _validate(ComboDraft d) {
    if (d.name.trim().isEmpty ||
        d.price <= 0 ||
        d.items.isEmpty ||
        d.items.any((i) => i.quantity < 1))
      throw const AppException(
        code: 'validation',
        message: 'Thông tin combo chưa hợp lệ.',
      );
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
