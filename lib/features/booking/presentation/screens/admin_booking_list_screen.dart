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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Tất cả'),
                      selected: upcoming == null,
                      selectedColor: const Color(0xFFD7262D),
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFEEEEEE),
                      labelStyle: TextStyle(
                        color: upcoming == null
                            ? Colors.white
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF212121)),
                        fontWeight:
                            upcoming == null ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => upcoming = null),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Sắp tới'),
                      selected: upcoming == true,
                      selectedColor: const Color(0xFFD7262D),
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFEEEEEE),
                      labelStyle: TextStyle(
                        color: upcoming == true
                            ? Colors.white
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF212121)),
                        fontWeight:
                            upcoming == true ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => upcoming = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Đã qua'),
                      selected: upcoming == false,
                      selectedColor: const Color(0xFFD7262D),
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFEEEEEE),
                      labelStyle: TextStyle(
                        color: upcoming == false
                            ? Colors.white
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF212121)),
                        fontWeight:
                            upcoming == false ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12,
                      ),
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
