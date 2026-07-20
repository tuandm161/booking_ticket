import 'package:flutter/material.dart';
import '../../models/movie.dart';

class MovieMetadata extends StatelessWidget {
  const MovieMetadata({super.key, required this.movie});
  final Movie movie;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        children: [
          Chip(label: Text(movie.status.label)),
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
