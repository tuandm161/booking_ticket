import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../providers/combo_providers.dart';

class AdminComboListScreen extends ConsumerWidget {
  const AdminComboListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(combosProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Combo')),
      body: AppAsyncValueWidget(
        value: data,
        onRetry: () => ref.invalidate(combosProvider),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có combo.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final c = items[i];
              return Card(
                child: ListTile(
                  title: Text(c.name),
                  subtitle: Text('${c.items.length} sản phẩm • ${c.price}₫'),
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
                      const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                      const PopupMenuItem(value: 'toggle', child: Text('Ẩn')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/combos/new'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
  }
}
