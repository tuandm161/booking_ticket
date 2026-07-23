import 'package:flutter/material.dart';

/// Reusable micro-animation widget wrapper that provides smooth press-scaling feedback (`Transform.scale(scale: 0.96)`).
class AppPressScale extends StatefulWidget {
  const AppPressScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 110),
    this.reverseDuration = const Duration(milliseconds: 140),
    this.curve = Curves.easeOutCubic,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final bool enabled;

  @override
  State<AppPressScale> createState() => _AppPressScaleState();
}

class _AppPressScaleState extends State<AppPressScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  // Guards against calling controller methods after disposal.
  // Listener pointer callbacks can fire after the widget is removed from the
  // tree (e.g. pressing a Cancel button that immediately pops the route).
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
      value: 0.0,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.curve,
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    super.dispose();
  }

  void _down() {
    if (widget.enabled && !_disposed) _controller.forward();
  }

  void _up() {
    if (widget.enabled && !_disposed) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    Widget content = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      return Listener(
        onPointerDown: (_) => _down(),
        onPointerUp: (_) => _up(),
        onPointerCancel: (_) => _up(),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: content,
        ),
      );
    }

    return Listener(
      onPointerDown: (_) => _down(),
      onPointerUp: (_) => _up(),
      onPointerCancel: (_) => _up(),
      child: content,
    );
  }
}
