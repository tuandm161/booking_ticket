import 'package:flutter/material.dart';
import '../../models/cinema_room.dart';
import '../widgets/seat_layout_preview.dart';

class RoomDetailScreen extends StatelessWidget {
  const RoomDetailScreen({super.key, required this.room});
  final CinemaRoom room;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(room.name)),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: const Text('Loại phòng'),
          subtitle: Text(room.roomType.label),
        ),
        ListTile(
          title: const Text('Số ghế'),
          subtitle: Text(
            '${room.seats.length} ghế vật lý • Sức chứa ${room.seats.fold<int>(0, (sum, seat) => sum + seat.capacity)}',
          ),
        ),
        SeatLayoutPreview(seats: room.seats),
      ],
    ),
  );
}
