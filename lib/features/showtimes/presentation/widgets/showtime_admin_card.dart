import 'package:flutter/material.dart';
import '../../models/showtime.dart';

class ShowtimeAdminCard extends StatelessWidget {
  const ShowtimeAdminCard({
    super.key,
    required this.showtime,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });
  final Showtime showtime;
  final VoidCallback onEdit, onToggle, onDelete;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(
        showtime.movieTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${showtime.roomName} • ${_time(showtime.startTime)}–${_time(showtime.endTime)}\n${showtime.basePrice}₫ • ${showtime.bookedSeatCodes.length} ghế đã đặt',
      ),
      isThreeLine: true,
      trailing: PopupMenuButton<String>(
        onSelected: (value) => switch (value) {
          'edit' => onEdit(),
          'toggle' => onToggle(),
          'delete' => onDelete(),
          _ => null,
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Sửa')),
          PopupMenuItem(
            value: 'toggle',
            child: Text(showtime.isActive ? 'Ẩn suất' : 'Kích hoạt'),
          ),
          const PopupMenuItem(value: 'delete', child: Text('Xóa')),
        ],
      ),
    ),
  );
  String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
