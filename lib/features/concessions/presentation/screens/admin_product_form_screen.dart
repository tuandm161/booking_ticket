import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../data/product_repository.dart';
import '../../models/product.dart';
import '../../providers/product_providers.dart';

class AdminProductFormScreen extends ConsumerStatefulWidget {
  const AdminProductFormScreen({super.key, this.productId});
  final String? productId;
  @override
  ConsumerState<AdminProductFormScreen> createState() =>
      _AdminProductFormScreenState();
}

class _AdminProductFormScreenState
    extends ConsumerState<AdminProductFormScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _desc = TextEditingController(),
      _image = TextEditingController(),
      _price = TextEditingController();
  ProductCategory _category = ProductCategory.popcorn;
  bool _available = true, _loading = true, _saving = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _image, _price]) c.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.productId != null) {
      final p = await ref
          .read(productRepositoryProvider)
          .getProduct(widget.productId!);
      if (p != null && mounted) {
        _name.text = p.name;
        _desc.text = p.description;
        _image.text = p.imageUrl;
        _price.text = '${p.price}';
        _category = p.category;
        _available = p.isAvailable;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!(_key.currentState?.validate() ?? false)) return;
    try {
      setState(() => _saving = true);
      final d = ProductDraft(
        name: _name.text,
        category: _category,
        description: _desc.text,
        imageUrl: _image.text,
        price: int.parse(_price.text),
        isAvailable: _available,
      );
      final r = ref.read(productRepositoryProvider);
      if (widget.productId == null)
        await r.createProduct(d);
      else
        await r.updateProduct(widget.productId!, d);
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
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin/products'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          widget.productId == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm',
        ),
      ),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              validator: (v) => requiredText(v, field: 'Tên sản phẩm'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ProductCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Danh mục'),
              items: ProductCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _image,
              decoration: const InputDecoration(labelText: 'Image URL'),
              validator: urlValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Giá'),
              validator: positiveIntegerValidator,
            ),
            SwitchListTile(
              value: _available,
              onChanged: (v) => setState(() => _available = v),
              title: const Text('Đang bán'),
            ),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
