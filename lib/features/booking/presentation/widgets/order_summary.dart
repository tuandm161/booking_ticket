import 'package:flutter/material.dart';
import '../../providers/order_totals_provider.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key, required this.totals});
  final OrderTotals totals;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _line('Vé', totals.seatSubtotal),
          _line('Sản phẩm', totals.productSubtotal),
          _line('Combo', totals.comboSubtotal),
          if (totals.discountAmount > 0)
            _line('Giảm giá', -totals.discountAmount),
          const Divider(),
          _line('Tổng thanh toán', totals.totalAmount, bold: true),
        ],
      ),
    ),
  );
  Widget _line(String label, int amount, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
      Text(
        '$amount đ',
        style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
      ),
    ],
  );
}
