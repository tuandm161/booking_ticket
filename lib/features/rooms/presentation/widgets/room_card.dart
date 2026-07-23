import 'package:flutter/material.dart';
import '../../models/cinema_room.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key,
    required this.room,
    required this.onEdit,
    required this.onPreview,
    required this.onToggle,
    required this.onDelete,
  });
  final CinemaRoom room;
  final VoidCallback onEdit, onPreview, onToggle, onDelete;
  @override
  Widget build(BuildContext context) {
    final capacity = room.seats.fold<int>(
      0,
      (sum, seat) => sum + seat.capacity,
    );
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFD7262D).withValues(alpha: 0.12),
          child: Text(
            RegExp(r'\d+').firstMatch(room.name)?.group(0) ?? 'P',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFD7262D),
            ),
          ),
        ),
        title: Text(room.name),
        subtitle: Text(
          '${room.roomType.label} • ${room.seats.length} ghế • Sức chứa $capacity',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => switch (value) {
            'edit' => onEdit(),
            'preview' => onPreview(),
            'toggle' => onToggle(),
            'delete' => onDelete(),
            _ => null,
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Sửa')),
            const PopupMenuItem(value: 'preview', child: Text('Xem sơ đồ')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(room.isActive ? 'Ngừng hoạt động' : 'Kích hoạt lại'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Xóa')),
          ],
        ),
      ),
    );
  }
}
