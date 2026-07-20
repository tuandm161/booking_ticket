// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../providers/booking_providers.dart';
import '../../providers/order_draft_provider.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  const PaymentSuccessScreen({super.key, required this.bookingId});
  final String bookingId;
  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(orderDraftProvider.notifier).clear());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingDetailProvider(widget.bookingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt vé thành công')),
      bottomNavigationBar: const UserBottomNavigation(index: 0),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Không tải được booking.')),
        data: (booking) {
          if (booking == null)
            return const Center(child: Text('Booking không tồn tại.'));
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 12),
                  Text(
                    'Mã vé: ${booking.bookingCode}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(booking.movieTitle),
                  Text('Tổng thanh toán: ${booking.totalAmount} đ'),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => context.go('/user/tickets/${booking.id}'),
                    child: const Text('Xem vé'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/user/home'),
                    child: const Text('Về trang chủ'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
