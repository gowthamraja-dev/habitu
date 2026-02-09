import 'package:flutter/material.dart';
import 'package:habitu/screens/auth/login_screen.dart';
import 'package:habitu/screens/setup/setup_gate.dart';
import 'package:habitu/services/auth_service.dart';

/// Shows [LoginScreen] when not authenticated, otherwise [SetupGate] (which shows setup or home).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0C),
            body: Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        return SetupGate(uid: user.uid);
      },
    );
  }
}
