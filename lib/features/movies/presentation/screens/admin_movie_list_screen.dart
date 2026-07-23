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
import '../widgets/movie_status_chip.dart';

import '../../../../shared/widgets/admin_filter_sort_header.dart';
import '../../../../shared/widgets/app_press_scale.dart';

enum AdminMovieSortField { createdAt, releaseDate, title, bookingCount }

extension AdminMovieSortFieldX on AdminMovieSortField {
  String get label => switch (this) {
        AdminMovieSortField.createdAt => 'Mới thêm (Ngày tạo)',
        AdminMovieSortField.releaseDate => 'Ngày phát hành',
        AdminMovieSortField.title => 'Tên phim (A-Z)',
        AdminMovieSortField.bookingCount => 'Lượt đặt vé',
      };
}

class AdminMovieListScreen extends ConsumerStatefulWidget {
  const AdminMovieListScreen({super.key});
  @override
  ConsumerState<AdminMovieListScreen> createState() =>
      _AdminMovieListScreenState();
}

class _AdminMovieListScreenState extends ConsumerState<AdminMovieListScreen> {
  MovieStatus? _status;
  AdminActiveStatusFilter _activeStatus = AdminActiveStatusFilter.all;
  AdminMovieSortField _sortField = AdminMovieSortField.createdAt;
  DateTime? _createdDateFilter;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final movies = ref.watch(moviesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          AdminFilterSortHeader<AdminMovieSortField>(
            activeStatus: _activeStatus,
            onActiveStatusChanged: (val) => setState(() => _activeStatus = val),
            sortValue: _sortField,
            sortItems: AdminMovieSortField.values
                .map((sf) => DropdownMenuItem(value: sf, child: Text(sf.label)))
                .toList(),
            onSortChanged: (val) {
              if (val != null) setState(() => _sortField = val);
            },
            extraFilterWidget: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // ── Date Added Filter Chip ───────────────────
                  if (_createdDateFilter == null)
                    ActionChip(
                      avatar: Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: isDark ? Colors.white70 : const Color(0xFF555555),
                      ),
                      label: const Text('Ngày thêm'),
                      backgroundColor:
                          isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF212121),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _createdDateFilter = date);
                      },
                    )
                  else
                    InputChip(
                      avatar: const Icon(
                        Icons.event_available_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Thêm: ${_createdDateFilter!.day}/${_createdDateFilter!.month}/${_createdDateFilter!.year}',
                      ),
                      selected: true,
                      selectedColor: const Color(0xFFD7262D),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      deleteIconColor: Colors.white,
                      onDeleted: () => setState(() => _createdDateFilter = null),
                    ),
                  const SizedBox(width: 8),

                  // ── Status Chips ─────────────────────────────
                  ChoiceChip(
                    label: const Text('Tất cả trạng thái'),
                    selected: _status == null,
                    selectedColor: const Color(0xFFD7262D),
                    backgroundColor:
                        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE),
                    labelStyle: TextStyle(
                      color: _status == null
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF212121)),
                      fontWeight:
                          _status == null ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _status = null),
                  ),
                  const SizedBox(width: 8),
                  ...MovieStatus.values.map((status) {
                    final isSel = _status == status;
                    final (textColor, bgColor) =
                        MovieStatusChip.colorsOf(status);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          status.label,
                          style: TextStyle(
                            color: isSel
                                ? textColor
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF212121)),
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: bgColor,
                        backgroundColor: isDark
                            ? const Color(0xFF2C2C2C)
                            : const Color(0xFFEEEEEE),
                        onSelected: (_) => setState(() => _status = status),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Expanded(
            child: AppAsyncValueWidget(
              value: movies,
              onRetry: () => ref.invalidate(moviesProvider),
              data: (items) {
                final filtered = items.where((movie) {
                  final matchesActive = switch (_activeStatus) {
                    AdminActiveStatusFilter.all => true,
                    AdminActiveStatusFilter.active => movie.isActive,
                    AdminActiveStatusFilter.hidden => !movie.isActive,
                  };
                  final matchesMovieStatus =
                      _status == null || movie.status == _status;
                  final matchesCreatedDate = _createdDateFilter == null ||
                      (movie.createdAt != null &&
                          movie.createdAt!.year == _createdDateFilter!.year &&
                          movie.createdAt!.month == _createdDateFilter!.month &&
                          movie.createdAt!.day == _createdDateFilter!.day);
                  final matchesQuery = _query.isEmpty ||
                      movie.title.toLowerCase().contains(_query);
                  return matchesActive &&
                      matchesMovieStatus &&
                      matchesCreatedDate &&
                      matchesQuery;
                }).toList();

                filtered.sort((a, b) {
                  return switch (_sortField) {
                    AdminMovieSortField.createdAt =>
                      (b.createdAt ?? DateTime(0))
                          .compareTo(a.createdAt ?? DateTime(0)),
                    AdminMovieSortField.releaseDate =>
                      (b.releaseDate ?? DateTime(0))
                          .compareTo(a.releaseDate ?? DateTime(0)),
                    AdminMovieSortField.title => a.title
                        .toLowerCase()
                        .compareTo(b.title.toLowerCase()),
                    AdminMovieSortField.bookingCount =>
                      b.bookingCount.compareTo(a.bookingCount),
                  };
                });

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
      floatingActionButton: AppPressScale(
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/admin/movies/new'),
          icon: const Icon(Icons.add),
          label: const Text('Thêm phim'),
        ),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
