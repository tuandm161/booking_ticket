import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/services/firebase_providers.dart';
import '../models/showtime.dart';

final userShowtimesProvider = StreamProvider.family<List<Showtime>, String>(
  (ref, movieId) => ref
      .watch(firestoreProvider)
      .collection(FirestorePaths.showtimes)
      .where('movieId', isEqualTo: movieId)
      .where('isActive', isEqualTo: true)
      .where('startTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
      .orderBy('startTime')
      .snapshots()
      .map(
        (s) => s.docs
            .map(
              (d) =>
                  Showtime.fromMap(d.id, Map<String, Object?>.from(d.data())),
            )
            .where(
              (x) => x.startTime.isBefore(
                DateTime.now().add(const Duration(days: 14)),
              ),
            )
            .toList(),
      ),
);
