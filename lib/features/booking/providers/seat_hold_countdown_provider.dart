import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/clock_service.dart';

final clockServiceProvider = Provider<ClockService>((_) => ClockService());
final seatHoldCountdownProvider = StreamProvider.family<Duration, DateTime>((
  ref,
  expiresAt,
) async* {
  final clock = ref.watch(clockServiceProvider);
  yield _remaining(expiresAt, clock);
  await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
    final remaining = _remaining(expiresAt, clock);
    yield remaining;
    if (remaining <= Duration.zero) break;
  }
});

Duration _remaining(DateTime expiresAt, ClockService clock) {
  final value = expiresAt.difference(clock.now());
  return value.isNegative ? Duration.zero : value;
}
