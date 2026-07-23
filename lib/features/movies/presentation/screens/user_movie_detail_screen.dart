// ignore_for_file: curly_braces_in_flow_control_structures, unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../shared/widgets/app_press_scale.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/services/firebase_providers.dart';
import '../../../showtimes/providers/user_showtime_providers.dart';
import '../../../user_home/providers/user_catalog_provider.dart';
import '../../data/movie_repository.dart';
import '../../models/movie.dart';
import '../widgets/trailer_dialog.dart';

class UserMovieDetailScreen extends ConsumerWidget {
  const UserMovieDetailScreen({super.key, required this.movieId});
  final String movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Movie?>(
      future: MovieRepository(
              ref.watch(firestoreProvider))
          .getMovie(movieId),
      builder: (context, snap) {
        ref.watch(userCatalogProvider);
        if (!snap.hasData)
          return const Scaffold(
              body: Center(
                  child: CircularProgressIndicator(color: AppTheme.cgvRed)));
        final movie = snap.data;
        if (movie == null)
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy phim.')),
          );

        final shows = ref.watch(userShowtimesProvider(movieId));
        final hasShows = shows.maybeWhen(
          data: (items) => items.isNotEmpty,
          orElse: () => false,
        );

        return Scaffold(
          body: _MovieDetailBody(movie: movie),
          bottomNavigationBar: _StickyBookNowBar(
            movieId: movieId,
            hasShows: hasShows,
            showsLoading: shows.isLoading,
          ),
        );
      },
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _MovieDetailBody extends StatefulWidget {
  const _MovieDetailBody({required this.movie});
  final Movie movie;

  @override
  State<_MovieDetailBody> createState() => _MovieDetailBodyState();
}

class _MovieDetailBodyState extends State<_MovieDetailBody> {
  bool _expandOverview = false;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // ── SliverAppBar: Backdrop Hero ────────────────────────
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor:
              isDark ? const Color(0xFF0E0E0E) : Colors.white,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: const Text(
            'Chi tiết phim',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Backdrop
                CachedNetworkImage(
                  imageUrl: movie.backdropUrl.isNotEmpty
                      ? movie.backdropUrl
                      : movie.posterUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                // Gradient top → black
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x55000000),
                        Color(0xFF000000),
                      ],
                      stops: [0.0, 1.0],
                    ),
                  ),
                ),
                // Play button (trailer)
                if (movie.trailerUrl.isNotEmpty)
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final videoId =
                            YoutubePlayerController.convertUrlToId(movie.trailerUrl);
                        if (videoId != null && videoId.isNotEmpty) {
                          TrailerDialog.show(context,
                              videoId: videoId, movieTitle: movie.title);
                        } else {
                          final uri = Uri.tryParse(movie.trailerUrl);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Không thể mở video trailer.')),
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .25),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: .7),
                              width: 2),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                // Poster + Info row - bottom of backdrop
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Poster thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: movie.posterUrl,
                          width: 90,
                          height: 130,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 90,
                            height: 130,
                            color: const Color(0xFF2A2A2A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Title + meta
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              movie.title.toUpperCase(),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Release date chip
                            if (movie.releaseDate != null)
                              _InfoChip(
                                icon: Icons.calendar_today_outlined,
                                label: DateFormat('dd/MM/yyyy')
                                    .format(movie.releaseDate!),
                              ),
                            const SizedBox(height: 5),
                            // Duration chip
                            _InfoChip(
                              icon: Icons.timer_outlined,
                              label:
                                  '${movie.durationMinutes ~/ 60}h ${movie.durationMinutes % 60}min',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Movie Details ──────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: isDark ? const Color(0xFF0E0E0E) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview
                  if (movie.overview.isNotEmpty) ...[
                    _buildSynopsis(context, movie),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                  ],

                  // Info table
                  _buildInfoTable(context, movie),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSynopsis(BuildContext context, Movie movie) {
    final text = movie.overview;
    final isLong = text.length > 150;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _expandOverview || !isLong ? text : '${text.substring(0, 150)}...',
          style: const TextStyle(fontSize: 14, height: 1.6),
        ),
        if (isLong) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _expandOverview = !_expandOverview),
            child: Text(
              _expandOverview ? 'Rút gọn' : 'Xem thêm',
              style: const TextStyle(
                color: AppTheme.cgvRed,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoTable(BuildContext context, Movie movie) {
    final rows = <_InfoRow>[];
    if (movie.ageRating.isNotEmpty) {
      rows.add(_InfoRow(label: 'Phân loại', value: movie.ageRating));
    }
    if (movie.genres.isNotEmpty) {
      rows.add(_InfoRow(label: 'Thể loại', value: movie.genres.join(', ')));
    }
    if (movie.director.isNotEmpty) {
      rows.add(_InfoRow(label: 'Đạo diễn', value: movie.director));
    }
    if (movie.cast.isNotEmpty) {
      rows.add(_InfoRow(label: 'Diễn viên', value: movie.cast.join(', ')));
    }
    if (movie.country.isNotEmpty) {
      rows.add(_InfoRow(label: 'Ngôn ngữ', value: movie.country));
    }

    return Column(
      children: rows
          .map(
            (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      r.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white38),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky Bottom Bar ─────────────────────────────────────────────────────────

class _StickyBookNowBar extends StatelessWidget {
  const _StickyBookNowBar({
    required this.movieId,
    required this.hasShows,
    required this.showsLoading,
  });
  final String movieId;
  final bool hasShows;
  final bool showsLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: AppPressScale(
        enabled: hasShows,
        child: FilledButton(
          onPressed: hasShows
              ? () => context.push('/user/showtimes/$movieId')
              : showsLoading
                  ? null
                  : null,
          style: FilledButton.styleFrom(
            backgroundColor: hasShows ? AppTheme.cgvRed : Colors.grey,
          ),
          child: showsLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(
                  hasShows ? 'ĐẶT VÉ NGAY' : 'Chưa có suất chiếu',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
