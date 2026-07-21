import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../data/combo_repository.dart';
import '../../models/combo.dart';
import '../../providers/combo_providers.dart';
import '../../providers/product_providers.dart';
import '../widgets/combo_item_editor.dart';

class AdminComboFormScreen extends ConsumerStatefulWidget {
  const AdminComboFormScreen({super.key, this.comboId});
  final String? comboId;
  @override
  ConsumerState<AdminComboFormScreen> createState() =>
      _AdminComboFormScreenState();
}

class _AdminComboFormScreenState extends ConsumerState<AdminComboFormScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _desc = TextEditingController(),
      _image = TextEditingController(),
      _price = TextEditingController();
  List<ComboItem> _items = [];
  bool _available = true, _loading = true, _saving = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _image, _price]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.comboId != null) {
      final c = await ref
          .read(comboRepositoryProvider)
          .getCombo(widget.comboId!);
      if (c != null && mounted) {
        _name.text = c.name;
        _desc.text = c.description;
        _image.text = c.imageUrl;
        _price.text = '${c.price}';
        _items = c.items;
        _available = c.isAvailable;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!(_key.currentState?.validate() ?? false) || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Combo cần ít nhất một sản phẩm.')),
      );
      return;
    }
    try {
      setState(() => _saving = true);
      final d = ComboDraft(
        name: _name.text,
        description: _desc.text,
        imageUrl: _image.text,
        price: int.parse(_price.text),
        items: _items,
        isAvailable: _available,
      );
      final r = ref.read(comboRepositoryProvider);
      if (widget.comboId == null) {
        await r.createCombo(d);
      } else {
        await r.updateCombo(widget.comboId!, d);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final products = ref.watch(productsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin/combos'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(widget.comboId == null ? 'Thêm combo' : 'Sửa combo'),
      ),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text(e.toString())),
        data: (items) {
          return Form(
            key: _key,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Tên combo'),
                  validator: (v) => requiredText(v, field: 'Tên combo'),
                ),
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                ),
                TextFormField(
                  controller: _image,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: urlValidator,
                ),
                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giá combo'),
                  validator: positiveIntegerValidator,
                ),
                ComboItemEditor(
                  items: _items,
                  products: items.where((p) => p.isAvailable).toList(),
                  onChanged: (v) => setState(() => _items = v),
                ),
                SwitchListTile(
                  value: _available,
                  onChanged: (v) => setState(() => _available = v),
                  title: const Text('Đang bán'),
                ),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('Lưu'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
