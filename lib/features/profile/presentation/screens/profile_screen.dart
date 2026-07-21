import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_controller.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../../../shared/models/app_user.dart';

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
                OutlinedButton.icon(
                  onPressed: () => _showEditProfileDialog(context, ref, user),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Chỉnh sửa hồ sơ'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (!context.mounted) return;
                    final state = ref.read(authControllerProvider);
                    if (state.hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error.toString())),
                      );
                    } else {
                      context.go('/login');
                    }
                  },
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
      bottomNavigationBar: const UserBottomNavigation(index: 4),
    );
  }
}

Future<void> _showEditProfileDialog(
  BuildContext context,
  WidgetRef ref,
  AppUser user,
) async {
  final controller = TextEditingController(text: user.displayName);
  try {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chỉnh sửa hồ sơ'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Tên hiển thị'),
          onSubmitted: (_) => Navigator.of(dialogContext).pop(controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (name == null || !context.mounted) return;
    try {
      await ref.read(authRepositoryProvider).updateProfile(displayName: name);
      ref.invalidate(currentAppUserProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã cập nhật hồ sơ.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  } finally {
    controller.dispose();
  }
}
