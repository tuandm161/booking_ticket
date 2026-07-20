import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../widgets/payment_method_tile.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});
  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentMethod selected = PaymentMethod.momo;
  bool simulateFailure = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Phương thức thanh toán')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final method in PaymentMethod.values)
          PaymentMethodTile(
            method: method,
            selected: selected == method,
            onTap: () => setState(() => selected = method),
          ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Mô phỏng thất bại (debug) only'),
          value: simulateFailure,
          onChanged: (value) => setState(() => simulateFailure = value),
        ),
        FilledButton(
          onPressed: () {
            final suffix = simulateFailure ? '?fail=true' : '';
            context.push(
              selected == PaymentMethod.card
                  ? '/user/card-payment$suffix'
                  : '/user/payment-processing/${selected.value}$suffix',
            );
          },
          child: const Text('Xác nhận'),
        ),
      ],
    ),
  );
}
