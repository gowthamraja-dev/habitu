# Technology Stack

**Analysis Date:** 2026-03-13

## Languages

**Primary:**
- Dart 3.7.2 - All application code (Flutter framework)

**Platform-Specific:**
- Kotlin - Android native code
- Swift - iOS native code

## Runtime

**Environment:**
- Flutter SDK - Cross-platform UI framework
- Dart VM - Runtime for Dart code

**Package Manager:**
- `flutter pub` - Dart package manager
- Lockfile: `pubspec.lock` (present)

## Frameworks

**Core:**
- Flutter 3.x - Cross-platform mobile UI framework
- Material Design 3 - UI components

**Firebase (Backend-as-a-Service):**
- firebase_core 4.4.0 - Firebase initialization
- firebase_auth 6.1.4 - Authentication
- cloud_firestore 6.1.2 - NoSQL database
- firebase_messaging 16.1.1 - Push notifications (FCM)

**Local Storage:**
- shared_preferences 2.2.2 - Key-value local storage
- flutter_local_notifications 19.5.0 - Local push notifications
- timezone 0.10.1 - Timezone handling for scheduling

**Icons:**
- cupertino_icons 1.0.8 - iOS-style icons

## Key Dependencies

**Critical:**
- firebase_core - Required for all Firebase services initialization
- firebase_auth - User authentication (email/password)
- cloud_firestore - User data persistence (habits, preferences)
- firebase_messaging - Cloud messaging for push notifications
- flutter_local_notifications - Local notification scheduling

**Infrastructure:**
- shared_preferences - Local key-value storage for user preferences
- timezone - IST timezone handling for habit reminders
- flutter_local_notifications - Scheduled daily reminders

## Configuration

**Environment:**
- Firebase configuration: `lib/firebase_options.dart` - Contains API keys and project IDs
- Firebase project ID: `habitu-tn88`
- Platform configs: `android/app/google-services.json` (Android), Firebase console (iOS)

**Build:**
- Flutter project configured via `pubspec.yaml`
- Dart analyzer: `analysis_options.yaml` (uses flutter_lints 5.0.0)

## Platform Requirements

**Development:**
- Flutter SDK 3.x
- Dart SDK 3.7.2+
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

**Production:**
- Android APK/AAB
- iOS IPA
- Firebase project (habitu-tn88)

---

*Stack analysis: 2026-03-13*
