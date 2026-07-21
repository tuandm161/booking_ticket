import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A reusable cinematic header that gives screens a clear visual hierarchy
/// without relying on remote images or heavyweight raster assets.
class CinemaHero extends StatelessWidget {
  const CinemaHero({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.icon = Icons.local_movies_outlined,
    this.action,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .94, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        constraints: const BoxConstraints(minHeight: 158),
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              colors.primary.withValues(alpha: .95),
              const Color(0xff24204b),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: .22),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -35,
              top: -32,
              child: _OrbitIcon(icon: icon, size: 150),
            ),
            Positioned(
              right: 28,
              bottom: -38,
              child: _FilmStrip(color: colors.secondary),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: TextStyle(
                      color: colors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 9),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .78),
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (action != null) ...[const SizedBox(height: 15), action!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CinemaSectionTitle extends StatelessWidget {
  const CinemaSectionTitle({super.key, required this.title, this.action});

  final String title;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 12, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 23,
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          if (action != null)
            IconButton(
              onPressed: action,
              icon: const Icon(Icons.arrow_forward_rounded),
              tooltip: 'Xem tất cả',
            ),
        ],
      ),
    );
  }
}

class CinemaBackdrop extends StatelessWidget {
  const CinemaBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _CinemaPatternPainter(Theme.of(context).colorScheme),
        ),
        child,
      ],
    ),
  );
}

class _OrbitIcon extends StatefulWidget {
  const _OrbitIcon({required this.icon, required this.size});
  final IconData icon;
  final double size;

  @override
  State<_OrbitIcon> createState() => _OrbitIconState();
}

class _OrbitIconState extends State<_OrbitIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (_, child) =>
        Transform.rotate(angle: _controller.value * math.pi * 2, child: child),
    child: Icon(
      widget.icon,
      size: widget.size,
      color: Colors.white.withValues(alpha: .08),
    ),
  );
}

class _FilmStrip extends StatelessWidget {
  const _FilmStrip({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -.18,
    child: Row(
      children: List.generate(
        5,
        (i) => Container(
          width: 34,
          height: 28,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: color.withValues(alpha: .4)),
          ),
          child: Icon(
            Icons.circle,
            size: 7,
            color: color.withValues(alpha: .55),
          ),
        ),
      ),
    ),
  );
}

class _CinemaPatternPainter extends CustomPainter {
  _CinemaPatternPainter(this.colors);
  final ColorScheme colors;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = colors.primary.withValues(alpha: .025);
    for (var x = -size.height; x < size.width; x += 42) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CinemaPatternPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
