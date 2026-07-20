import 'package:flutter/material.dart';
import '../../models/cinema_room.dart';

class RoomFormFields extends StatelessWidget {
  const RoomFormFields({
    super.key,
    required this.nameController,
    required this.roomType,
    required this.onRoomTypeChanged,
    required this.rowController,
    required this.seatsController,
    required this.vipController,
    required this.coupleController,
    required this.isActive,
    required this.onActiveChanged,
  });
  final TextEditingController nameController,
      rowController,
      seatsController,
      vipController,
      coupleController;
  final RoomType roomType;
  final ValueChanged<RoomType?> onRoomTypeChanged;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextFormField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Tên phòng'),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Tên phòng không được để trống.'
            : null,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<RoomType>(
        initialValue: roomType,
        decoration: const InputDecoration(labelText: 'Loại phòng'),
        items: RoomType.values
            .map(
              (type) => DropdownMenuItem(value: type, child: Text(type.label)),
            )
            .toList(),
        onChanged: onRoomTypeChanged,
      ),
      const SizedBox(height: 12),
      _numberField(rowController, 'Số hàng (1–20)'),
      const SizedBox(height: 12),
      _numberField(seatsController, 'Số ghế mỗi hàng (2–20)'),
      const SizedBox(height: 12),
      _numberField(vipController, 'Hàng bắt đầu VIP (0 = không có)'),
      const SizedBox(height: 12),
      _numberField(coupleController, 'Số ghế đôi hàng cuối'),
      SwitchListTile(
        value: isActive,
        onChanged: onActiveChanged,
        title: const Text('Đang hoạt động'),
      ),
    ],
  );
  Widget _numberField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final number = int.tryParse(value ?? '');
          return number == null ? 'Nhập số hợp lệ.' : null;
        },
      );
}
