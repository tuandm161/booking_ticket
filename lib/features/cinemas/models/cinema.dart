import '../../../core/utils/firestore_converters.dart';

class Cinema {
  const Cinema({
    this.id = '',
    required this.name,
    required this.address,
    required this.city,
    required this.imageUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String imageUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Cinema.fromMap(String id, Map<String, Object?> map) => Cinema(
        id: id,
        name: map['name'] as String? ?? '',
        address: map['address'] as String? ?? '',
        city: map['city'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        isActive: map['isActive'] as bool? ?? true,
        createdAt: dateFromFirestore(map['createdAt']),
        updatedAt: dateFromFirestore(map['updatedAt']),
      );

  Map<String, Object?> toMap() => {
        'name': name,
        'address': address,
        'city': city,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'createdAt': dateToFirestore(createdAt),
        'updatedAt': dateToFirestore(updatedAt),
      };

  Cinema copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Cinema(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        city: city ?? this.city,
        imageUrl: imageUrl ?? this.imageUrl,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class CinemaDraft {
  const CinemaDraft({
    required this.name,
    required this.address,
    required this.city,
    required this.imageUrl,
    required this.isActive,
  });

  final String name;
  final String address;
  final String city;
  final String imageUrl;
  final bool isActive;

  Map<String, Object?> toMap({required DateTime now}) => {
        'name': name,
        'address': address,
        'city': city,
        'imageUrl': imageUrl,
        'isActive': isActive,
        'createdAt': dateToFirestore(now),
        'updatedAt': dateToFirestore(now),
      };
}
