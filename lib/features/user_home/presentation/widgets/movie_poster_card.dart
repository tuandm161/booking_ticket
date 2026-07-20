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
    width: 140,
    child: InkWell(
      onTap: () => context.push('/user/movie/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: Colors.black12,
                  child: Icon(Icons.movie),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
