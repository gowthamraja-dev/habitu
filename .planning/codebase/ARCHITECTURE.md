# Architecture

**Analysis Date:** 2026-03-14

## System Shape

- App type: Flutter mobile client with Firebase backend.
- Runtime entrypoint: `lib/main.dart`.
- Root widget and global navigation key: `lib/app/app.dart`.
- Primary architecture style: feature-oriented UI + thin service layer over Firebase SDKs.

## Runtime Layers

1. Bootstrap and process-level wiring
- `lib/main.dart` initializes Firebase, FCM foreground presentation, background message handler, and local notifications.
- `lib/main.dart` registers notification-open callbacks after `runApp`.

2. App shell and navigation surface
- `lib/app/app.dart` defines `MaterialApp`, global `appNavigatorKey`, and push-open route handling (`message.data['route']`).

3. Session and onboarding gates
- `lib/screens/auth/auth_gate.dart` selects authenticated vs unauthenticated flow via `AuthService.authStateChanges`.
- `lib/screens/setup/setup_gate.dart` checks setup completion and routes to `HomeScreen` or onboarding.
- `lib/widgets/fcm_token_registration.dart` persists FCM token for authenticated users.

4. Feature screens
- Auth: `lib/screens/auth/login_screen.dart`.
- Setup (active): `lib/screens/setup/unified_setup_screen.dart`.
- Home and daily usage: `lib/screens/home_screen.dart`.
- Habit management: `lib/screens/manage/manage_habits_screen.dart`, `lib/screens/manage/add_habits_screen.dart`, `lib/screens/manage/habit_form_sheet.dart`, `lib/screens/manage/habit_reminder_sheet.dart`.
- Notification diagnostics/settings: `lib/screens/settings/settings_screen.dart`.

5. Domain models
- Habit entity: `lib/models/habit.dart`.
- Habit catalog metadata entity: `lib/models/habit_meta.dart`.

6. Service layer (Firebase + platform integration)
- Auth: `lib/services/auth_service.dart` (`FirebaseAuth`).
- Habit CRUD and stream queries: `lib/services/habit_service.dart` (`Cloud Firestore`).
- Habit catalog fetch/grouping: `lib/services/habits_meta_service.dart` (`Cloud Firestore`).
- Setup completion flag storage: `lib/services/user_prefs_service.dart` (`Cloud Firestore users/{uid}`).
- Push token and message hooks: `lib/services/fcm_service.dart` (`FirebaseMessaging`).
- Local scheduling/display: `lib/services/notification_service.dart` (`flutter_local_notifications` + `timezone`).

7. Shared constants/time helpers
- `lib/core/app_constants.dart` (sections + age groups).
- `lib/core/ist_time.dart` (IST conversion and formatting helpers).

## Data and Control Flows

### Auth to app flow
1. `lib/main.dart` starts `HabituApp`.
2. `lib/screens/auth/auth_gate.dart` listens to auth stream.
3. Signed-out users see `lib/screens/auth/login_screen.dart`.
4. Signed-in users are wrapped by `lib/widgets/fcm_token_registration.dart` then sent to `lib/screens/setup/setup_gate.dart`.

### Setup flow (active)
1. `lib/screens/setup/setup_gate.dart` checks setup state through `lib/services/user_prefs_service.dart`.
2. If incomplete, `lib/screens/setup/unified_setup_screen.dart` loads suggestions from `lib/services/habits_meta_service.dart`.
3. Selected habits are created via `lib/services/habit_service.dart`.
4. Setup completion is persisted to `users/{uid}.setupComplete` through `lib/services/user_prefs_service.dart`.

### Daily habit flow
1. `lib/screens/home_screen.dart` subscribes to `HabitService.watchHabits()`.
2. Stream source is Firestore `users/{uid}/habits`, ordered by `section`, `order`.
3. Manage and edit actions route to `lib/screens/manage/*` screens/sheets.
4. Reminder changes in `lib/screens/manage/habit_reminder_sheet.dart` update habit docs and sync/cancel local notifications via `lib/services/notification_service.dart`.

### Notification flow
- FCM background handler: top-level function in `lib/main.dart`.
- FCM foreground/open handling APIs: `lib/services/fcm_service.dart`.
- Token persistence: `saveFcmTokenToFirestore` in `lib/services/fcm_service.dart` writing to `users/{uid}`.
- Local reminder scheduling: `lib/services/notification_service.dart`, with timezone fixed to `Asia/Kolkata` via `lib/core/ist_time.dart`.
- Android notification channel creation: `android/app/src/main/kotlin/com/example/habitu/MainActivity.kt`.

## Storage Model

Firestore collections/documents used by app code:
- `users/{uid}`
- `users/{uid}/habits/{habitId}`
- `habits_meta/{metaId}`

Document fields actively used:
- User doc: `setupComplete`, `fcmToken`, `fcmTokenUpdatedAt`.
- Habit doc: `name`, `section`, `order`, `createdAt`, `updatedAt`, optional `colorHex`, `iconName`, `reminderTimeMinutes`.
- Habit meta doc: compact fields `n`, `c`, `d`, `amin`, `amax`.

## Active vs Legacy Paths

- Active onboarding path: `lib/screens/setup/unified_setup_screen.dart` via `lib/screens/setup/setup_gate.dart`.
- Legacy onboarding screens still present but not routed from gates:
  - `lib/screens/setup/age_selection.dart`
  - `lib/screens/setup/habits_selection.dart`

## Platform Integration Points

- Firebase options: `lib/firebase_options.dart`.
- Android manifest permissions/channels: `android/app/src/main/AndroidManifest.xml`.
- Android channel implementation: `android/app/src/main/kotlin/com/example/habitu/MainActivity.kt`.
- iOS app delegate bootstrap: `ios/Runner/AppDelegate.swift`.

## Architectural Notes

- Services are instantiated ad hoc (no dependency injection container).
- UI uses `StreamBuilder`/`FutureBuilder` directly over service calls.
- Setup persistence currently uses Firestore (`UserPrefsService`), not local preferences.
