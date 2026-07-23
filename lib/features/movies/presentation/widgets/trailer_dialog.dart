import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../app/app_theme.dart';

class TrailerDialog extends StatefulWidget {
  const TrailerDialog({
    super.key,
    required this.videoId,
    required this.movieTitle,
  });

  final String videoId;
  final String movieTitle;

  static void show(
    BuildContext context, {
    required String videoId,
    required String movieTitle,
  }) {
    showDialog(
      context: context,
      builder: (_) => TrailerDialog(videoId: videoId, movieTitle: movieTitle),
    );
  }

  @override
  State<TrailerDialog> createState() => _TrailerDialogState();
}

class _TrailerDialogState extends State<TrailerDialog> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF121212),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                const Icon(Icons.movie_rounded, color: AppTheme.cgvRed, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'TRAILER: ${widget.movieTitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  tooltip: 'Đóng',
                ),
              ],
            ),
          ),
          // Player Container
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),
        ],
      ),
    );
  }
}
