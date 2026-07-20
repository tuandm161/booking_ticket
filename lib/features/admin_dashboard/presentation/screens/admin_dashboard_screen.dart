import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Admin Dashboard')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          onPressed: () => context.push('/admin/rooms'),
          icon: const Icon(Icons.meeting_room_outlined),
          label: const Text('Quản lý phòng chiếu'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => context.push('/admin/movies'),
          icon: const Icon(Icons.movie_outlined),
          label: const Text('Quản lý phim'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => context.push('/admin/showtimes'),
          icon: const Icon(Icons.schedule_outlined),
          label: const Text('Quản lý suất chiếu'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.go('/login'),
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );
}
