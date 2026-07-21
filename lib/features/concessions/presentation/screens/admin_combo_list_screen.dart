import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../../../core/services/seed_provider.dart';
import '../../providers/combo_providers.dart';

class AdminComboListScreen extends ConsumerStatefulWidget {
  const AdminComboListScreen({super.key});
  @override
  ConsumerState<AdminComboListScreen> createState() =>
      _AdminComboListScreenState();
}

class _AdminComboListScreenState extends ConsumerState<AdminComboListScreen> {
  String _query = '';
  bool _onlyAvailable = false;

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Chỉ combo đang bán'),
                selected: _onlyAvailable,
                onSelected: (value) => setState(() => _onlyAvailable = value),
              ),
            ),
          ),
          Expanded(
            child: AppAsyncValueWidget(
              value: data,
              onRetry: () => ref.invalidate(combosProvider),
              data: (items) {
                final filtered = items
                    .where(
                      (c) =>
                          (_query.isEmpty ||
                              c.name.toLowerCase().contains(_query)) &&
                          (!_onlyAvailable || c.isAvailable),
                    )
                    .toList();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/combos/new'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
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
