import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_services.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.authServices});

  final AuthServices? authServices;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AuthServices _authServices = widget.authServices ?? AuthServices();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmation = _confirmPasswordController.text;
    if (email.isEmpty) {
      _showMessage('Email wajib diisi.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Kata sandi minimal 6 karakter.');
      return;
    }
    if (confirmation != password) {
      _showMessage('Konfirmasi kata sandi tidak sama.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authServices.registerWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      _showMessage('Gagal mendaftar: ${error.message ?? error.code}');
    } catch (error) {
      _showMessage('Gagal mendaftar: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Kata sandi',
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi kata sandi',
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Daftar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
