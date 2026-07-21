// ignore_for_file: curly_braces_in_flow_control_structures, unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../../../shared/widgets/cinema_decor.dart';
import '../../providers/user_catalog_provider.dart';
import '../widgets/movie_horizontal_section.dart';
import '../widgets/featured_movie_banner.dart';

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userCatalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.local_movies_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            const Text('CineBook'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/user/search'),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Tìm phim',
          ),
        ],
      ),
      bottomNavigationBar: const UserBottomNavigation(index: 0),
      body: CinemaBackdrop(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              const Center(child: Text('Không thể tải danh mục phim.')),
          data: (catalog) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(userCatalogProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 18),
              children: [
                CinemaHero(
                  eyebrow: 'Rạp chiếu phim của bạn',
                  title: catalog.popular.isEmpty
                      ? 'Sẵn sàng cho một suất chiếu?'
                      : 'Đèn tắt. Phim bắt đầu.',
                  subtitle: catalog.popular.isEmpty
                      ? 'Khám phá lịch chiếu mới nhất ngay hôm nay.'
                      : 'Chọn ghế yêu thích và tận hưởng khoảnh khắc điện ảnh.',
                  icon: Icons.movie_filter_rounded,
                  action: FilledButton.icon(
                    onPressed: () => context.push('/user/search'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    icon: const Icon(Icons.explore_rounded),
                    label: const Text('Khám phá phim'),
                  ),
                ),
                if (catalog.popular.isNotEmpty) ...[
                  if (catalog.popular.isNotEmpty)
                    FeaturedMovieBanner(movie: catalog.popular.first),
                  if (catalog.nowShowing.isNotEmpty)
                    MovieHorizontalSection(
                      title: 'Đang chiếu',
                      movies: catalog.nowShowing,
                      onSeeAll: () => context.push('/user/catalog/nowShowing'),
                    ),
                  if (catalog.comingSoon.isNotEmpty)
                    MovieHorizontalSection(
                      title: 'Sắp chiếu',
                      movies: catalog.comingSoon,
                      onSeeAll: () => context.push('/user/catalog/comingSoon'),
                    ),
                  MovieHorizontalSection(
                    title: 'Phổ biến',
                    movies: catalog.popular,
                    onSeeAll: () => context.push('/user/catalog/popular'),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 30,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_movies_outlined,
                          size: 54,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có suất chiếu sắp tới',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Kéo xuống để làm mới hoặc quay lại sau nhé.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
