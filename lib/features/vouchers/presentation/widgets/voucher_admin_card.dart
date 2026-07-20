import 'package:flutter/material.dart';
import '../../models/voucher.dart';

class VoucherAdminCard extends StatelessWidget {
  const VoucherAdminCard({
    super.key,
    required this.voucher,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });
  final Voucher voucher;
  final VoidCallback onEdit, onToggle, onDelete;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(voucher.code),
      subtitle: Text(
        '${voucher.discountType == DiscountType.percentage ? 'Giảm ${voucher.discountValue}%' : 'Giảm ${voucher.discountValue}₫'} • ${voucher.usedCount}/${voucher.usageLimit} lượt',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) => switch (v) {
          'edit' => onEdit(),
          'toggle' => onToggle(),
          'delete' => onDelete(),
          _ => null,
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Sửa')),
          PopupMenuItem(
            value: 'toggle',
            child: Text(voucher.isActive ? 'Tắt' : 'Kích hoạt'),
          ),
          const PopupMenuItem(value: 'delete', child: Text('Xóa')),
        ],
      ),
    ),
  );
}
