import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../providers/product_providers.dart';
import '../widgets/product_admin_card.dart';

class AdminProductListScreen extends ConsumerWidget {
  const AdminProductListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(productsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm bỏng nước')),
      body: AppAsyncValueWidget(
        value: data,
        onRetry: () => ref.invalidate(productsProvider),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final p = items[i];
              return ProductAdminCard(
                product: p,
                onEdit: () => context.push('/admin/products/${p.id}/edit'),
                onToggle: () => ref
                    .read(productRepositoryProvider)
                    .setAvailable(p.id, !p.isAvailable),
                onDelete: () => _delete(context, ref, p.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/products/new'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
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
