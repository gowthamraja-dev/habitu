# External Integrations

**Last verified:** 2026-03-14

## 1. Firebase Services

### 1.1 Firebase Core

- App initialization via `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` in `lib/main.dart`.
- Platform options generated in `lib/firebase_options.dart`.
- FlutterFire mapping config in `firebase.json`.

### 1.2 Firebase Authentication

- SDK: `firebase_auth` (declared in `pubspec.yaml`).
- Integration wrapper: `lib/services/auth_service.dart`.
- Flows used:
- Email/password sign in (`signInWithEmailAndPassword`).
- Email/password sign up (`createUserWithEmailAndPassword`).
- Sign out (`signOut`).
- Password reset email (`sendPasswordResetEmail`).
- Auth state stream drives root routing in `lib/screens/auth/auth_gate.dart`.

### 1.3 Cloud Firestore

- SDK: `cloud_firestore` (declared in `pubspec.yaml`).
- Main service integrations:
- `lib/services/habit_service.dart` for per-user habits CRUD at `users/{uid}/habits`.
- `lib/services/habits_meta_service.dart` for catalog reads from top-level `habits_meta`.
- `lib/services/user_prefs_service.dart` for user setup state at `users/{uid}`.
- `lib/services/fcm_service.dart` stores FCM token data on `users/{uid}`.

#### Firestore collection/document footprint in code

- `users/{uid}/habits`:
- Fields from `lib/models/habit.dart`: `name`, `section`, `order`, `createdAt`, `updatedAt`, optional `colorHex`, optional `iconName`, optional `reminderTimeMinutes`.
- `users/{uid}`:
- `setupComplete` (written/read by `lib/services/user_prefs_service.dart`).
- `fcmToken`, `fcmTokenUpdatedAt` (written by `saveFcmTokenToFirestore` in `lib/services/fcm_service.dart`).
- `habits_meta/{docId}`:
- Parsed by `lib/models/habit_meta.dart` fields `n`, `c`, `d`, `amin`, `amax`.

### 1.4 Firebase Cloud Messaging (FCM)

- SDK: `firebase_messaging` (declared in `pubspec.yaml`).
- Background handler registration in `lib/main.dart` with top-level `@pragma('vm:entry-point')` handler.
- Foreground presentation options set in `lib/main.dart`.
- Opened-from-notification handling:
- Cold start: `getInitialMessage()` via `lib/services/fcm_service.dart`, consumed in `lib/main.dart`.
- Resume from background: `onMessageOpenedApp` via `lib/services/fcm_service.dart`.
- Foreground messages are bridged to local notification display in `lib/main.dart` via `NotificationService().showTestNow(...)`.
- Token registration/refresh persistence pipeline:
- Triggered by `lib/widgets/fcm_token_registration.dart` for authenticated users.
- Token read and permission flow in `lib/services/fcm_service.dart`.
- Token persisted to Firestore via `saveFcmTokenToFirestore(...)`.

## 2. Local Notifications and Timezone

### 2.1 Local Notifications

- Plugin: `flutter_local_notifications` (declared in `pubspec.yaml`).
- Integration singleton: `lib/services/notification_service.dart`.
- Capabilities used:
- Notification plugin initialization.
- Android channel creation (`habit_reminders`).
- Immediate test notifications (`showTestNow`).
- Daily zoned schedule (`zonedSchedule`) for habit reminders.
- Fallback from exact to inexact scheduling on `exact_alarms_not_permitted`.
- Habit reminder workflows wired from `lib/screens/manage/habit_reminder_sheet.dart` and diagnostics in `lib/screens/settings/settings_screen.dart`.

### 2.2 Timezone

- Plugin: `timezone` (declared in `pubspec.yaml`).
- Timezone DB init in `lib/services/notification_service.dart`.
- Forced timezone strategy: `Asia/Kolkata` via helper in `lib/core/ist_time.dart`.
- Reminder times stored as minutes since midnight (`reminderTimeMinutes` in `lib/models/habit.dart`).

## 3. Platform-Level Integration Points

### 3.1 Android

- App permissions and FCM metadata in `android/app/src/main/AndroidManifest.xml`:
- `android.permission.POST_NOTIFICATIONS`
- `android.permission.WAKE_LOCK`
- `android.permission.VIBRATE`
- `android.permission.SCHEDULE_EXACT_ALARM`
- `com.google.firebase.messaging.default_notification_channel_id = habitu_default`
- Native notification channel creation (`habitu_default`) in `android/app/src/main/kotlin/com/example/habitu/MainActivity.kt`.
- Firebase Android config file: `android/app/google-services.json`.

### 3.2 iOS

- App host registration in `ios/Runner/AppDelegate.swift`.
- iOS app metadata in `ios/Runner/Info.plist`.
- iOS Firebase options in `lib/firebase_options.dart`.

## 4. Not Present (as of this verification)

- No direct REST client integration (`http`, `dio`) found in `lib/`.
- No analytics/crash reporting SDK integration (e.g., Firebase Analytics, Crashlytics, Sentry) found in `pubspec.yaml` or `lib/`.
- No CI/CD workflow files detected (e.g., `.github/workflows/`).
