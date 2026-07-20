// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../providers/booking_providers.dart';
import '../widgets/ticket_qr_card.dart';
import '../widgets/ticket_seat_summary.dart';

class AdminBookingDetailScreen extends ConsumerWidget {
  const AdminBookingDetailScreen({super.key, required this.bookingId});
  final String bookingId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingDetailProvider(bookingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết booking')),
      bottomNavigationBar: const AdminBottomNavigation(index: 3),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Không tải được booking.')),
        data: (b) {
          if (b == null)
            return const Center(child: Text('Booking không tồn tại.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                b.movieTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('Mã: ${b.bookingCode}'),
              Text('User ID: ${b.userId}'),
              Text('Email: ${b.userEmail}'),
              Text('Tạo lúc: ${b.createdAt}'),
              Text('Suất: ${b.startTime} • ${b.roomName}'),
              TicketSeatSummary(booking: b),
              Text(
                'Thanh toán: ${b.paymentMethod.name} • ${b.paymentStatus.name}',
              ),
              Text('Tổng: ${b.totalAmount} đ'),
              TicketQrCard(booking: b),
            ],
          );
        },
      ),
    );
  }
}
