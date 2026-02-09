import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:habitu/app/app.dart';
import 'package:habitu/services/fcm_service.dart';
import 'package:habitu/services/notification_service.dart';
import 'firebase_options.dart';

/// Top-level handler for FCM when app is in background or terminated.
/// Must be a top-level function (not a closure or instance method).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Optional: handle data, log, or update local state
  // Avoid heavy work; this runs in a separate isolate.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService().initialize();

  runApp(const HabituApp());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final fcm = FcmService();
    final initialMessage = await fcm.getInitialMessage();
    if (initialMessage != null) {
      HabituApp.handleNotificationOpen(initialMessage);
    }
    fcm.setOpenedAppHandler(HabituApp.handleNotificationOpen);
    fcm.setForegroundHandler((message) async {
      // Show push as a local notification when app is in foreground so user sees it.
      final title = message.notification?.title ?? 'Push';
      final body = message.notification?.body ?? message.data.toString();
      await NotificationService().showTestNow(title: title, body: body);
    });
  });
}
