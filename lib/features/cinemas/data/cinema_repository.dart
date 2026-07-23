import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../models/cinema.dart';

class CinemaRepository {
  const CinemaRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.cinemas);

  Stream<List<Cinema>> watchCinemas({bool includeInactive = true}) {
    Query<Map<String, dynamic>> query = _collection;
    if (!includeInactive) {
      query = query.where('isActive', isEqualTo: true);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Cinema.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<Cinema?> getCinema(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Cinema.fromMap(doc.id, doc.data()!);
  }

  Future<String> createCinema(CinemaDraft draft) async {
    final now = DateTime.now();
    final doc = await _collection.add(draft.toMap(now: now));
    return doc.id;
  }

  Future<void> updateCinema(String id, CinemaDraft draft) async {
    final now = DateTime.now();
    await _collection.doc(id).update({
      'name': draft.name,
      'address': draft.address,
      'city': draft.city,
      'imageUrl': draft.imageUrl,
      'isActive': draft.isActive,
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  Future<void> setCinemaActive(String id, bool isActive) async {
    await _collection.doc(id).update({
      'isActive': isActive,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteCinema(String id) async {
    await _collection.doc(id).delete();
  }
}
