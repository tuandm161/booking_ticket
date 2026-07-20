// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../../booking/providers/booking_providers.dart';
import '../../../booking/providers/seat_hold_countdown_provider.dart';
import '../widgets/ticket_card.dart';

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Vé của tôi')),
      bottomNavigationBar: const UserBottomNavigation(index: 2),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Không tải được vé.')),
        data: (bookings) {
          final groups = groupBookingsByTime(
            bookings,
            ref.read(clockServiceProvider).now(),
          );
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Sắp diễn ra'),
                    Tab(text: 'Đã xem'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _TicketList(items: groups.upcoming, upcoming: true),
                      _TicketList(items: groups.past, upcoming: false),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TicketList extends StatelessWidget {
  const _TicketList({required this.items, required this.upcoming});
  final List items;
  final bool upcoming;
  @override
  Widget build(BuildContext context) => items.isEmpty
      ? Center(
          child: Text(
            upcoming ? 'Chưa có vé sắp diễn ra.' : 'Chưa có vé đã xem.',
          ),
        )
      : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (_, i) =>
              TicketCard(booking: items[i], upcoming: upcoming),
        );
}
