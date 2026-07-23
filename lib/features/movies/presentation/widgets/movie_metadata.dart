import 'package:flutter/material.dart';
import '../../models/movie.dart';
import 'movie_status_chip.dart';

class MovieMetadata extends StatelessWidget {
  const MovieMetadata({super.key, required this.movie});
  final Movie movie;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          MovieStatusChip(status: movie.status),
          if (movie.ageRating.isNotEmpty) Chip(label: Text(movie.ageRating)),
          Chip(label: Text('${movie.durationMinutes} phút')),
        ],
      ),
      Text(
        [
          if (movie.releaseDate != null)
            'Khởi chiếu ${movie.releaseDate!.day}/${movie.releaseDate!.month}/${movie.releaseDate!.year}',
          movie.country,
          movie.director,
        ].where((x) => x.isNotEmpty).join(' • '),
      ),
      if (movie.genres.isNotEmpty) Text('Thể loại: ${movie.genres.join(', ')}'),
    ],
  );
}
