import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_theme.dart';
import '../../models/cinema.dart';
import '../../providers/cinema_providers.dart';

class AdminCinemaFormScreen extends ConsumerStatefulWidget {
  const AdminCinemaFormScreen({super.key, this.cinemaId});
  final String? cinemaId;

  @override
  ConsumerState<AdminCinemaFormScreen> createState() =>
      _AdminCinemaFormScreenState();
}

class _AdminCinemaFormScreenState extends ConsumerState<AdminCinemaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _imageUrl = TextEditingController();
  bool _isActive = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.cinemaId != null) {
      _loadCinema();
    } else {
      _city.text = 'TP.HCM';
    }
  }

  Future<void> _loadCinema() async {
    setState(() => _loading = true);
    final cinema = await ref
        .read(cinemaRepositoryProvider)
        .getCinema(widget.cinemaId!);
    if (cinema != null && mounted) {
      _name.text = cinema.name;
      _address.text = cinema.address;
      _city.text = cinema.city;
      _imageUrl.text = cinema.imageUrl;
      _isActive = cinema.isActive;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final repo = ref.read(cinemaRepositoryProvider);
    final draft = CinemaDraft(
      name: _name.text.trim(),
      address: _address.text.trim(),
      city: _city.text.trim(),
      imageUrl: _imageUrl.text.trim(),
      isActive: _isActive,
    );

    try {
      if (widget.cinemaId == null) {
        await repo.createCinema(draft);
      } else {
        await repo.updateCinema(widget.cinemaId!, draft);
      }
      ref.invalidate(cinemasProvider);
      ref.invalidate(activeCinemasProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.cinemaId == null
                ? 'Đã tạo cụm rạp.'
                : 'Đã cập nhật cụm rạp.'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cinemaId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa Cụm Rạp' : 'Thêm Cụm Rạp Mới'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.cgvRed))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Tên Cụm Rạp',
                      hintText: 'VD: CGV Vincom Đồng Khởi',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Vui lòng nhập tên rạp' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ',
                      hintText: 'VD: 72 Lê Thánh Tôn, Q.1',
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Vui lòng nhập địa chỉ'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _city,
                    decoration: const InputDecoration(
                      labelText: 'Thành phố',
                      hintText: 'VD: TP.HCM',
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Vui lòng nhập thành phố'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _imageUrl,
                    decoration: const InputDecoration(
                      labelText: 'URL Hình ảnh (tùy chọn)',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    title: const Text('Kích hoạt hoạt động'),
                    value: _isActive,
                    activeThumbColor: AppTheme.cgvRed,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(isEdit ? 'LƯU THAY ĐỔI' : 'TẠO CỤM RẠP'),
                  ),
                ],
              ),
            ),
    );
  }
}
