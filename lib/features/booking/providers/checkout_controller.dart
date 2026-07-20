import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/checkout_repository.dart';
import '../models/booking.dart';
import '../models/checkout_result.dart';
import '../models/order_draft.dart';
import 'seat_hold_countdown_provider.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) => CheckoutRepository(ref.watch(firestoreProvider)),
);
final checkoutControllerProvider =
    NotifierProvider<CheckoutController, AsyncValue<CheckoutResult?>>(
      CheckoutController.new,
    );

class CheckoutController extends Notifier<AsyncValue<CheckoutResult?>> {
  @override
  AsyncValue<CheckoutResult?> build() => const AsyncData(null);
  Future<CheckoutResult?> pay({
    required OrderDraft draft,
    required PaymentMethod method,
    bool simulateFailure = false,
    Duration delay = const Duration(seconds: 2),
  }) async {
    final firebaseUser = ref.read(firebaseAuthProvider).currentUser;
    final appUser = ref
        .read(currentAppUserProvider)
        .maybeWhen(data: (user) => user, orElse: () => null);
    if (firebaseUser == null) {
      state = AsyncError(StateError('Bạn cần đăng nhập.'), StackTrace.current);
      return null;
    }
    state = const AsyncLoading();
    try {
      await PaymentSimulator.simulate(
        method,
        delay: delay,
        shouldFail: simulateFailure,
      );
      final result = await ref
          .read(checkoutRepositoryProvider)
          .checkout(
            draft: draft,
            userId: firebaseUser.uid,
            userEmail: appUser?.email ?? firebaseUser.email ?? '',
            paymentMethod: method,
            now: ref.read(clockServiceProvider).now(),
          );
      state = AsyncData(result);
      return result;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      return null;
    }
  }
}

class PaymentSimulator {
  static Future<void> simulate(
    PaymentMethod method, {
    Duration delay = const Duration(seconds: 2),
    bool shouldFail = false,
  }) async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Thanh toán mô phỏng thất bại.');
  }
}
