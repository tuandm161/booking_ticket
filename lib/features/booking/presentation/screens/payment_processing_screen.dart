// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../providers/checkout_controller.dart';
import '../../providers/order_draft_provider.dart';

class PaymentProcessingScreen extends ConsumerStatefulWidget {
  const PaymentProcessingScreen({
    super.key,
    required this.method,
    this.simulateFailure = false,
  });
  final String method;
  final bool simulateFailure;
  @override
  ConsumerState<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends ConsumerState<PaymentProcessingScreen> {
  var started = false;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutControllerProvider);
    final draft = ref.watch(orderDraftProvider);
    if (!started && draft != null) {
      started = true;
      Future.microtask(
        () => ref
            .read(checkoutControllerProvider.notifier)
            .pay(
              draft: draft,
              method: PaymentMethodX.fromValue(widget.method),
              simulateFailure: widget.simulateFailure,
            ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Đang xử lý thanh toán')),
      body: state.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang xử lý giao dịch mô phỏng...'),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Thanh toán thất bại: $error'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
        data: (result) {
          if (result == null)
            return const Center(child: Text('Chuẩn bị thanh toán...'));
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 72),
                const SizedBox(height: 12),
                Text(
                  'Đặt vé thành công\nMã vé: ${result.bookingCode}',
                  textAlign: TextAlign.center,
                ),
                FilledButton(
                  onPressed: () => context.go('/user/home'),
                  child: const Text('Về trang chủ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
