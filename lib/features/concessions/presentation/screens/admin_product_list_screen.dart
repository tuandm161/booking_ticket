import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../../../core/services/seed_provider.dart';
import '../../models/product.dart';
import '../../providers/product_providers.dart';
import '../widgets/product_admin_card.dart';

class AdminProductListScreen extends ConsumerStatefulWidget {
  const AdminProductListScreen({super.key});
  @override
  ConsumerState<AdminProductListScreen> createState() =>
      _AdminProductListScreenState();
}

class _AdminProductListScreenState
    extends ConsumerState<AdminProductListScreen> {
  String _query = '';
  ProductCategory? _category;
  bool _onlyAvailable = false;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(productsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm bỏng nước'),
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
                hintText: 'Tìm bỏng, nước, snack...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                const SizedBox(width: 8),
                ...ProductCategory.values.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.label),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                  ),
                ),
                FilterChip(
                  label: const Text('Đang bán'),
                  selected: _onlyAvailable,
                  onSelected: (value) => setState(() => _onlyAvailable = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: AppAsyncValueWidget(
              value: data,
              onRetry: () => ref.invalidate(productsProvider),
              data: (items) {
                final filtered = items
                    .where(
                      (p) =>
                          (_query.isEmpty ||
                              p.name.toLowerCase().contains(_query)) &&
                          (_category == null || p.category == _category) &&
                          (!_onlyAvailable || p.isAvailable),
                    )
                    .toList();
                if (filtered.isEmpty)
                  return const Center(
                    child: Text('Không có sản phẩm phù hợp.'),
                  );
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    return ProductAdminCard(
                      product: p,
                      onEdit: () =>
                          context.push('/admin/products/${p.id}/edit'),
                      onToggle: () => ref
                          .read(productRepositoryProvider)
                          .setAvailable(p.id, !p.isAvailable),
                      onDelete: () => _delete(context, ref, p.id),
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
        onPressed: () => context.push('/admin/products/new'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
  }

  Future<void> _seed() async {
    try {
      final result = await ref.read(seedServiceProvider).seedDefaultProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.skipped
                ? 'Đã có sản phẩm, không tạo trùng.'
                : 'Đã tạo ${result.createdCount} sản phẩm mẫu.',
          ),
        ),
      );
      ref.invalidate(productsProvider);
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
      title: 'Xóa sản phẩm?',
      message: 'Sản phẩm đã dùng sẽ không thể xóa cứng.',
    )) {
      return;
    }
    try {
      await ref.read(productRepositoryProvider).deleteProduct(id);
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
