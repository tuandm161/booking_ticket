import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../models/showtime.dart';
import '../../providers/showtime_providers.dart';
import '../widgets/showtime_admin_card.dart';
import '../widgets/showtime_date_filter.dart';

import '../../../../shared/widgets/admin_filter_sort_header.dart';
import '../../../../shared/widgets/app_press_scale.dart';

enum AdminShowtimeSortField { startTime, price, movieTitle }

extension AdminShowtimeSortFieldX on AdminShowtimeSortField {
  String get label => switch (this) {
        AdminShowtimeSortField.startTime => 'Giờ chiếu',
        AdminShowtimeSortField.price => 'Giá vé',
        AdminShowtimeSortField.movieTitle => 'Tên phim (A-Z)',
      };
}

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
  String _query = '';
  AdminActiveStatusFilter _activeStatus = AdminActiveStatusFilter.all;
  AdminShowtimeSortField _sortField = AdminShowtimeSortField.startTime;

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm theo phim hoặc phòng',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          AdminFilterSortHeader<AdminShowtimeSortField>(
            activeStatus: _activeStatus,
            onActiveStatusChanged: (val) => setState(() => _activeStatus = val),
            sortValue: _sortField,
            sortItems: AdminShowtimeSortField.values
                .map((sf) => DropdownMenuItem(value: sf, child: Text(sf.label)))
                .toList(),
            onSortChanged: (val) {
              if (val != null) setState(() => _sortField = val);
            },
          ),
          Expanded(
            child: AppAsyncValueWidget(
              value: showtimes,
              onRetry: () => ref.invalidate(showtimesProvider),
              data: (items) {
                final filtered = items.where((item) {
                  final matchesDate = item.startTime.year == _date.year &&
                      item.startTime.month == _date.month &&
                      item.startTime.day == _date.day;
                  final matchesRoom = _room == null || item.roomId == _room;
                  final matchesActive = switch (_activeStatus) {
                    AdminActiveStatusFilter.all => true,
                    AdminActiveStatusFilter.active => item.isActive,
                    AdminActiveStatusFilter.hidden => !item.isActive,
                  };
                  final matchesQuery = _query.isEmpty ||
                      item.movieTitle.toLowerCase().contains(_query) ||
                      item.roomName.toLowerCase().contains(_query);
                  return matchesDate &&
                      matchesRoom &&
                      matchesActive &&
                      matchesQuery;
                }).toList();

                filtered.sort((a, b) {
                  return switch (_sortField) {
                    AdminShowtimeSortField.startTime =>
                      a.startTime.compareTo(b.startTime),
                    AdminShowtimeSortField.price =>
                      b.basePrice.compareTo(a.basePrice),
                    AdminShowtimeSortField.movieTitle => a.movieTitle
                        .toLowerCase()
                        .compareTo(b.movieTitle.toLowerCase()),
                  };
                });

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
      bottomNavigationBar: const AdminBottomNavigation(index: 2),
      floatingActionButton: AppPressScale(
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/admin/showtimes/new'),
          icon: const Icon(Icons.add),
          label: const Text('Thêm suất'),
        ),
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
