import 'package:flutter/material.dart';
import '../../models/voucher.dart';

class AppliedVoucherCard extends StatelessWidget {
  const AppliedVoucherCard({
    super.key,
    required this.voucher,
    required this.onRemove,
  });
  final Voucher voucher;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.green.shade50,
    child: ListTile(
      leading: const Icon(Icons.local_offer),
      title: Text(voucher.code),
      subtitle: Text(voucher.description),
      trailing: IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
    ),
  );
}
