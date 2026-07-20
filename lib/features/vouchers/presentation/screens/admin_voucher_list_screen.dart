import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../providers/voucher_providers.dart';
import '../widgets/voucher_admin_card.dart';

class AdminVoucherListScreen extends ConsumerWidget {
  const AdminVoucherListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(vouchersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Voucher')),
      body: AppAsyncValueWidget(
        value: data,
        onRetry: () => ref.invalidate(vouchersProvider),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có voucher.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final v = items[i];
              return VoucherAdminCard(
                voucher: v,
                onEdit: () => context.push('/admin/vouchers/${v.id}/edit'),
                onToggle: () => ref
                    .read(voucherRepositoryProvider)
                    .setActive(v.id, !v.isActive),
                onDelete: () => _delete(context, ref, v.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/vouchers/new'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String id) async {
    if (!await showConfirmDialog(
      context,
      title: 'Xóa voucher?',
      message: 'Voucher đã dùng sẽ không thể xóa.',
    )) {
      return;
    }
    try {
      await ref.read(voucherRepositoryProvider).deleteVoucher(id);
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
