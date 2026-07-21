import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/seed_provider.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../providers/room_providers.dart';
import '../widgets/room_card.dart';

class AdminRoomListScreen extends ConsumerStatefulWidget {
  const AdminRoomListScreen({super.key});
  @override
  ConsumerState<AdminRoomListScreen> createState() =>
      _AdminRoomListScreenState();
}

class _AdminRoomListScreenState extends ConsumerState<AdminRoomListScreen> {
  bool _includeInactive = true;
  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý phòng'),
        actions: [
          IconButton(
            tooltip: 'Tạo 4 phòng mẫu',
            onPressed: _seed,
            icon: const Icon(Icons.playlist_add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Tất cả')),
                ButtonSegment(value: false, label: Text('Đang hoạt động')),
              ],
              selected: {_includeInactive},
              onSelectionChanged: (value) =>
                  setState(() => _includeInactive = value.first),
            ),
          ),
          Expanded(
            child: AppAsyncValueWidget(
              value: rooms,
              onRetry: () => ref.invalidate(roomsProvider),
              data: (items) {
                final visible = _includeInactive
                    ? items
                    : items.where((room) => room.isActive).toList();
                if (visible.isEmpty)
                  return const Center(child: Text('Chưa có phòng chiếu.'));
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: visible.length,
                  itemBuilder: (_, index) {
                    final room = visible[index];
                    return RoomCard(
                      room: room,
                      onEdit: () =>
                          context.push('/admin/rooms/${room.id}/edit'),
                      onPreview: () =>
                          context.push('/admin/rooms/${room.id}', extra: room),
                      onToggle: () => _toggle(room.id, room.isActive),
                      onDelete: () => _delete(room.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNavigation(index: 4),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/rooms/new'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm phòng'),
      ),
    );
  }

  Future<void> _seed() async {
    try {
      final result = await ref.read(seedServiceProvider).seedDefaultRooms();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.skipped
                ? 'Đã có dữ liệu phòng, không seed lại.'
                : 'Đã tạo ${result.createdCount} phòng mẫu.',
          ),
        ),
      );
      ref.invalidate(roomsProvider);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _toggle(String id, bool active) async {
    try {
      await ref.read(roomRepositoryProvider).setRoomActive(id, !active);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _delete(String id) async {
    if (!await showConfirmDialog(
      context,
      title: 'Xóa phòng?',
      message: 'Phòng có suất chiếu sẽ không thể xóa cứng.',
    ))
      return;
    try {
      await ref.read(roomRepositoryProvider).deleteRoom(id);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
