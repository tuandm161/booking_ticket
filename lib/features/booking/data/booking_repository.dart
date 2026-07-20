import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../models/booking.dart';

class BookingRepository {
  const BookingRepository(this._firestore);
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection(FirestorePaths.bookings);
  Stream<List<Booking>> watchMyBookings(String userId) => _bookings
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Booking.fromMap(
                doc.id,
                Map<String, Object?>.from(doc.data()),
              ),
            )
            .toList(),
      );
  Stream<List<Booking>> watchAllBookings() => _bookings
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Booking.fromMap(
                doc.id,
                Map<String, Object?>.from(doc.data()),
              ),
            )
            .toList(),
      );
  Future<Booking?> getBooking(String bookingId) async {
    final doc = await _bookings.doc(bookingId).get();
    return doc.exists && doc.data() != null
        ? Booking.fromMap(doc.id, Map<String, Object?>.from(doc.data()!))
        : null;
  }
}
