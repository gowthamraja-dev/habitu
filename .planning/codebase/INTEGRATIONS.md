# External Integrations

**Analysis Date:** 2026-03-13

## APIs & External Services

**Firebase (Backend-as-a-Service):**
- Firebase Authentication - Email/password user authentication
  - SDK: `firebase_auth` 6.1.4
  - Methods: `signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, `signOut`, `sendPasswordResetEmail`
  - Auth state: `authStateChanges()` stream

- Firebase Cloud Firestore - NoSQL database
  - SDK: `cloud_firestore` 6.1.2
  - Collections: `users/{uid}/habits` for habit data, `users/{uid}` for user preferences
  - FCM token storage: `users/{uid}.fcmToken`

- Firebase Cloud Messaging (FCM) - Push notifications
  - SDK: `firebase_messaging` 16.1.1
  - Used for: Push notifications from server
  - Token stored in Firestore at `users/{uid}.fcmToken`

## Data Storage

**Firestore (Primary Database):**
- Type: Firebase Cloud Firestore (NoSQL)
- Connection: Auto-configured via `firebase_core` with options from `lib/firebase_options.dart`
- Project ID: `habitu-tn88`
- Collections:
  - `users/{uid}/habits` - Individual habit documents
  - `users/{uid}` - User preferences (setupComplete, fcmToken)

**Local Storage:**
- `shared_preferences` - Key-value local storage (referenced in `pubspec.yaml` but actual usage appears minimal; user prefs stored in Firestore)

**File Storage:**
- Firebase Storage - Referenced in Firebase config (`habitu-tn88.firebasestorage.app`) but not actively used in code

## Authentication & Identity

**Auth Provider:**
- Firebase Authentication (email/password)
  - Implementation: `AuthService` class in `lib/services/auth_service.dart`
  - Uses FirebaseAuth SDK
  - Methods: sign-in, sign-up, sign-out, password reset
  - User ID available via `currentUser?.uid`

## Push Notifications

**FCM (Firebase Cloud Messaging):**
- Service: `FcmService` in `lib/services/fcm_service.dart`
- Token management: Saved to Firestore at `users/{uid}.fcmToken`
- Background handler: Registered in `lib/main.dart`
- Foreground handling: `FirebaseMessaging.onMessage` listener

**Local Notifications:**
- Service: `NotificationService` in `lib/services/notification_service.dart`
- Plugin: `flutter_local_notifications` 19.5.0
- Uses: `timezone` package for scheduling
- Channel: `habit_reminders` (Android)
- Features: Daily scheduled reminders at user-specified times (IST timezone)

## Monitoring & Observability

**Error Tracking:**
- Not detected - No Sentry, Crashlytics, or similar error tracking in dependencies

**Logs:**
- Standard Flutter `debugPrint` / `print` statements (not using a structured logging framework)

## CI/CD & Deployment

**Hosting:**
- Firebase (implied by Firebase project configuration)
- Project ID: `habitu-tn88`

**CI Pipeline:**
- Not detected in codebase - No GitHub Actions, Bitrise, Codemagic, or similar

## Environment Configuration

**Firebase config stored in:**
- `lib/firebase_options.dart` - Contains API keys, app IDs, project IDs (committed to repo)
- Android: `android/app/google-services.json` (not in repo, referenced in firebase.json)
- iOS: Configured via Firebase console

**Required env vars / secrets:**
- Firebase API keys (stored in firebase_options.dart - not secrets in traditional sense)
- Project ID: `habitu-tn88`
- Messaging Sender ID: `608621636633`

## Webhooks & Callbacks

**Incoming:**
- FCM push messages - Handled by `firebase_messaging` background handler in `lib/main.dart`
- Notification tap callbacks - `NotificationService._onSelect()` handles notification response

**Outgoing:**
- FCM token registration - Token sent to Firestore via `saveFcmTokenToFirestore()` in `lib/services/fcm_service.dart`

---

*Integration audit: 2026-03-13*
