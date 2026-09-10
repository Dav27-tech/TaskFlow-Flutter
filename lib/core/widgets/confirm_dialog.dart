import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirmer',
    this.cancelText = 'Annuler',
    this.isDestructive = false,
  });

  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive ? const Color(0xFFDC2626) : const Color(0xFF2878E8),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
