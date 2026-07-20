import 'package:flutter/material.dart';

class GenreInput extends StatelessWidget {
  const GenreInput({super.key, required this.genres, required this.onChanged});
  final List<String> genres;
  final ValueChanged<List<String>> onChanged;
  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: const InputDecoration(labelText: 'Thể loại'),
    child: Wrap(
      spacing: 6,
      children: [
        ...genres.map(
          (genre) => InputChip(
            label: Text(genre),
            onDeleted: () =>
                onChanged(genres.where((item) => item != genre).toList()),
          ),
        ),
        ActionChip(label: const Text('Thêm'), onPressed: () => _add(context)),
      ],
    ),
  );
  Future<void> _add(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm thể loại'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Tên thể loại'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null &&
        value.trim().isNotEmpty &&
        !genres.contains(value.trim())) {
      onChanged([...genres, value.trim()]);
    }
  }
}
