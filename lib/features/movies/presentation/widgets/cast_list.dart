import 'package:flutter/material.dart';

class CastList extends StatelessWidget {
  const CastList({super.key, required this.cast});
  final List<String> cast;
  @override
  Widget build(BuildContext context) => cast.isEmpty
      ? const SizedBox.shrink()
      : Text('Diễn viên: ${cast.join(', ')}');
}
