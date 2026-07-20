// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../../movies/providers/movie_providers.dart';
import '../../providers/admin_booking_providers.dart';
import '../widgets/admin_booking_card.dart';

class AdminBookingListScreen extends ConsumerStatefulWidget {
  const AdminBookingListScreen({super.key});
  @override
  ConsumerState<AdminBookingListScreen> createState() =>
      _AdminBookingListScreenState();
}

class _AdminBookingListScreenState
    extends ConsumerState<AdminBookingListScreen> {
  final query = TextEditingController();
  String? movieId;
  bool? upcoming;
  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allBookingsProvider);
    final movies = ref.watch(moviesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      bottomNavigationBar: const AdminBottomNavigation(index: 3),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Không tải được booking.')),
        data: (items) {
          final filtered = filterAdminBookings(
            items,
            query: query.text,
            movieId: movieId,
            upcoming: upcoming,
          );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: query,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Tìm mã, email hoặc phim',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Tất cả'),
                      selected: upcoming == null,
                      onSelected: (_) => setState(() => upcoming = null),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Sắp tới'),
                      selected: upcoming == true,
                      onSelected: (_) => setState(() => upcoming = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Đã qua'),
                      selected: upcoming == false,
                      onSelected: (_) => setState(() => upcoming = false),
                    ),
                    const SizedBox(width: 8),
                    movies.maybeWhen(
                      data: (ms) => DropdownButton<String>(
                        hint: const Text('Phim'),
                        value: movieId,
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Tất cả phim'),
                          ),
                          ...ms.map(
                            (m) => DropdownMenuItem(
                              value: m.id,
                              child: Text(m.title),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => movieId = v),
                      ),
                      orElse: () => const SizedBox(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Không có booking.'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) =>
                            AdminBookingCard(booking: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
