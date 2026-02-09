import 'package:flutter/material.dart';
import 'package:habitu/screens/home_screen.dart';
import 'package:habitu/screens/setup/unified_setup_screen.dart';
import 'package:habitu/services/user_prefs_service.dart';

/// Decides whether to show setup flow (unified age + habits) or [HomeScreen].
/// [uid] must be the current authenticated user's id.
class SetupGate extends StatelessWidget {
  final String uid;

  const SetupGate({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final userPrefs = UserPrefsService();
    return FutureBuilder<bool>(
      future: userPrefs.isSetupComplete(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0C),
            body: Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          );
        }
        if (snapshot.data == true) {
          return const HomeScreen();
        }
        return const UnifiedSetupScreen();
      },
    );
  }
}
