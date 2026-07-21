import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/room_repository.dart';
import '../../models/cinema_room.dart';
import '../../providers/room_providers.dart';
import '../widgets/room_form_fields.dart';
import '../widgets/seat_layout_preview.dart';

class AdminRoomFormScreen extends ConsumerStatefulWidget {
  const AdminRoomFormScreen({super.key, this.roomId});
  final String? roomId;
  @override
  ConsumerState<AdminRoomFormScreen> createState() =>
      _AdminRoomFormScreenState();
}

class _AdminRoomFormScreenState extends ConsumerState<AdminRoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _rows = TextEditingController(text: '8');
  final _seats = TextEditingController(text: '10');
  final _vip = TextEditingController(text: '0');
  final _couple = TextEditingController(text: '0');
  RoomType _type = RoomType.standard;
  bool _active = true;
  bool _loading = true;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    for (final c in [_name, _rows, _seats, _vip, _couple]) {
      c.addListener(_refresh);
    }
    _load();
  }

  Future<void> _load() async {
    if (widget.roomId != null) {
      final room = await ref
          .read(roomRepositoryProvider)
          .getRoom(widget.roomId!);
      if (room != null && mounted) {
        _name.text = room.name;
        _rows.text = '${room.rowCount}';
        _seats.text = '${room.seatsPerRow}';
        _vip.text = '${room.vipRowStart}';
        _couple.text = '${room.coupleSeatCount}';
        _type = room.roomType;
        _active = room.isActive;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in [_name, _rows, _seats, _vip, _couple]) c.dispose();
    super.dispose();
  }

  RoomDraft _draft() => RoomDraft(
    name: _name.text,
    roomType: _type,
    rowCount: int.tryParse(_rows.text) ?? 0,
    seatsPerRow: int.tryParse(_seats.text) ?? 0,
    vipRowStart: int.tryParse(_vip.text) ?? 0,
    coupleSeatCount: int.tryParse(_couple.text) ?? 0,
    isActive: _active,
  );
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final draft = _draft();
    try {
      final preview = draft.previewSeats;
      if (preview.isEmpty)
        throw const FormatException('Sơ đồ ghế không hợp lệ.');
      setState(() => _saving = true);
      final repo = ref.read(roomRepositoryProvider);
      if (widget.roomId == null) {
        await repo.createRoom(draft);
      } else {
        await repo.updateRoom(widget.roomId!, draft);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã lưu phòng.')));
        context.pop();
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final draft = _draft();
    List preview = [];
    try {
      preview = draft.previewSeats;
    } catch (_) {}
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin/rooms'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(widget.roomId == null ? 'Thêm phòng' : 'Sửa phòng'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RoomFormFields(
              nameController: _name,
              roomType: _type,
              onRoomTypeChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
              rowController: _rows,
              seatsController: _seats,
              vipController: _vip,
              coupleController: _couple,
              isActive: _active,
              onActiveChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 16),
            if (preview.isNotEmpty) SeatLayoutPreview(seats: preview.cast()),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Lưu phòng'),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
