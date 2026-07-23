import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_theme.dart';
import '../../../auth/providers/auth_controller.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../../../shared/models/app_user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAppUserProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0E0E0E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'TÀI KHOẢN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Không tìm thấy hồ sơ người dùng.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── User Info Header Card ─────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252525) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF3A3A3A)
                          : const Color(0xFFE0E0E0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar placeholder
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: AppTheme.cgvRed,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: user.role == UserRole.admin
                                    ? AppTheme.cgvRed
                                    : Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.role == UserRole.admin ? 'ADMIN' : 'MEMBER',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Options Section ─────────────────────────────
                _SectionHeader(label: 'CÀI ĐẶT TÀI KHOẢN'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252525) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF3A3A3A)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.edit_outlined,
                        label: 'Chỉnh sửa hồ sơ',
                        onTap: () => _showEditProfileDialog(context, ref, user),
                      ),
                      _Divider(isDark: isDark),
                      _ProfileTile(
                        icon: Icons.confirmation_num_outlined,
                        label: 'Lịch sử đặt vé',
                        onTap: () => context.push('/user/tickets'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Sign Out Button ─────────────────────────────
                OutlinedButton.icon(
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.cgvRed,
                    side: const BorderSide(color: AppTheme.cgvRed, width: 1.5),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('ĐĂNG XUẤT'),
                ),
              ],
            ),
      bottomNavigationBar: const UserBottomNavigation(index: 4),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.cgvRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.cgvRed, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key, required this.initialName});
  final String initialName;

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Chỉnh sửa hồ sơ',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(labelText: 'Tên hiển thị'),
        onSubmitted: (v) {
          final trimmed = v.trim();
          if (trimmed.isNotEmpty) Navigator.of(context).pop(trimmed);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton(
          onPressed: () {
            final trimmed = _controller.text.trim();
            if (trimmed.isNotEmpty) Navigator.of(context).pop(trimmed);
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.cgvRed,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

Future<void> _showEditProfileDialog(
  BuildContext context,
  WidgetRef ref,
  AppUser user,
) async {
  final name = await showDialog<String>(
    context: context,
    builder: (dialogContext) => EditProfileDialog(initialName: user.displayName),
  );

  if (name == null || name.isEmpty || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(authRepositoryProvider).updateProfile(displayName: name);
    ref.invalidate(currentAppUserProvider);
    if (context.mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Đã cập nhật hồ sơ.')),
      );
    }
  } catch (error) {
    if (context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}
