import '../../../core/errors/app_exception.dart';
import '../../../core/utils/firestore_converters.dart';

enum DiscountType { percentage, fixedAmount }

extension DiscountTypeX on DiscountType {
  String get value => name;
  static DiscountType fromValue(Object? value) =>
      DiscountType.values.where((item) => item.value == value).firstOrNull ??
      DiscountType.fixedAmount;
}

class Voucher {
  const Voucher({
    this.id = '',
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.maxDiscount,
    required this.startDate,
    required this.endDate,
    required this.usageLimit,
    required this.usedCount,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });
  final String id, code, description;
  final DiscountType discountType;
  final int discountValue, minOrderValue, maxDiscount, usageLimit, usedCount;
  final DateTime startDate, endDate;
  final bool isActive;
  final DateTime? createdAt, updatedAt;
  factory Voucher.fromMap(String id, Map<String, Object?> m) => Voucher(
    id: id,
    code: (m['code'] as String? ?? '').toUpperCase(),
    description: m['description'] as String? ?? '',
    discountType: DiscountTypeX.fromValue(m['discountType']),
    discountValue: (m['discountValue'] as num?)?.toInt() ?? 0,
    minOrderValue: (m['minOrderValue'] as num?)?.toInt() ?? 0,
    maxDiscount: (m['maxDiscount'] as num?)?.toInt() ?? 0,
    startDate:
        dateFromFirestore(m['startDate']) ??
        DateTime.fromMillisecondsSinceEpoch(0),
    endDate:
        dateFromFirestore(m['endDate']) ??
        DateTime.fromMillisecondsSinceEpoch(0),
    usageLimit: (m['usageLimit'] as num?)?.toInt() ?? 0,
    usedCount: (m['usedCount'] as num?)?.toInt() ?? 0,
    isActive: m['isActive'] as bool? ?? true,
    createdAt: dateFromFirestore(m['createdAt']),
    updatedAt: dateFromFirestore(m['updatedAt']),
  );
  Map<String, Object?> toMap() => {
    'code': code.toUpperCase(),
    'description': description,
    'discountType': discountType.value,
    'discountValue': discountValue,
    'minOrderValue': minOrderValue,
    'maxDiscount': maxDiscount,
    'startDate': dateToFirestore(startDate),
    'endDate': dateToFirestore(endDate),
    'usageLimit': usageLimit,
    'usedCount': usedCount,
    'isActive': isActive,
    'createdAt': dateToFirestore(createdAt),
    'updatedAt': dateToFirestore(updatedAt),
  };
  Voucher copyWith({
    String? id,
    String? code,
    String? description,
    DiscountType? discountType,
    int? discountValue,
    int? minOrderValue,
    int? maxDiscount,
    DateTime? startDate,
    DateTime? endDate,
    int? usageLimit,
    int? usedCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Voucher(
    id: id ?? this.id,
    code: code ?? this.code,
    description: description ?? this.description,
    discountType: discountType ?? this.discountType,
    discountValue: discountValue ?? this.discountValue,
    minOrderValue: minOrderValue ?? this.minOrderValue,
    maxDiscount: maxDiscount ?? this.maxDiscount,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    usageLimit: usageLimit ?? this.usageLimit,
    usedCount: usedCount ?? this.usedCount,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

int calculateDiscount({
  required Voucher voucher,
  required int subtotal,
  required DateTime now,
}) {
  if (!voucher.isActive ||
      now.isBefore(voucher.startDate) ||
      now.isAfter(voucher.endDate) ||
      voucher.usedCount >= voucher.usageLimit ||
      subtotal < voucher.minOrderValue) {
    throw AppException(
      code: 'voucher_invalid',
      message: 'Voucher không hợp lệ hoặc không đủ điều kiện.',
    );
  }
  if (subtotal <= 0) {
    return 0;
  }
  if (voucher.discountType == DiscountType.fixedAmount) {
    return voucher.discountValue.clamp(0, subtotal);
  }
  final discount = (subtotal * voucher.discountValue) ~/ 100;
  return voucher.maxDiscount > 0
      ? discount.clamp(0, voucher.maxDiscount)
      : discount.clamp(0, subtotal);
}
