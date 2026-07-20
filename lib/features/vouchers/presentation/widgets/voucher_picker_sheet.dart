import 'package:flutter/material.dart';
import '../../models/voucher.dart';

class VoucherPickerSheet extends StatelessWidget {
  const VoucherPickerSheet({
    super.key,
    required this.vouchers,
    required this.onSelected,
  });
  final List<Voucher> vouchers;
  final ValueChanged<Voucher> onSelected;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Voucher khả dụng',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ...vouchers.map(
          (voucher) => ListTile(
            leading: const Icon(Icons.local_offer_outlined),
            title: Text(voucher.code),
            subtitle: Text(voucher.description),
            onTap: () {
              onSelected(voucher);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    ),
  );
}
