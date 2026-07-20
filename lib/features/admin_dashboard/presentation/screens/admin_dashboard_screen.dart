import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Admin Dashboard')),
    body: Center(
      child: FilledButton(
        onPressed: () => context.go('/login'),
        child: const Text('Đăng xuất'),
      ),
    ),
  );
}
