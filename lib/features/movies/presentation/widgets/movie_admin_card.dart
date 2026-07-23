import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/movie.dart';
import 'movie_status_chip.dart';

class MovieAdminCard extends StatelessWidget {
  const MovieAdminCard({
    super.key,
    required this.movie,
    required this.onEdit,
    required this.onToggleActive,
    required this.onToggleFeatured,
    required this.onDelete,
  });
  final Movie movie;
  final VoidCallback onEdit, onToggleActive, onToggleFeatured, onDelete;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: SizedBox(
        width: 52,
        height: 76,
        child: CachedNetworkImage(
          imageUrl: movie.posterUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Icon(Icons.movie),
        ),
      ),
      title: Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            MovieStatusChip(status: movie.status),
            Text(
              '${movie.bookingCount} lượt đặt${movie.isFeatured ? ' • Nổi bật' : ''}${movie.createdAt != null ? ' • Thêm: ${movie.createdAt!.day}/${movie.createdAt!.month}/${movie.createdAt!.year}' : ''}',
            ),
          ],
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => switch (value) {
          'edit' => onEdit(),
          'active' => onToggleActive(),
          'featured' => onToggleFeatured(),
          'delete' => onDelete(),
          _ => null,
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Sửa')),
          PopupMenuItem(
            value: 'featured',
            child: Text(movie.isFeatured ? 'Bỏ nổi bật' : 'Đánh dấu nổi bật'),
          ),
          PopupMenuItem(
            value: 'active',
            child: Text(movie.isActive ? 'Ẩn phim' : 'Kích hoạt'),
          ),
          const PopupMenuItem(value: 'delete', child: Text('Xóa')),
        ],
      ),
    ),
  );
}
