import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/tmdb_movie_summary.dart';

class TmdbResultTile extends StatelessWidget {
  const TmdbResultTile({super.key, required this.movie, required this.onTap});
  final TmdbMovieSummary movie;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: SizedBox(
      width: 48,
      height: 64,
      child: movie.posterUrl == null
          ? const Icon(Icons.movie)
          : CachedNetworkImage(imageUrl: movie.posterUrl!, fit: BoxFit.cover),
    ),
    title: Text(movie.title),
    subtitle: Text(movie.releaseDate ?? 'Chưa có ngày phát hành'),
  );
}
