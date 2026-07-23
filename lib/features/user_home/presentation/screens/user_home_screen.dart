// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/app_press_scale.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../providers/user_catalog_provider.dart';
import '../widgets/cgv_depth_carousel.dart';
import '../widgets/movie_horizontal_section.dart';

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userCatalogProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.cgvDarkRed.withValues(alpha: 0) : null,
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0E0E0E) : Colors.white,
        elevation: 0,
        leadingWidth: 56,
        // Left: search icon
        leading: IconButton(
          onPressed: () => context.push('/user/search'),
          icon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white : const Color(0xFF121212),
          ),
        ),
        // Center: CGV logo text
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'CGV',
                style: TextStyle(
                  color: AppTheme.cgvRed,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: '*',
                style: TextStyle(
                  color: AppTheme.cgvRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        // Right: My tickets + Drawer-menu icon
        actions: [
          IconButton(
            onPressed: () => context.push('/user/tickets'),
            icon: Icon(
              Icons.confirmation_num_outlined,
              color: isDark ? Colors.white : const Color(0xFF121212),
            ),
            tooltip: 'Vé của tôi',
          ),
          IconButton(
            onPressed: () => context.push('/user/profile'),
            icon: Icon(
              Icons.person_outline_rounded,
              color: isDark ? Colors.white : const Color(0xFF121212),
            ),
            tooltip: 'Tài khoản',
          ),
        ],
      ),
      bottomNavigationBar: const UserBottomNavigation(index: 0),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.cgvRed),
        ),
        error: (_, __) => const Center(
          child: Text('Không thể tải danh mục phim.'),
        ),
        data: (catalog) {
          final bannerMovies = catalog.popular.isNotEmpty
              ? catalog.popular
              : catalog.nowShowing;

          return RefreshIndicator(
            color: AppTheme.cgvRed,
            onRefresh: () async => ref.invalidate(userCatalogProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Banner Carousel 3D ─────────────────────────
                if (bannerMovies.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: CgvDepthCarousel(movies: bannerMovies),
                    ),
                  ),

                // ── Tabs Now Showing / Coming Soon ─────────────
                if (catalog.nowShowing.isNotEmpty ||
                    catalog.comingSoon.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _CgvMovieTabs(
                      nowShowing: catalog.nowShowing,
                      comingSoon: catalog.comingSoon,
                    ),
                  ),

                // ── Popular Section ────────────────────────────
                if (catalog.popular.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: MovieHorizontalSection(
                        title: 'Phổ biến',
                        movies: catalog.popular,
                        onSeeAll: () =>
                            context.push('/user/catalog/popular'),
                      ),
                    ),
                  ),

                // ── Empty state ────────────────────────────────
                if (bannerMovies.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.movie_filter_outlined,
                              size: 60,
                              color: AppTheme.cgvRed.withValues(alpha: .5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Chưa có suất chiếu sắp tới',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Kéo xuống để làm mới.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Tab bar with Now Showing / Coming Soon – CGV style.
class _CgvMovieTabs extends StatefulWidget {
  const _CgvMovieTabs({
    required this.nowShowing,
    required this.comingSoon,
  });
  final List nowShowing;
  final List comingSoon;

  @override
  State<_CgvMovieTabs> createState() => _CgvMovieTabsState();
}

class _CgvMovieTabsState extends State<_CgvMovieTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TabBar(
            controller: _tab,
            indicator: BoxDecoration(
              color: AppTheme.cgvRed,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            dividerColor: Colors.transparent,
            splashBorderRadius: BorderRadius.circular(10),
            padding: const EdgeInsets.all(4),
            tabs: const [
              Tab(text: 'Đang chiếu'),
              Tab(text: 'Sắp chiếu'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: TabBarView(
            controller: _tab,
            children: [
              _MovieHorizontalList(movies: widget.nowShowing),
              _MovieHorizontalList(movies: widget.comingSoon),
            ],
          ),
        ),
      ],
    );
  }
}

class _MovieHorizontalList extends StatelessWidget {
  const _MovieHorizontalList({required this.movies});
  final List movies;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có phim',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: movies.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final movie = movies[i];
        return SizedBox(
          width: 130,
          child: AppPressScale(
            onTap: () => context.push('/user/movie/${movie.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        movie.posterUrl.isNotEmpty
                            ? Image.network(
                                movie.posterUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF252525),
                                  child: const Icon(
                                    Icons.movie_filter_outlined,
                                    color: Colors.white24,
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFF252525),
                                child: const Icon(
                                  Icons.movie_filter_outlined,
                                  color: Colors.white24,
                                ),
                              ),
                        if (movie.ageRating.isNotEmpty)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.cgvRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                movie.ageRating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${movie.durationMinutes} phút',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
