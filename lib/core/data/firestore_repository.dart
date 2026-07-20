import 'package:cloud_firestore/cloud_firestore.dart';

import '../errors/app_exception.dart';

typedef FirestoreDecoder<T> = T Function(String id, Map<String, Object?> data);

/// Small shared repository primitive for feature repositories.
class FirestoreRepository<T> {
  const FirestoreRepository({
    required FirebaseFirestore firestore,
    required String collectionPath,
    required FirestoreDecoder<T> decoder,
  }) : _firestore = firestore,
       _collectionPath = collectionPath,
       _decoder = decoder;
  final FirebaseFirestore _firestore;
  final String _collectionPath;
  final FirestoreDecoder<T> _decoder;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionPath);

  Stream<List<T>> watchAll() => _collection.snapshots().map(
    (snapshot) => snapshot.docs
        .map((doc) => _decoder(doc.id, Map<String, Object?>.from(doc.data())))
        .toList(),
  );

  Future<T?> get(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      return doc.exists && doc.data() != null
          ? _decoder(doc.id, Map<String, Object?>.from(doc.data()!))
          : null;
    } on FirebaseException catch (error) {
      throw AppException(
        code: error.code,
        message: 'Không thể đọc dữ liệu.',
        cause: error,
      );
    }
  }

  Future<String> create(Map<String, Object?> data) async {
    try {
      final ref = await _collection.add(data);
      return ref.id;
    } on FirebaseException catch (error) {
      throw AppException(
        code: error.code,
        message: 'Không thể tạo dữ liệu.',
        cause: error,
      );
    }
  }

  Future<void> update(String id, Map<String, Object?> data) async {
    try {
      await _collection.doc(id).update(data);
    } on FirebaseException catch (error) {
      throw AppException(
        code: error.code,
        message: 'Không thể cập nhật dữ liệu.',
        cause: error,
      );
    }
  }
}
