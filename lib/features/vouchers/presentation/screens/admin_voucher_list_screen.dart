import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../../../core/services/seed_provider.dart';
import '../../providers/voucher_providers.dart';
import '../widgets/voucher_admin_card.dart';

import '../../../../shared/widgets/admin_filter_sort_header.dart';
import '../../../../shared/widgets/app_press_scale.dart';

enum AdminVoucherSortField { code, discountValue, endDate }

extension AdminVoucherSortFieldX on AdminVoucherSortField {
  String get label => switch (this) {
        AdminVoucherSortField.code => 'Mã voucher (A-Z)',
        AdminVoucherSortField.discountValue => 'Giá trị giảm',
        AdminVoucherSortField.endDate => 'Ngày hết hạn',
      };
}

class AdminVoucherListScreen extends ConsumerStatefulWidget {
  const AdminVoucherListScreen({super.key});
  @override
  ConsumerState<AdminVoucherListScreen> createState() =>
      _AdminVoucherListScreenState();
}

class _AdminVoucherListScreenState
    extends ConsumerState<AdminVoucherListScreen> {
  String _query = '';
  AdminActiveStatusFilter _activeStatus = AdminActiveStatusFilter.all;
  AdminVoucherSortField _sortField = AdminVoucherSortField.code;

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
          AdminFilterSortHeader<AdminVoucherSortField>(
            activeStatus: _activeStatus,
            onActiveStatusChanged: (val) => setState(() => _activeStatus = val),
            activeLabel: 'Đang bật',
            hiddenLabel: 'Tạm ẩn',
            sortValue: _sortField,
            sortItems: AdminVoucherSortField.values
                .map((sf) => DropdownMenuItem(value: sf, child: Text(sf.label)))
                .toList(),
            onSortChanged: (val) {
              if (val != null) setState(() => _sortField = val);
            },
          ),
          Expanded(
            child: AppAsyncValueWidget(
              value: data,
              onRetry: () => ref.invalidate(vouchersProvider),
              data: (items) {
                final filtered = items.where((v) {
                  final matchesQuery = _query.isEmpty ||
                      v.code.toLowerCase().contains(_query) ||
                      v.description.toLowerCase().contains(_query);
                  final matchesActive = switch (_activeStatus) {
                    AdminActiveStatusFilter.all => true,
                    AdminActiveStatusFilter.active => v.isActive,
                    AdminActiveStatusFilter.hidden => !v.isActive,
                  };
                  return matchesQuery && matchesActive;
                }).toList();

                filtered.sort((a, b) {
                  return switch (_sortField) {
                    AdminVoucherSortField.code =>
                      a.code.toLowerCase().compareTo(b.code.toLowerCase()),
                    AdminVoucherSortField.discountValue =>
                      b.discountValue.compareTo(a.discountValue),
                    AdminVoucherSortField.endDate =>
                      a.endDate.compareTo(b.endDate),
                  };
                });

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
      floatingActionButton: AppPressScale(
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/admin/vouchers/new'),
          icon: const Icon(Icons.add),
          label: const Text('Thêm'),
        ),
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
