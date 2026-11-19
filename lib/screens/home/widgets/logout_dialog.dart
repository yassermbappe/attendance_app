import 'package:flutter/material.dart';

Future<bool> showLogoutDialog(BuildContext context) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Keluar dari akun?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Keluar'),
        ),
      ],
    ),
  );
  return shouldLogout ?? false;
}
