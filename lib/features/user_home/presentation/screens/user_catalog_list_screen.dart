// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../providers/user_catalog_provider.dart';
import '../widgets/movie_poster_card.dart';

class UserCatalogListScreen extends ConsumerWidget {
  const UserCatalogListScreen({
    super.key,
    required this.title,
    required this.section,
  });
  final String title;
  final String section;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userCatalogProvider);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      bottomNavigationBar: const UserBottomNavigation(index: 0),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Không thể tải danh mục phim.')),
        data: (catalog) {
          final movies = switch (section) {
            'nowShowing' => catalog.nowShowing,
            'comingSoon' => catalog.comingSoon,
            _ => catalog.popular,
          };
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .62,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: movies.length,
            itemBuilder: (_, i) => MoviePosterCard(movie: movies[i]),
          );
        },
      ),
    );
  }
}
