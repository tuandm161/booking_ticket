import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Xác nhận',
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;
}
