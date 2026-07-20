import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_providers.dart';
import '../data/voucher_repository.dart';
import '../models/voucher.dart';

final voucherRepositoryProvider = Provider<VoucherRepository>(
  (ref) => VoucherRepository(ref.watch(firestoreProvider)),
);
final vouchersProvider = StreamProvider<List<Voucher>>(
  (ref) => ref.watch(voucherRepositoryProvider).watchVouchers(),
);
