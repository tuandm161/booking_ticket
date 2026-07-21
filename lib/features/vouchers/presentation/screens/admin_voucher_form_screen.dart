import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../data/voucher_repository.dart';
import '../../models/voucher.dart';
import '../../providers/voucher_providers.dart';

class AdminVoucherFormScreen extends ConsumerStatefulWidget {
  const AdminVoucherFormScreen({super.key, this.voucherId});
  final String? voucherId;
  @override
  ConsumerState<AdminVoucherFormScreen> createState() =>
      _AdminVoucherFormScreenState();
}

class _AdminVoucherFormScreenState
    extends ConsumerState<AdminVoucherFormScreen> {
  final _key = GlobalKey<FormState>();
  final _code = TextEditingController(),
      _desc = TextEditingController(),
      _value = TextEditingController(text: '10'),
      _min = TextEditingController(text: '0'),
      _max = TextEditingController(text: '0'),
      _limit = TextEditingController(text: '100');
  DiscountType _type = DiscountType.percentage;
  DateTime _start = DateTime.now(),
      _end = DateTime.now().add(const Duration(days: 30));
  bool _active = true, _loading = true, _saving = false;
  int _used = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_code, _desc, _value, _min, _max, _limit]) c.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.voucherId != null) {
      final item = await ref
          .read(voucherRepositoryProvider)
          .getVoucher(widget.voucherId!);
      if (item != null && mounted) {
        _code.text = item.code;
        _desc.text = item.description;
        _value.text = '${item.discountValue}';
        _min.text = '${item.minOrderValue}';
        _max.text = '${item.maxDiscount}';
        _limit.text = '${item.usageLimit}';
        _type = item.discountType;
        _start = item.startDate;
        _end = item.endDate;
        _active = item.isActive;
        _used = item.usedCount;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!(_key.currentState?.validate() ?? false)) return;
    try {
      setState(() => _saving = true);
      final d = VoucherDraft(
        code: _code.text,
        description: _desc.text,
        discountType: _type,
        discountValue: int.parse(_value.text),
        minOrderValue: int.parse(_min.text),
        maxDiscount: int.parse(_max.text),
        startDate: _start,
        endDate: _end,
        usageLimit: int.parse(_limit.text),
        usedCount: _used,
        isActive: _active,
      );
      final r = ref.read(voucherRepositoryProvider);
      if (widget.voucherId == null) {
        await r.createVoucher(d);
      } else {
        await r.updateVoucher(widget.voucherId!, d);
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
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin/vouchers'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(widget.voucherId == null ? 'Thêm voucher' : 'Sửa voucher'),
      ),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _code,
              decoration: const InputDecoration(labelText: 'Mã voucher'),
              validator: voucherCodeValidator,
            ),
            TextFormField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            DropdownButtonFormField<DiscountType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Loại giảm'),
              items: DiscountType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        t == DiscountType.percentage
                            ? 'Phần trăm'
                            : 'Số tiền cố định',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            TextFormField(
              controller: _value,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Giá trị giảm'),
              validator: positiveIntegerValidator,
            ),
            TextFormField(
              controller: _min,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Đơn tối thiểu'),
              validator: (v) =>
                  int.tryParse(v ?? '') == null ? 'Nhập số hợp lệ' : null,
            ),
            TextFormField(
              controller: _max,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giảm tối đa (0 = không giới hạn)',
              ),
              validator: (v) =>
                  int.tryParse(v ?? '') == null ? 'Nhập số hợp lệ' : null,
            ),
            TextFormField(
              controller: _limit,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giới hạn lượt dùng',
              ),
              validator: positiveIntegerValidator,
            ),
            ListTile(
              title: Text(
                'Bắt đầu: ${_start.day}/${_start.month}/${_start.year}',
              ),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _start,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _start = d);
              },
            ),
            ListTile(
              title: Text('Kết thúc: ${_end.day}/${_end.month}/${_end.year}'),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _end,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _end = d);
              },
            ),
            SwitchListTile(
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              title: const Text('Đang hoạt động'),
            ),
            if (widget.voucherId != null)
              ListTile(title: Text('Đã dùng: $_used')),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
