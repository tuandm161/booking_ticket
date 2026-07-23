// ignore_for_file: unnecessary_underscores
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../movies/models/movie.dart';
import '../../../../app/app_theme.dart';

/// CGV-style auto-scroll depth carousel banner.
/// - Centre slide: scale 1.0, shadow nổi.
/// - Side slides: scale 0.88, opacity 0.55 tạo chiều sâu 3D.
/// - Auto-play mỗi 4 giây.
class CgvDepthCarousel extends StatefulWidget {
  const CgvDepthCarousel({super.key, required this.movies});
  final List<Movie> movies;

  @override
  State<CgvDepthCarousel> createState() => _CgvDepthCarouselState();
}

class _CgvDepthCarouselState extends State<CgvDepthCarousel> {
  late final PageController _controller;
  late int _currentPage;
  Timer? _timer;

  static const _viewportFraction = 0.82;
  static const _autoPlayDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    // Start in the middle of a large list to allow infinite scrolling feel
    _currentPage = widget.movies.length > 1 ? 1 : 0;
    _controller = PageController(
      viewportFraction: _viewportFraction,
      initialPage: _currentPage,
    );
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (widget.movies.length <= 1) return;
    _timer = Timer.periodic(_autoPlayDuration, (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.movies.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movies = widget.movies;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _controller,
            itemCount: movies.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final movie = movies[index];
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                margin: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: isActive ? 8 : 22,
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: isActive ? 1.0 : 0.55,
                  child: _BannerCard(movie: movie, isActive: isActive),
                ),
              );
            },
          ),
        ),
        if (movies.length > 1) ...[
          const SizedBox(height: 10),
          _DotsIndicator(count: movies.length, current: _currentPage),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.movie, required this.isActive});
  final Movie movie;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/user/movie/${movie.id}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .45),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop / Poster image
            CachedNetworkImage(
              imageUrl: movie.backdropUrl.isNotEmpty
                  ? movie.backdropUrl
                  : movie.posterUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFF1A1A1A),
                child: const Icon(
                  Icons.movie_filter_outlined,
                  color: Colors.white24,
                  size: 60,
                ),
              ),
            ),
            // Gradient overlay bottom
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xCC000000),
                  ],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            // Content bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Age rating badge
                          if (movie.ageRating.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.cgvRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                movie.ageRating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${movie.durationMinutes} phút',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // BOOK NOW button
                    GestureDetector(
                      onTap: () => context.push('/user/movie/${movie.id}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.cgvRed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'BOOK NOW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.cgvRed : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
