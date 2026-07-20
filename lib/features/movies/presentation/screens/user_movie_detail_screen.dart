// ignore_for_file: curly_braces_in_flow_control_structures, unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/firebase_providers.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../../showtimes/providers/user_showtime_providers.dart';
import '../../../user_home/providers/user_catalog_provider.dart';
import '../../data/movie_repository.dart';
import '../../models/movie.dart';
import '../widgets/movie_metadata.dart';
import '../widgets/cast_list.dart';

class UserMovieDetailScreen extends ConsumerWidget {
  const UserMovieDetailScreen({super.key, required this.movieId});
  final String movieId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder<Movie?>(
    future: MovieRepository(ref.watch(firestoreProvider)).getMovie(movieId),
    builder: (context, snap) {
      final catalogState = ref.watch(userCatalogProvider);
      if (catalogState.hasValue &&
          !catalogState.requireValue.bookable.any(
            (item) => item.id == movieId,
          )) {
        return const Scaffold(
          body: Center(child: Text('Phim hiện chưa có suất chiếu để đặt.')),
        );
      }
      if (!snap.hasData)
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      final movie = snap.data;
      if (movie == null)
        return const Scaffold(
          body: Center(child: Text('Không tìm thấy phim.')),
        );
      final shows = ref.watch(userShowtimesProvider(movieId));
      return Scaffold(
        bottomNavigationBar: const UserBottomNavigation(index: 0),
        body: ListView(
          children: [
            SizedBox(
              height: 250,
              child: Image.network(
                movie.backdropUrl.isNotEmpty
                    ? movie.backdropUrl
                    : movie.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Colors.black12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  MovieMetadata(movie: movie),
                  const SizedBox(height: 16),
                  Text(
                    movie.overview.isEmpty ? 'Chưa có mô tả.' : movie.overview,
                  ),
                  const SizedBox(height: 12),
                  CastList(cast: movie.cast),
                  if (movie.trailerUrl.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.tryParse(movie.trailerUrl);
                        if (uri != null &&
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            ))
                          return;
                        if (context.mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Không mở được trailer.'),
                            ),
                          );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Xem trailer'),
                    ),
                  const SizedBox(height: 12),
                  shows.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Không tải được suất chiếu.'),
                    data: (items) => FilledButton(
                      onPressed: items.isEmpty
                          ? null
                          : () => context.push('/user/showtimes/$movieId'),
                      child: Text(
                        items.isEmpty
                            ? 'Chưa có suất chiếu'
                            : 'Chọn suất chiếu (${items.length})',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
