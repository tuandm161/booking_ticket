// ignore_for_file: unnecessary_underscores
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../movies/models/movie.dart';
import '../../../../app/app_theme.dart';

import '../../../../shared/widgets/app_press_scale.dart';

/// CGV-style movie poster card: poster dạng 2:3, badge ageRating góc trên,
/// tên phim phía dưới, không có BOOK NOW riêng (tapping card điều hướng đến
/// detail).
class MoviePosterCard extends StatelessWidget {
  const MoviePosterCard({super.key, required this.movie});
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: AppPressScale(
        onTap: () => context.push('/user/movie/${movie.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster image 2:3
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFF252525),
                        child: const Icon(
                          Icons.movie_filter_outlined,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                    // Age rating badge - top left
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
                    // Coming soon dim overlay
                    if (movie.status == MovieStatus.comingSoon)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            // Title
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
            const SizedBox(height: 3),
            // Duration
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
  }
}
