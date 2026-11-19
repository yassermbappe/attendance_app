import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: onToggleVisibility == null
            ? null
            : IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                tooltip: obscureText
                    ? 'Tampilkan kata sandi'
                    : 'Sembunyikan kata sandi',
              ),
      ),
    );
  }
}
