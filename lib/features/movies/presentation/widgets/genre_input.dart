import 'package:flutter/material.dart';

class AddGenreDialog extends StatefulWidget {
  const AddGenreDialog({super.key});

  @override
  State<AddGenreDialog> createState() => _AddGenreDialogState();
}

class _AddGenreDialogState extends State<AddGenreDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm thể loại'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Tên thể loại'),
        onSubmitted: (v) {
          final trimmed = v.trim();
          if (trimmed.isNotEmpty) Navigator.of(context).pop(trimmed);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            final trimmed = _controller.text.trim();
            if (trimmed.isNotEmpty) Navigator.of(context).pop(trimmed);
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}

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
    final value = await showDialog<String>(
      context: context,
      builder: (_) => const AddGenreDialog(),
    );
    if (value != null &&
        value.trim().isNotEmpty &&
        !genres.contains(value.trim())) {
      onChanged([...genres, value.trim()]);
    }
  }
}
