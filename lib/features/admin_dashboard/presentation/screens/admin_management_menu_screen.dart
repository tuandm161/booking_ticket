import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_controller.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';

class AdminManagementMenuScreen extends ConsumerWidget {
  const AdminManagementMenuScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Quản lý')),
    bottomNavigationBar: const AdminBottomNavigation(index: 4),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Link(
          label: 'Phòng chiếu',
          icon: Icons.meeting_room,
          path: '/admin/rooms',
        ),
        _Link(
          label: 'Sản phẩm',
          icon: Icons.local_drink,
          path: '/admin/products',
        ),
        _Link(label: 'Combo', icon: Icons.fastfood, path: '/admin/combos'),
        _Link(label: 'Voucher', icon: Icons.discount, path: '/admin/vouchers'),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).signOut();
            if (!context.mounted) return;
            final state = ref.read(authControllerProvider);
            if (state.hasError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error.toString())));
            } else {
              context.go('/login');
            }
          },
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.icon, required this.path});
  final String label, path;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(path),
    ),
  );
}
