import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../models/showtime.dart';
import '../../providers/showtime_providers.dart';
import '../widgets/showtime_admin_card.dart';
import '../widgets/showtime_date_filter.dart';

class AdminShowtimeListScreen extends ConsumerStatefulWidget {
  const AdminShowtimeListScreen({super.key});
  @override
  ConsumerState<AdminShowtimeListScreen> createState() =>
      _AdminShowtimeListScreenState();
}

class _AdminShowtimeListScreenState
    extends ConsumerState<AdminShowtimeListScreen> {
  DateTime _date = DateTime.now();
  String? _room;
  @override
  Widget build(BuildContext context) {
    final showtimes = ref.watch(showtimesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý suất chiếu')),
      body: Column(
        children: [
          ShowtimeDateFilter(
            date: _date,
            onChanged: (date) => setState(() => _date = date),
          ),
          Expanded(
            child: AppAsyncValueWidget(
              value: showtimes,
              onRetry: () => ref.invalidate(showtimesProvider),
              data: (items) {
                final filtered = items
                    .where(
                      (item) =>
                          item.startTime.year == _date.year &&
                          item.startTime.month == _date.month &&
                          item.startTime.day == _date.day &&
                          (_room == null || item.roomId == _room),
                    )
                    .toList();
                filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
                if (filtered.isEmpty)
                  return const Center(
                    child: Text('Chưa có suất chiếu trong ngày này.'),
                  );
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final item = filtered[index];
                    return ShowtimeAdminCard(
                      showtime: item,
                      onEdit: () =>
                          context.push('/admin/showtimes/${item.id}/edit'),
                      onToggle: () => ref
                          .read(showtimeRepositoryProvider)
                          .setShowtimeActive(item.id, !item.isActive),
                      onDelete: () => _delete(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/showtimes/new'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm suất'),
      ),
    );
  }

  Future<void> _delete(Showtime item) async {
    if (!await showConfirmDialog(
      context,
      title: 'Xóa suất chiếu?',
      message: 'Suất đã có ghế/booking sẽ chỉ được ẩn.',
    ))
      return;
    try {
      await ref.read(showtimeRepositoryProvider).deleteShowtime(item.id);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
