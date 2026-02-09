import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:habitu/screens/auth/auth_gate.dart';

/// Global key so FCM can trigger navigation when app is opened from a notification.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class HabituApp extends StatelessWidget {
  const HabituApp({super.key});

  /// Call when app is opened from a notification (cold start or from background).
  /// Navigate based on [message.data]; extend as needed for your routes.
  static void handleNotificationOpen(RemoteMessage message) {
    final context = appNavigatorKey.currentContext;
    if (context == null) return;
    // Optional: navigate by message.data['route'] or other payload
    final route = message.data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Habitu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthGate(),
    );
  }
}
