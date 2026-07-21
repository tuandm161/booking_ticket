import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../../../core/services/seed_provider.dart';
import '../../providers/voucher_providers.dart';
import '../widgets/voucher_admin_card.dart';

class AdminVoucherListScreen extends ConsumerStatefulWidget {
  const AdminVoucherListScreen({super.key});
  @override
  ConsumerState<AdminVoucherListScreen> createState() =>
      _AdminVoucherListScreenState();
}

class _AdminVoucherListScreenState
    extends ConsumerState<AdminVoucherListScreen> {
  String _query = '';
  bool _onlyActive = false;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(vouchersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher'),
        actions: [
          IconButton(
            onPressed: _seed,
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'Tạo dữ liệu mẫu',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm mã voucher...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Chỉ voucher đang bật'),
                selected: _onlyActive,
                onSelected: (value) => setState(() => _onlyActive = value),
              ),
            ),
          ),
          Expanded(
            child: AppAsyncValueWidget(
              value: data,
              onRetry: () => ref.invalidate(vouchersProvider),
              data: (items) {
                final filtered = items
                    .where(
                      (v) =>
                          (_query.isEmpty ||
                              v.code.toLowerCase().contains(_query) ||
                              v.description.toLowerCase().contains(_query)) &&
                          (!_onlyActive || v.isActive),
                    )
                    .toList();
                if (filtered.isEmpty)
                  return const Center(child: Text('Không có voucher phù hợp.'));
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final v = filtered[i];
                    return VoucherAdminCard(
                      voucher: v,
                      onEdit: () =>
                          context.push('/admin/vouchers/${v.id}/edit'),
                      onToggle: () => ref
                          .read(voucherRepositoryProvider)
                          .setActive(v.id, !v.isActive),
                      onDelete: () => _delete(context, ref, v.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNavigation(index: 4),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/vouchers/new'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
  }

  Future<void> _seed() async {
    try {
      final result = await ref.read(seedServiceProvider).seedDefaultVouchers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.skipped
                ? 'Đã có voucher, không tạo trùng.'
                : 'Đã tạo ${result.createdCount} voucher mẫu.',
          ),
        ),
      );
      ref.invalidate(vouchersProvider);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
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
