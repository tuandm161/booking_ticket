import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/showtime_repository.dart';
import '../../providers/showtime_providers.dart';
import '../../../movies/models/movie.dart';
import '../../../movies/providers/movie_providers.dart';
import '../../../rooms/models/cinema_room.dart';
import '../../../rooms/providers/room_providers.dart';
import '../widgets/seat_price_preview.dart';

class AdminShowtimeFormScreen extends ConsumerStatefulWidget {
  const AdminShowtimeFormScreen({super.key, this.showtimeId});
  final String? showtimeId;
  @override
  ConsumerState<AdminShowtimeFormScreen> createState() =>
      _AdminShowtimeFormScreenState();
}

class _AdminShowtimeFormScreenState
    extends ConsumerState<AdminShowtimeFormScreen> {
  String? _movieId, _roomId;
  DateTime _start = DateTime.now().add(const Duration(hours: 1));
  final _price = TextEditingController(text: '80000');
  bool _active = true, _loading = true, _saving = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.showtimeId != null) {
      final item = await ref
          .read(showtimeRepositoryProvider)
          .getShowtime(widget.showtimeId!);
      if (item != null && mounted) {
        _movieId = item.movieId;
        _roomId = item.roomId;
        _start = item.startTime;
        _price.text = '${item.basePrice}';
        _active = item.isActive;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted)
      setState(
        () => _start = DateTime(
          date.year,
          date.month,
          date.day,
          _start.hour,
          _start.minute,
        ),
      );
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (time != null && mounted)
      setState(
        () => _start = DateTime(
          _start.year,
          _start.month,
          _start.day,
          time.hour,
          time.minute,
        ),
      );
  }

  Future<void> _save() async {
    if (_movieId == null || _roomId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hãy chọn phim và phòng.')));
      return;
    }
    final price = int.tryParse(_price.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giá vé phải lớn hơn 0.')));
      return;
    }
    try {
      setState(() => _saving = true);
      final draft = ShowtimeDraft(
        movieId: _movieId!,
        roomId: _roomId!,
        startTime: _start,
        basePrice: price,
        isActive: _active,
      );
      final repo = ref.read(showtimeRepositoryProvider);
      if (widget.showtimeId == null) {
        await repo.createShowtime(draft);
      } else {
        await repo.updateShowtime(widget.showtimeId!, draft);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã lưu suất chiếu.')));
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
    final movies = ref.watch(moviesProvider);
    final rooms = ref.watch(roomsProvider);
    if (movies.hasError || rooms.hasError)
      return Scaffold(
        appBar: AppBar(title: const Text('Suất chiếu')),
        body: Center(child: Text('${movies.error ?? rooms.error}')),
      );
    if (movies.isLoading ||
        rooms.isLoading ||
        movies.value == null ||
        rooms.value == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showtimeId == null ? 'Thêm suất chiếu' : 'Sửa suất chiếu',
        ),
      ),
      body: _form(context, movies.value!, rooms.value!),
    );
  }

  Widget _form(
    BuildContext context,
    List<Movie> movieItems,
    List<CinemaRoom> roomItems,
  ) {
    final activeMovies = movieItems.where((movie) => movie.isActive).toList();
    final activeRooms = roomItems.where((room) => room.isActive).toList();
    final duration =
        activeMovies
            .where((movie) => movie.id == _movieId)
            .map((movie) => movie.durationMinutes)
            .firstOrNull ??
        0;
    final end = _start.add(
      Duration(minutes: duration) + const Duration(minutes: 15),
    );
    final parsedPrice = int.tryParse(_price.text);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: activeMovies.any((movie) => movie.id == _movieId)
              ? _movieId
              : null,
          decoration: const InputDecoration(labelText: 'Phim'),
          items: activeMovies
              .map(
                (movie) => DropdownMenuItem(
                  value: movie.id,
                  child: Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _movieId = value),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: activeRooms.any((room) => room.id == _roomId)
              ? _roomId
              : null,
          decoration: const InputDecoration(labelText: 'Phòng'),
          items: activeRooms
              .map(
                (room) =>
                    DropdownMenuItem(value: room.id, child: Text(room.name)),
              )
              .toList(),
          onChanged: (value) => setState(() => _roomId = value),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _pickDate,
                child: Text('${_start.day}/${_start.month}/${_start.year}'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: _pickTime,
                child: Text(
                  '${_start.hour.toString().padLeft(2, '0')}:${_start.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Giờ kết thúc dự kiến: ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _price,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Giá vé cơ bản (VND)'),
          onChanged: (_) => setState(() {}),
        ),
        if (parsedPrice != null) SeatPricePreview(basePrice: parsedPrice),
        SwitchListTile(
          value: _active,
          onChanged: (value) => setState(() => _active = value),
          title: const Text('Đang hoạt động'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const CircularProgressIndicator()
              : const Text('Lưu suất chiếu'),
        ),
      ],
    );
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
