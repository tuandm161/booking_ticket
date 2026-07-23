// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CardPaymentFormScreen extends StatefulWidget {
  const CardPaymentFormScreen({super.key, this.simulateFailure = false});
  final bool simulateFailure;
  @override
  State<CardPaymentFormScreen> createState() => _CardPaymentFormScreenState();
}

class _CardPaymentFormScreenState extends State<CardPaymentFormScreen> {
  final formKey = GlobalKey<FormState>();
  final number = TextEditingController();
  final holder = TextEditingController();
  final expiry = TextEditingController();
  final cvv = TextEditingController();
  @override
  void dispose() {
    number.dispose();
    holder.dispose();
    expiry.dispose();
    cvv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thẻ ngân hàng demo')),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: number,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Số thẻ 16 số'),
            validator: (v) =>
                RegExp(r'^\d{16}$').hasMatch(v?.replaceAll(' ', '') ?? '')
                ? null
                : 'Nhập đủ 16 chữ số',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: holder,
            decoration: const InputDecoration(labelText: 'Chủ thẻ'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: expiry,
                  decoration: const InputDecoration(labelText: 'MM/YY'),
                  validator: (v) => RegExp(r'^\d{2}/\d{2}$').hasMatch(v ?? '')
                      ? null
                      : 'Định dạng MM/YY',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: cvv,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'CVV'),
                  validator: (v) =>
                      RegExp(r'^\d{3}$').hasMatch(v ?? '') ? null : '3 chữ số',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate())
                context.push(
                  '/user/payment-processing/card${widget.simulateFailure ? '?fail=true' : ''}',
                );
            },
            child: const Text('Thanh toán demo'),
          ),
        ],
      ),
    ),
  );
}
