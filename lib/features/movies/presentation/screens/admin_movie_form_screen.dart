import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../data/movie_repository.dart';
import '../../models/movie.dart';
import '../../providers/movie_providers.dart';
import '../widgets/genre_input.dart';
import 'tmdb_search_screen.dart';

class AdminMovieFormScreen extends ConsumerStatefulWidget {
  const AdminMovieFormScreen({super.key, this.movieId});
  final String? movieId;
  @override
  ConsumerState<AdminMovieFormScreen> createState() =>
      _AdminMovieFormScreenState();
}

class _AdminMovieFormScreenState extends ConsumerState<AdminMovieFormScreen> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController(),
      _overview = TextEditingController(),
      _poster = TextEditingController(),
      _backdrop = TextEditingController(),
      _duration = TextEditingController(text: '120'),
      _age = TextEditingController(),
      _country = TextEditingController(),
      _director = TextEditingController(),
      _cast = TextEditingController(),
      _trailer = TextEditingController();
  List<String> _genres = [];
  MovieSource _source = MovieSource.manual;
  int? _tmdbId;
  DateTime? _release;
  MovieStatus _status = MovieStatus.comingSoon;
  bool _featured = false, _active = true, _loading = true, _saving = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _overview,
      _poster,
      _backdrop,
      _duration,
      _age,
      _country,
      _director,
      _cast,
      _trailer,
    ])
      c.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.movieId != null) {
      final movie = await ref
          .read(movieRepositoryProvider)
          .getMovie(widget.movieId!);
      if (movie != null && mounted) {
        _source = movie.source;
        _tmdbId = movie.tmdbId;
        _title.text = movie.title;
        _overview.text = movie.overview;
        _poster.text = movie.posterUrl;
        _backdrop.text = movie.backdropUrl;
        _duration.text = '${movie.durationMinutes}';
        _age.text = movie.ageRating;
        _country.text = movie.country;
        _director.text = movie.director;
        _cast.text = movie.cast.join(', ');
        _trailer.text = movie.trailerUrl;
        _genres = movie.genres;
        _release = movie.releaseDate;
        _status = movie.status;
        _featured = movie.isFeatured;
        _active = movie.isActive;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  MovieDraft _draft() => MovieDraft(
    source: _source,
    tmdbId: _tmdbId,
    title: _title.text,
    overview: _overview.text,
    posterUrl: _poster.text,
    backdropUrl: _backdrop.text,
    durationMinutes: int.tryParse(_duration.text) ?? 0,
    genres: _genres,
    releaseDate: _release,
    ageRating: _age.text,
    country: _country.text,
    director: _director.text,
    cast: _cast.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(10)
        .toList(),
    trailerUrl: _trailer.text,
    status: _status,
    isFeatured: _featured,
    isActive: _active,
  );
  Future<void> _save() async {
    if (!(_key.currentState?.validate() ?? false)) return;
    try {
      setState(() => _saving = true);
      final repo = ref.read(movieRepositoryProvider);
      if (widget.movieId == null)
        await repo.createMovie(_draft());
      else
        await repo.updateMovie(widget.movieId!, _draft());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã lưu phim.')));
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

  Future<void> _tmdb() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TmdbSearchScreen(
        onSelected: (summary) async {
          Navigator.pop(context);
          try {
            final detail = await ref
                .read(tmdbApiProvider)
                .getMovieDetails(summary.id);
            if (!mounted) return;
            setState(() {
              _source = MovieSource.tmdb;
              _tmdbId = detail.id;
              _title.text = detail.title;
              _overview.text = detail.overview;
              _poster.text = detail.posterUrl ?? '';
              _backdrop.text = detail.backdropPath == null
                  ? ''
                  : 'https://image.tmdb.org/t/p/w1280${detail.backdropPath}';
              _duration.text = '${detail.runtime ?? 120}';
              _genres = detail.genres;
              _country.text = detail.country;
              _director.text = detail.director;
              _cast.text = detail.cast.join(', ');
              _trailer.text = detail.trailerUrl ?? '';
              _release = DateTime.tryParse(detail.releaseDate ?? '');
            });
          } catch (error) {
            if (mounted)
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error.toString())));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Quay lại danh sách phim',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin/movies'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(widget.movieId == null ? 'Thêm phim' : 'Sửa phim'),
      ),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_source == MovieSource.tmdb)
              const Chip(label: Text('Nguồn TMDB')),
            FilledButton.icon(
              onPressed: _tmdb,
              icon: const Icon(Icons.search),
              label: const Text('Tìm trên TMDB'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Tên phim'),
              validator: (v) => requiredText(v, field: 'Tên phim'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _overview,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              validator: (v) => requiredText(v, field: 'Mô tả'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _poster,
              decoration: const InputDecoration(labelText: 'Poster URL'),
              validator: urlValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _backdrop,
              decoration: const InputDecoration(labelText: 'Backdrop URL'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _duration,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Thời lượng (phút)'),
              validator: positiveIntegerValidator,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _release ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _release = date);
              },
              child: Text(
                _release == null
                    ? 'Chọn ngày phát hành'
                    : 'Ngày phát hành: ${_release!.day}/${_release!.month}/${_release!.year}',
              ),
            ),
            const SizedBox(height: 12),
            GenreInput(
              genres: _genres,
              onChanged: (value) => setState(() => _genres = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _age,
              decoration: const InputDecoration(
                labelText: 'Độ tuổi (T13, T16...)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _country,
              decoration: const InputDecoration(labelText: 'Quốc gia'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _director,
              decoration: const InputDecoration(labelText: 'Đạo diễn'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cast,
              decoration: const InputDecoration(
                labelText: 'Diễn viên (phân tách bằng dấu phẩy)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _trailer,
              decoration: const InputDecoration(labelText: 'Trailer URL'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? null
                  : urlValidator(value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MovieStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Trạng thái'),
              items: MovieStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            SwitchListTile(
              value: _featured,
              onChanged: (v) => setState(() => _featured = v),
              title: const Text('Phim nổi bật'),
            ),
            SwitchListTile(
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              title: const Text('Đang hoạt động'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Lưu phim'),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
