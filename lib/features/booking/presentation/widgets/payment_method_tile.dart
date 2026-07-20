// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../models/booking.dart';

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: RadioListTile<PaymentMethod>(
      value: method,
      groupValue: selected ? method : null,
      onChanged: (_) => onTap(),
      title: Text(_label(method)),
      secondary: Icon(_icon(method)),
    ),
  );
  static String _label(PaymentMethod method) => switch (method) {
    PaymentMethod.momo => 'MoMo',
    PaymentMethod.zalopay => 'ZaloPay',
    PaymentMethod.vnpay => 'VNPay',
    PaymentMethod.card => 'Thẻ ngân hàng',
  };
  static IconData _icon(PaymentMethod method) => switch (method) {
    PaymentMethod.momo => Icons.account_balance_wallet,
    PaymentMethod.zalopay => Icons.wallet,
    PaymentMethod.vnpay => Icons.payments,
    PaymentMethod.card => Icons.credit_card,
  };
}
