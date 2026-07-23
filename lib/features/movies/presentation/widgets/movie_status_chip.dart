import 'package:flutter/material.dart';
import '../../models/movie.dart';

class MovieStatusChip extends StatelessWidget {
  const MovieStatusChip({super.key, required this.status});
  final MovieStatus status;

  static (Color textColor, Color bgColor) colorsOf(MovieStatus status) {
    return switch (status) {
      MovieStatus.nowShowing => (
          const Color(0xFF1B5E20),
          const Color(0xFFE8F5E9)
        ),
      MovieStatus.comingSoon => (
          const Color(0xFF0D47A1),
          const Color(0xFFE3F2FD)
        ),
      MovieStatus.stopped => (
          const Color(0xFF8B0000),
          const Color(0xFFFFE0B2)
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (textColor, bgColor) = colorsOf(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
