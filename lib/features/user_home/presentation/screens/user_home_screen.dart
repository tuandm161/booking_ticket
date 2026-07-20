// ignore_for_file: curly_braces_in_flow_control_structures, unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
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
        title: const Text('CineBook'),
        actions: [
          IconButton(
            onPressed: () => context.push('/user/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      bottomNavigationBar: const UserBottomNavigation(index: 0),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Không thể tải danh mục phim.')),
        data: (catalog) {
          if (catalog.popular.isEmpty)
            return const Center(child: Text('Chưa có suất chiếu sắp tới.'));
          return ListView(
            children: [
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
            ],
          );
        },
      ),
    );
  }
}
