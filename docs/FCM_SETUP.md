# FCM Push Notifications – Setup Summary

Production-ready Firebase Cloud Messaging (FCM) for the Flutter Android app, using only `firebase_messaging` (no `flutter_local_notifications` or custom splash).

---

## 1. Dependencies

**pubspec.yaml**

- `firebase_core` – already present
- `firebase_messaging: ^16.1.1` – added for FCM

No `flutter_local_notifications` or other notification plugins.

---

## 2. Initialization and background handler (main.dart)

- Call `Firebase.initializeApp()` before any Firebase usage.
- Register the **background** handler with `FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler)`.
- The background handler **must** be a **top-level function** (not a closure or instance method) and must be annotated with `@pragma('vm:entry-point')` so it runs in a separate isolate.
- Inside the background handler, call `Firebase.initializeApp()` again (isolate has no access to the main isolate’s app instance).
- Use `setForegroundNotificationPresentationOptions` so that on iOS (and where supported) notifications can show when the app is in the foreground.

---

## 3. Notification permission (Android 13+)

- **Android 13+**: Runtime permission `POST_NOTIFICATIONS` is required for showing notifications.
- Permission is requested inside `FcmService.getToken()` when on Android: we call `requestPermission()` before getting the token, and return `null` if the user denies.
- No extra plugin is needed; `firebase_messaging` uses the platform permission APIs.

---

## 4. AndroidManifest.xml

- **Permissions**: `POST_NOTIFICATIONS`, `WAKE_LOCK`, `VIBRATE`.
- **Metadata**: `com.google.firebase.messaging.default_notification_channel_id` = `habitu_default` (must match the channel id created in MainActivity).

---

## 5. Notification channel (MainActivity.kt, Android 8+)

- Create a `NotificationChannel` in `MainActivity.onCreate()` with id `habitu_default` so FCM has a channel to use for display notifications.
- Channel id must match the one set in AndroidManifest metadata.

---

## 6. FCM token and Firestore

- **Get token**: `FcmService().getToken()` (after user is signed in; on Android this triggers the permission request).
- **Save to Firestore**: `saveFcmTokenToFirestore(uid, token)` writes to `users/{uid}` with `fcmToken` and `fcmTokenUpdatedAt` (merge so other fields are not overwritten).
- **Token refresh**: Subscribe to `FcmService().tokenRefreshStream` and call `saveFcmTokenToFirestore(uid, newToken)` whenever a new token is emitted. This is wired in `FcmTokenRegistration` for the logged-in user.

---

## 7. Handling notifications

| Case | Where | What to do |
|------|--------|------------|
| **Foreground** | `FirebaseMessaging.onMessage` (set in main.dart post-frame) | App is visible; no system tray by default. Use for in-app UI (e.g. snackbar) or logging. |
| **Background** | `_firebaseMessagingBackgroundHandler` (top-level in main.dart) | App in background or terminated; runs in isolate. Keep work light; no UI. |
| **App opened from notification** | `FirebaseMessaging.onMessageOpenedApp` | User tapped notification; app was in background. Use to navigate (e.g. via `HabituApp.handleNotificationOpen`). |
| **Cold start** | `FirebaseMessaging.getInitialMessage()` | App was killed and opened by tapping notification. Call once after app start (e.g. in a post-frame callback in main) and navigate if non-null. |

---

## 8. Recommended FCM payload (data message)

Use **data-only** messages for full control and reliable delivery in all states (foreground, background, terminated). Optional **notification** payload can be added for a system tray title/body when the app is in the background.

**Data message (recommended):**

```json
{
  "data": {
    "route": "/home",
    "id": "123",
    "type": "reminder"
  }
}
```

- All entries under `data` are string key-value pairs (numbers/booleans must be sent as strings and parsed in the app).
- No `notification` block: your app handles all UI (foreground and, if you want, background by showing a local notification yourself; we do not use `flutter_local_notifications` here, so background display is system-handled only if you add a `notification` payload).

**Data + notification (optional):**

```json
{
  "notification": {
    "title": "Reminder",
    "body": "Time to log your habit"
  },
  "data": {
    "route": "/home",
    "id": "123"
  }
}
```

- When the app is in the **background or terminated**, the system can show the notification and open the app on tap; `data` is then available in `getInitialMessage()` or `onMessageOpenedApp`.
- When the app is in the **foreground**, behavior depends on `setForegroundNotificationPresentationOptions`; the `onMessage` handler always receives the message.

**Android-specific (optional):** use `android_channel_id: "habitu_default"` in the FCM payload to target the default channel.

---

## 9. Common mistakes to avoid

1. **Background handler not top-level** – `onBackgroundMessage` must reference a top-level function with `@pragma('vm:entry-point')`. Closures or instance methods will fail in release/build.
2. **Not initializing Firebase in the background handler** – The background isolate does not share the main isolate’s `Firebase.initializeApp()`; call it again inside the background handler.
3. **Missing POST_NOTIFICATIONS on Android 13+** – Declare the permission and request it at runtime (e.g. before `getToken()`); otherwise the user will not see notifications.
4. **No notification channel (Android 8+)** – Without a channel, notifications may not appear or may use a default channel. Create a channel in MainActivity and set `default_notification_channel_id` in the manifest.
5. **Storing FCM token before user is signed in** – Get and save the token only after you have a `uid`; otherwise you may overwrite or mix tokens across users.
6. **Ignoring token refresh** – Tokens can change. Subscribe to `onTokenRefresh` / `tokenRefreshStream` and update Firestore so the server always sends to the latest token.
7. **Heavy work in the background handler** – Runs in a separate isolate with strict limits. Avoid long work, large allocations, or UI; prefer small updates and logging.
8. **Using notification payload only** – Notification-only messages may not be delivered when the app is in the foreground or may not give you `data` in all cases. Prefer data (or data + notification) for routing and deep links.
9. **Navigating before the navigator is ready** – Call `getInitialMessage()` and perform navigation in a post-frame callback (or after the first frame) so the navigator key is available.
10. **Removing `google-services` plugin or `google-services.json`** – Required for FCM; keep `apply plugin: 'com.google.gms.google-services'` and the correct `google-services.json` in `android/app/`.

---

## 10. No flutter_local_notifications or custom splash

- Notifications are shown by the system using FCM’s default behavior and the channel created in MainActivity.
- No custom splash screen or extra notification plugin is required for this setup.

---

## File reference

| File | Role |
|------|------|
| `pubspec.yaml` | `firebase_messaging` dependency |
| `lib/main.dart` | Firebase init, background handler, foreground/opened/initial handlers |
| `lib/app/app.dart` | `appNavigatorKey`, `handleNotificationOpen` |
| `lib/services/fcm_service.dart` | Token, permission, Firestore save, stream/handlers API |
| `lib/widgets/fcm_token_registration.dart` | Registers token and token refresh for logged-in user |
| `lib/screens/auth/auth_gate.dart` | Wraps authenticated content with `FcmTokenRegistration` |
| `android/app/src/main/AndroidManifest.xml` | Permissions, default channel meta-data |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Notification channel creation |
