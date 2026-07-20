import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/pricing_constants.dart';
import '../../../core/services/firebase_providers.dart';
import '../../../core/utils/id_generator.dart';
import '../data/seat_hold_repository.dart';
import 'seat_hold_countdown_provider.dart';

final seatHoldRepositoryProvider = Provider<SeatHoldRepository>(
  (ref) => SeatHoldRepository(ref.watch(firestoreProvider)),
);
final seatHoldControllerProvider =
    NotifierProvider<SeatHoldController, AsyncValue<DateTime?>>(
      SeatHoldController.new,
    );

class SeatHoldController extends Notifier<AsyncValue<DateTime?>> {
  @override
  AsyncValue<DateTime?> build() => const AsyncData(null);
  Future<String?> hold({
    required String showtimeId,
    required List<String> seatCodes,
    String? reservationId,
    DateTime? now,
  }) async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      state = AsyncError(StateError('Bạn cần đăng nhập.'), StackTrace.current);
      return null;
    }
    final current = now ?? ref.read(clockServiceProvider).now();
    final id = reservationId ?? '${showtimeId}_${user.uid}_${generateId(8)}';
    state = const AsyncLoading();
    try {
      final expires = await ref
          .read(seatHoldRepositoryProvider)
          .holdSeats(
            showtimeId: showtimeId,
            userId: user.uid,
            selectedSeatCodes: seatCodes,
            reservationId: id,
            now: current,
            expiresAt: current.add(PricingConstants.seatHoldDuration),
          );
      state = AsyncData(expires);
      return id;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      return null;
    }
  }

  Future<void> release({
    required String showtimeId,
    required String reservationId,
    DateTime? now,
  }) async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;
    await ref
        .read(seatHoldRepositoryProvider)
        .releaseHeldSeats(
          showtimeId: showtimeId,
          userId: user.uid,
          reservationId: reservationId,
          now: now ?? ref.read(clockServiceProvider).now(),
        );
    state = const AsyncData(null);
  }
}
