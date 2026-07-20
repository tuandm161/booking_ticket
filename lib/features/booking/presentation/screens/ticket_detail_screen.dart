// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../providers/booking_providers.dart';
import '../widgets/ticket_qr_card.dart';
import '../widgets/ticket_seat_summary.dart';

class TicketDetailScreen extends ConsumerWidget {
  const TicketDetailScreen({super.key, required this.bookingId});
  final String bookingId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingDetailProvider(bookingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết vé')),
      bottomNavigationBar: const UserBottomNavigation(index: 2),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Không tải được vé.')),
        data: (booking) {
          if (booking == null)
            return const Center(child: Text('Booking không tồn tại.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (booking.moviePosterUrl.isNotEmpty)
                Image.network(
                  booking.moviePosterUrl,
                  height: 190,
                  fit: BoxFit.cover,
                ),
              Text(
                booking.movieTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${booking.startTime.day}/${booking.startTime.month}/${booking.startTime.year} ${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')} • ${booking.roomName}',
              ),
              TicketSeatSummary(booking: booking),
              if (booking.productItems.isNotEmpty)
                _ItemsCard(title: 'Sản phẩm', items: booking.productItems),
              if (booking.comboItems.isNotEmpty)
                _ItemsCard(title: 'Combo', items: booking.comboItems),
              Text('Voucher: ${booking.voucherCode ?? 'Không dùng'}'),
              Text('Phương thức: ${booking.paymentMethod.name}'),
              Text('Tạm tính: ${booking.subtotal} đ'),
              Text('Giảm giá: ${booking.discountAmount} đ'),
              Text(
                'Tổng: ${booking.totalAmount} đ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TicketQrCard(booking: booking),
            ],
          );
        },
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.title, required this.items});
  final String title;
  final List items;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ...items.map(
            (item) =>
                Text('${item.name} x${item.quantity} • ${item.totalPrice} đ'),
          ),
        ],
      ),
    ),
  );
}
