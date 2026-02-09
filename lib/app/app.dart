import 'package:flutter/material.dart';
import 'package:habitu/screens/auth/auth_gate.dart';

class HabituApp extends StatelessWidget {
  const HabituApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habitu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthGate(),
    );
  }
}
