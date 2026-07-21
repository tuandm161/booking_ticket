// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../movies/models/movie.dart';

class MoviePosterCard extends StatelessWidget {
  const MoviePosterCard({super.key, required this.movie});
  final Movie movie;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 142,
    child: InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () => context.push('/user/movie/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: .4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      child: const Icon(Icons.movie_filter_outlined),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .6),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, height: 1.15),
          ),
        ],
      ),
    ),
  );
}
