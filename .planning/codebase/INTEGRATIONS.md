# INTEGRATIONS

## Integration Overview
External dependencies are concentrated around Firebase (Auth, Firestore, Cloud Messaging) and device notification APIs. Integration code is mostly in `lib/services/` with platform hooks in Android native files.

## Firebase Core
- Purpose: initialize Firebase app and load platform options.
- Entry points:
  - `lib/main.dart` calls `Firebase.initializeApp(...)`
  - `lib/firebase_options.dart` stores generated app credentials/options
  - `firebase.json` maps FlutterFire output and Firebase project/app IDs
  - `android/app/google-services.json` provides Android Firebase config
- Data exchanged: app-level config and credentials for Firebase SDK boot.

## Firebase Authentication
- Purpose: email/password auth state and account actions.
- Integration files:
  - `lib/services/auth_service.dart` (`FirebaseAuth.instance`, sign-in/sign-up/sign-out/reset)
  - `lib/screens/auth/auth_gate.dart` consumes `authStateChanges` stream
- Data contracts:
  - Uses Firebase `User`/`UserCredential`
  - Emits authenticated UID used by downstream Firestore/FCM integrations.

## Cloud Firestore
- Purpose: user profile flags, habits CRUD, habit metadata catalog, FCM token persistence.
- Integration files:
  - `lib/services/habit_service.dart`
  - `lib/services/habits_meta_service.dart`
  - `lib/services/user_prefs_service.dart`
  - `lib/services/fcm_service.dart` (`saveFcmTokenToFirestore`)
- Security and schema envelope:
  - `firestore.rules`
  - Collections implied by code/rules: `users/{uid}`, `users/{uid}/habits/{habitId}`, `habits_meta/{docId}`
- Data flow notes:
  - Habit data is per-user and auth-gated in service + rules.
  - Setup completion is stored on `users/{uid}.setupComplete`.
  - FCM token is merged onto `users/{uid}` with server timestamp.

## Firebase Cloud Messaging (Push)
- Purpose: receive push notifications, handle app-open navigation, manage token lifecycle.
- Integration files:
  - `lib/main.dart` registers background handler and foreground/opened/cold-start listeners
  - `lib/services/fcm_service.dart` wraps messaging API, permission request, token refresh stream
  - `lib/widgets/fcm_token_registration.dart` registers and persists token for logged-in user
  - `lib/app/app.dart` routes on notification tap payload (`message.data['route']`)
- Android platform hooks:
  - `android/app/src/main/AndroidManifest.xml` permissions + default channel metadata (`habitu_default`)
  - `android/app/src/main/kotlin/com/example/habitu/MainActivity.kt` creates notification channel `habitu_default`
  - `android/app/build.gradle.kts` includes Firebase BoM + Google services plugin
- Integration setup notes:
  - `docs/FCM_SETUP.md` documents expected payloads and runtime behavior.

## Local Notifications (Device-Side)
- Purpose: daily reminder scheduling and foreground display fallback.
- Integration files:
  - `lib/services/notification_service.dart`
  - `lib/main.dart` initializes service and shows local notification for foreground FCM
- Dependencies and APIs:
  - Flutter plugin `flutter_local_notifications`
  - Timezone package `timezone` and IST helper `lib/core/ist_time.dart`
  - Android permissions in `android/app/src/main/AndroidManifest.xml` include `SCHEDULE_EXACT_ALARM`
- Behavior:
  - Creates local channel `habit_reminders`
  - Schedules per-habit recurring reminders by `habitId`-derived notification ID
  - Falls back to inexact schedule when exact alarms are not permitted.

## Platform and Build Integrations
- Android:
  - Gradle + Flutter plugin: `android/app/build.gradle.kts`
  - Firebase services plugin: `com.google.gms.google-services`
- iOS:
  - Flutter app delegate wiring: `ios/Runner/AppDelegate.swift`
  - iOS app metadata: `ios/Runner/Info.plist`

## Integration Risks / Watchpoints
- `shared_preferences` is declared in `pubspec.yaml` but currently unused in `lib/`.
- `lib/firebase_options.dart` excludes web/desktop support and throws on those platforms.
- Notification channel IDs must stay aligned between `MainActivity.kt` (`habitu_default`) and `AndroidManifest.xml` metadata.
