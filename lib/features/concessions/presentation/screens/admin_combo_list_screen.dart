import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../../../core/services/seed_provider.dart';
import '../../providers/combo_providers.dart';

import '../../../../shared/widgets/admin_filter_sort_header.dart';
import '../../../../shared/widgets/app_press_scale.dart';

enum AdminComboSortField { name, price, createdAt }

extension AdminComboSortFieldX on AdminComboSortField {
  String get label => switch (this) {
        AdminComboSortField.name => 'Tên combo (A-Z)',
        AdminComboSortField.price => 'Giá tiền',
        AdminComboSortField.createdAt => 'Ngày tạo',
      };
}

class AdminComboListScreen extends ConsumerStatefulWidget {
  const AdminComboListScreen({super.key});
  @override
  ConsumerState<AdminComboListScreen> createState() =>
      _AdminComboListScreenState();
}

class _AdminComboListScreenState extends ConsumerState<AdminComboListScreen> {
  String _query = '';
  AdminActiveStatusFilter _activeStatus = AdminActiveStatusFilter.all;
  AdminComboSortField _sortField = AdminComboSortField.name;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(combosProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Combo'),
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
                hintText: 'Tìm combo...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          AdminFilterSortHeader<AdminComboSortField>(
            activeStatus: _activeStatus,
            onActiveStatusChanged: (val) => setState(() => _activeStatus = val),
            activeLabel: 'Đang bán',
            hiddenLabel: 'Tạm ẩn',
            sortValue: _sortField,
            sortItems: AdminComboSortField.values
                .map((sf) => DropdownMenuItem(value: sf, child: Text(sf.label)))
                .toList(),
            onSortChanged: (val) {
              if (val != null) setState(() => _sortField = val);
            },
          ),
          Expanded(
            child: AppAsyncValueWidget(
              value: data,
              onRetry: () => ref.invalidate(combosProvider),
              data: (items) {
                final filtered = items.where((c) {
                  final matchesQuery = _query.isEmpty ||
                      c.name.toLowerCase().contains(_query);
                  final matchesActive = switch (_activeStatus) {
                    AdminActiveStatusFilter.all => true,
                    AdminActiveStatusFilter.active => c.isAvailable,
                    AdminActiveStatusFilter.hidden => !c.isAvailable,
                  };
                  return matchesQuery && matchesActive;
                }).toList();

                filtered.sort((a, b) {
                  return switch (_sortField) {
                    AdminComboSortField.name =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                    AdminComboSortField.price => b.price.compareTo(a.price),
                    AdminComboSortField.createdAt =>
                      (b.createdAt ?? DateTime(0))
                          .compareTo(a.createdAt ?? DateTime(0)),
                  };
                });

                if (filtered.isEmpty) {
                  return const Center(child: Text('Không có combo phù hợp.'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_activity_rounded),
                        title: Text(c.name),
                        subtitle: Text(
                          '${c.items.length} sản phẩm • ${c.price}₫',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') {
                              context.push('/admin/combos/${c.id}/edit');
                            } else if (v == 'toggle') {
                              ref
                                  .read(comboRepositoryProvider)
                                  .setAvailable(c.id, !c.isAvailable);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Sửa'),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Text(c.isAvailable ? 'Ẩn' : 'Hiện'),
                            ),
                          ],
                        ),
                      ),
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
          onPressed: () => context.push('/admin/combos/new'),
          icon: const Icon(Icons.add),
          label: const Text('Thêm'),
        ),
      ),
    );
  }

  Future<void> _seed() async {
    try {
      final result = await ref.read(seedServiceProvider).seedDefaultCombos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.skipped
                ? 'Đã có combo, không tạo trùng.'
                : 'Đã tạo ${result.createdCount} combo mẫu.',
          ),
        ),
      );
      ref.invalidate(combosProvider);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}
