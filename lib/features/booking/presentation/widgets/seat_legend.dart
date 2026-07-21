import 'package:flutter/material.dart';
import '../../models/seat_hold.dart';

class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 14),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          for (final item in [
            (SeatAvailability.available, 'Trống', Colors.blueGrey),
            (SeatAvailability.selected, 'Đã chọn', Colors.green),
            (SeatAvailability.heldByMe, 'Đang giữ', Colors.orange),
            (SeatAvailability.heldByOther, 'Người khác giữ', Colors.redAccent),
            (SeatAvailability.booked, 'Đã đặt', Colors.grey),
          ])
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.square, color: item.$3, size: 15),
                const SizedBox(width: 3),
                Text(item.$2),
              ],
            ),
        ],
      ),
    ),
  );
}
