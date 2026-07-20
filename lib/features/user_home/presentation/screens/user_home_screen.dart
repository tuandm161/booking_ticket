import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Trang chủ User')),
    body: Center(
      child: FilledButton(
        onPressed: () => context.go('/login'),
        child: const Text('Đăng xuất'),
      ),
    ),
  );
}
