import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/app_exception.dart';
import '../models/voucher.dart';

class VoucherDraft {
  const VoucherDraft({
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.maxDiscount,
    required this.startDate,
    required this.endDate,
    required this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
  });
  final String code, description;
  final DiscountType discountType;
  final int discountValue, minOrderValue, maxDiscount, usageLimit, usedCount;
  final DateTime startDate, endDate;
  final bool isActive;
}

class VoucherRepository {
  const VoucherRepository(this._firestore);
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _vouchers =>
      _firestore.collection(FirestorePaths.vouchers);
  Future<Voucher?> getVoucher(String id) async {
    final d = await _vouchers.doc(id).get();
    return d.exists && d.data() != null
        ? Voucher.fromMap(d.id, Map<String, Object?>.from(d.data()!))
        : null;
  }

  Stream<List<Voucher>> watchVouchers({bool includeInactive = true}) =>
      _vouchers
          .orderBy('startDate', descending: true)
          .snapshots()
          .map(
            (s) => s.docs
                .map(
                  (d) => Voucher.fromMap(
                    d.id,
                    Map<String, Object?>.from(d.data()),
                  ),
                )
                .where((v) => includeInactive || v.isActive)
                .toList(),
          );
  Stream<List<Voucher>> watchPotentiallyAvailableVouchers() =>
      watchVouchers(includeInactive: false).map(
        (items) => items
            .where(
              (v) =>
                  v.endDate.isAfter(DateTime.now()) &&
                  v.usedCount < v.usageLimit,
            )
            .toList(),
      );
  Future<Voucher?> findByCode(String code) async {
    final s = await _vouchers
        .where('code', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    return s.docs.isEmpty
        ? null
        : Voucher.fromMap(
            s.docs.first.id,
            Map<String, Object?>.from(s.docs.first.data()),
          );
  }

  Future<bool> codeExists(String code, {String? excludingId}) async {
    final v = await findByCode(code);
    return v != null && v.id != excludingId;
  }

  Future<String> createVoucher(VoucherDraft d) async {
    _validate(d);
    if (await codeExists(d.code))
      throw const AppException(
        code: 'validation',
        message: 'Mã voucher đã tồn tại.',
      );
    final now = Timestamp.now();
    final v = Voucher(
      code: d.code.trim().toUpperCase(),
      description: d.description.trim(),
      discountType: d.discountType,
      discountValue: d.discountValue,
      minOrderValue: d.minOrderValue,
      maxDiscount: d.maxDiscount,
      startDate: d.startDate,
      endDate: d.endDate,
      usageLimit: d.usageLimit,
      usedCount: 0,
      isActive: d.isActive,
      createdAt: now.toDate(),
      updatedAt: now.toDate(),
    );
    return (await _vouchers.add(v.toMap())).id;
  }

  Future<void> updateVoucher(String id, VoucherDraft d) async {
    _validate(d);
    final current = await getVoucher(id);
    if (current == null)
      throw const AppException(
        code: 'not_found',
        message: 'Không tìm thấy voucher.',
      );
    if (await codeExists(d.code, excludingId: id))
      throw const AppException(
        code: 'validation',
        message: 'Mã voucher đã tồn tại.',
      );
    if (d.usageLimit < current.usedCount)
      throw const AppException(
        code: 'validation',
        message: 'Giới hạn lượt dùng không được nhỏ hơn đã sử dụng.',
      );
    final v = Voucher(
      id: id,
      code: d.code.trim().toUpperCase(),
      description: d.description.trim(),
      discountType: d.discountType,
      discountValue: d.discountValue,
      minOrderValue: d.minOrderValue,
      maxDiscount: d.maxDiscount,
      startDate: d.startDate,
      endDate: d.endDate,
      usageLimit: d.usageLimit,
      usedCount: current.usedCount,
      isActive: d.isActive,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    await _vouchers.doc(id).set(v.toMap());
  }

  Future<void> setActive(String id, bool active) => _vouchers.doc(id).update({
    'isActive': active,
    'updatedAt': Timestamp.now(),
  });
  Future<void> deleteVoucher(String id) async {
    final v = await getVoucher(id);
    if (v != null && v.usedCount > 0)
      throw const AppException(
        code: 'voucher_used',
        message: 'Voucher đã được sử dụng; hãy tắt hoạt động.',
      );
    await _vouchers.doc(id).delete();
  }

  void _validate(VoucherDraft d) {
    if (d.code.trim().isEmpty ||
        d.code.contains(RegExp(r'\s')) ||
        !d.startDate.isBefore(d.endDate) ||
        d.usageLimit <= 0 ||
        d.minOrderValue < 0 ||
        d.maxDiscount < 0 ||
        (d.discountType == DiscountType.percentage &&
            (d.discountValue < 1 || d.discountValue > 100)) ||
        (d.discountType == DiscountType.fixedAmount && d.discountValue <= 0))
      throw const AppException(
        code: 'validation',
        message: 'Thông tin voucher chưa hợp lệ.',
      );
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
