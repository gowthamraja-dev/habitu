import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Saves FCM token to Firestore under users/{uid}. Call when user is signed in
/// and on token refresh. Uses merge so it doesn't overwrite other user fields.
Future<void> saveFcmTokenToFirestore(String uid, String token) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .set({'fcmToken': token, 'fcmTokenUpdatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true));
}

/// Handles FCM token, permissions, and in-app notification handling.
/// Background handler is registered in main.dart.
class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Request notification permission (required on Android 13+).
  /// No-op on older Android / iOS returns existing status.
  Future<NotificationSettings> requestPermission() async {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Get current FCM token. Call after user signs in and save to Firestore.
  /// Token may refresh; listen to [onTokenRefresh] and update Firestore.
  Future<String?> getToken() async {
    if (Platform.isAndroid) {
      final settings = await requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return null;
      }
    }
    return _messaging.getToken();
  }

  /// Stream of new FCM tokens when the token is refreshed. Subscribe and
  /// update Firestore; cancel the subscription when the user signs out.
  Stream<String> get tokenRefreshStream => _messaging.onTokenRefresh;

  /// Foreground: when app is in foreground and a message is received.
  /// Use for in-app UI (e.g. snackbar); no system tray by default.
  void setForegroundHandler(void Function(RemoteMessage message) handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }

  /// Background/terminated: user tapped notification and app opened.
  /// Use to navigate to a specific screen based on [RemoteMessage.data].
  void setOpenedAppHandler(void Function(RemoteMessage message) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }

  /// Cold start: app was terminated and opened by tapping the notification.
  /// Call once at startup (e.g. in main after runApp) and navigate if non-null.
  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }
}
