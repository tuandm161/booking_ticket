import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_controller.dart';
import '../../../auth/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAppUserProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: user == null
          ? const Center(child: Text('Không tìm thấy hồ sơ người dùng.'))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ListTile(
                  title: Text(user.displayName),
                  subtitle: Text(user.email),
                ),
                ListTile(
                  title: const Text('Vai trò'),
                  subtitle: Text(user.role.name),
                ),
                FilledButton(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  },
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
    );
  }
}
