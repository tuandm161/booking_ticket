// ignore_for_file: curly_braces_in_flow_control_structures, unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../providers/user_catalog_provider.dart';
import '../../models/user_catalog.dart';
import '../widgets/movie_poster_card.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});
  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userCatalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm phim, đạo diễn, thể loại',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => query = v),
        ),
      ),
      bottomNavigationBar: const UserBottomNavigation(index: 1),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Không thể tải dữ liệu.')),
        data: (catalog) {
          final results = searchUserMovies(catalog, query);
          if (results.isEmpty)
            return const Center(child: Text('Không tìm thấy phim phù hợp.'));
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .62,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: results.length,
            itemBuilder: (_, i) => MoviePosterCard(movie: results[i]),
          );
        },
      ),
    );
  }
}
