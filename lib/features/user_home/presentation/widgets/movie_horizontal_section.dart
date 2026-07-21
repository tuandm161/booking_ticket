// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import '../../../../shared/widgets/cinema_decor.dart';
import 'movie_poster_card.dart';

class MovieHorizontalSection extends StatelessWidget {
  const MovieHorizontalSection({
    super.key,
    required this.title,
    required this.movies,
    this.onSeeAll,
  });
  final String title;
  final List movies;
  final VoidCallback? onSeeAll;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CinemaSectionTitle(title: title, action: onSeeAll),
      const SizedBox(height: 10),
      SizedBox(
        height: 230,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: movies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => MoviePosterCard(movie: movies[i]),
        ),
      ),
      const SizedBox(height: 22),
    ],
  );
}
