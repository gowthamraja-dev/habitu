# STACK

## Snapshot
- Product type: Flutter mobile app (Android + iOS) with Firebase backend services.
- Primary language: Dart (`lib/`).
- Mobile host languages: Kotlin (`android/app/src/main/kotlin/com/example/habitu/MainActivity.kt`) and Swift (`ios/Runner/AppDelegate.swift`).
- Backend model: Firebase-managed services (Auth, Firestore, FCM) consumed directly from client.

## Runtime Platforms
- Flutter runtime bootstrap: `lib/main.dart`
- Android app shell: `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`
- iOS app shell: `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift`

## Application Layering (Dart)
- Entrypoint and app wiring: `lib/main.dart`, `lib/app/app.dart`
- UI screens: `lib/screens/`
- Reusable UI widgets: `lib/widgets/`
- Domain models: `lib/models/habit.dart`, `lib/models/habit_meta.dart`
- Service layer: `lib/services/auth_service.dart`, `lib/services/habit_service.dart`, `lib/services/habits_meta_service.dart`, `lib/services/user_prefs_service.dart`, `lib/services/fcm_service.dart`, `lib/services/notification_service.dart`
- Core utilities/constants: `lib/core/app_constants.dart`, `lib/core/ist_time.dart`

## Dependency Stack
Source of truth: `pubspec.yaml`

### Core App
- `flutter`
- `cupertino_icons`

### Firebase
- `firebase_core` for app bootstrap (`lib/main.dart`, `lib/firebase_options.dart`)
- `firebase_auth` for authentication (`lib/services/auth_service.dart`)
- `cloud_firestore` for persistent user/habit data (`lib/services/habit_service.dart`, `lib/services/habits_meta_service.dart`, `lib/services/user_prefs_service.dart`, `lib/services/fcm_service.dart`)
- `firebase_messaging` for remote push (`lib/main.dart`, `lib/services/fcm_service.dart`)

### Local Device Services
- `shared_preferences` declared in `pubspec.yaml` (not yet consumed in `lib/`)
- `flutter_local_notifications` for local scheduling and foreground display (`lib/services/notification_service.dart`)
- `timezone` for deterministic IST scheduling (`lib/core/ist_time.dart`, `lib/services/notification_service.dart`)

## Build and Tooling
- Dart SDK constraint: `^3.7.2` in `pubspec.yaml`
- Lints: `flutter_lints` with config in `analysis_options.yaml`
- Android Gradle (KTS): `android/build.gradle.kts`, `android/settings.gradle.kts`, `android/app/build.gradle.kts`
- Firebase Android plugin: `com.google.gms.google-services` in `android/app/build.gradle.kts`
- Android desugaring for Java APIs: `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` in `android/app/build.gradle.kts`
- iOS project files: `ios/Runner.xcodeproj/project.pbxproj`, `ios/Runner.xcworkspace/`

## Data and Security Baseline
- Firestore security rules: `firestore.rules`
- Firebase project mapping/config: `firebase.json`, `lib/firebase_options.dart`, `android/app/google-services.json`

## Operational Notes
- Firebase is configured for Android and iOS, not web/desktop (`lib/firebase_options.dart` throws for unsupported platforms).
- Time behavior is intentionally fixed to IST inside app logic (`lib/core/ist_time.dart`).
- Notification strategy combines FCM + local notifications (`lib/main.dart`, `lib/services/fcm_service.dart`, `lib/services/notification_service.dart`).
