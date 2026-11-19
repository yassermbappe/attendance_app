import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../services/auth_services.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key, this.authServices});

  final AuthServices? authServices;

  @override
  Widget build(BuildContext context) {
    final service = authServices ?? AuthServices();
    return StreamBuilder<User?>(
      stream: service.authStateChanges,
      initialData: service.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return const LoginScreen();
        return HomeScreen(userId: user.uid);
      },
    );
  }
}
