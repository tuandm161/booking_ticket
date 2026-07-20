import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? dateFromFirestore(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

Object? dateToFirestore(DateTime? value) =>
    value == null ? null : Timestamp.fromDate(value.toUtc());

List<String> stringListFromFirestore(Object? value) =>
    value is Iterable ? value.whereType<String>().toList() : <String>[];

Map<String, Object?> mapFromFirestore(Object? value) {
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return <String, Object?>{};
}
