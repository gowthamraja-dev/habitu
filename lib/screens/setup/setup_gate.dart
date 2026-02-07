import 'package:flutter/material.dart';
import 'package:habitu/core/app_constants.dart';
import 'package:habitu/screens/home_screen.dart';
import 'package:habitu/screens/setup/age_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Decides whether to show setup flow (age → habits) or [HomeScreen].
class SetupGate extends StatelessWidget {
  const SetupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance()
          .then((p) => p.getBool(kSetupCompleteKey) ?? false),
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
        return const AgeSelectionScreen();
      },
    );
  }
}
