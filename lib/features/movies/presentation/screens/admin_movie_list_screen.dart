import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../data/movie_repository.dart';
import '../../models/movie.dart';
import '../../providers/movie_providers.dart';
import '../widgets/movie_admin_card.dart';

class AdminMovieListScreen extends ConsumerStatefulWidget {
  const AdminMovieListScreen({super.key});
  @override
  ConsumerState<AdminMovieListScreen> createState() =>
      _AdminMovieListScreenState();
}

class _AdminMovieListScreenState extends ConsumerState<AdminMovieListScreen> {
  MovieStatus? _status;
  bool _includeInactive = true;
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final movies = ref.watch(moviesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý phim'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm theo tên phim',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _status == null,
                  onSelected: (_) => setState(() => _status = null),
                ),
                const SizedBox(width: 8),
                ...MovieStatus.values.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status.label),
                      selected: _status == status,
                      onSelected: (_) => setState(() => _status = status),
                    ),
                  ),
                ),
                FilterChip(
                  label: const Text('Đang hoạt động'),
                  selected: _includeInactive,
                  onSelected: (value) =>
                      setState(() => _includeInactive = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: AppAsyncValueWidget(
              value: movies,
              onRetry: () => ref.invalidate(moviesProvider),
              data: (items) {
                final filtered = items
                    .where(
                      (movie) =>
                          (_includeInactive || movie.isActive) &&
                          (_status == null || movie.status == _status) &&
                          (_query.isEmpty ||
                              movie.title.toLowerCase().contains(_query)),
                    )
                    .toList();
                if (filtered.isEmpty)
                  return const Center(child: Text('Chưa có phim.'));
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final movie = filtered[index];
                    return MovieAdminCard(
                      movie: movie,
                      onEdit: () =>
                          context.push('/admin/movies/${movie.id}/edit'),
                      onToggleActive: () => _toggleActive(movie),
                      onToggleFeatured: () => _toggleFeatured(movie),
                      onDelete: () => _delete(movie),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNavigation(index: 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/movies/new'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm phim'),
      ),
    );
  }

  Future<void> _toggleActive(Movie movie) => ref
      .read(movieRepositoryProvider)
      .setMovieActive(movie.id, !movie.isActive);
  Future<void> _toggleFeatured(Movie movie) => ref
      .read(movieRepositoryProvider)
      .updateMovie(
        movie.id,
        MovieDraft(
          source: movie.source,
          tmdbId: movie.tmdbId,
          title: movie.title,
          overview: movie.overview,
          posterUrl: movie.posterUrl,
          backdropUrl: movie.backdropUrl,
          durationMinutes: movie.durationMinutes,
          genres: movie.genres,
          releaseDate: movie.releaseDate,
          ageRating: movie.ageRating,
          country: movie.country,
          director: movie.director,
          cast: movie.cast,
          trailerUrl: movie.trailerUrl,
          status: movie.status,
          isFeatured: !movie.isFeatured,
          isActive: movie.isActive,
        ),
      );
  Future<void> _delete(Movie movie) async {
    if (!await showConfirmDialog(
      context,
      title: 'Xóa phim?',
      message: 'Phim đã tham chiếu sẽ chỉ được ẩn.',
    ))
      return;
    try {
      await ref.read(movieRepositoryProvider).deleteMovie(movie.id);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
