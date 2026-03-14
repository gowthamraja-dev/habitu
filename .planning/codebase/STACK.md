# Technology Stack

**Last verified:** 2026-03-14

## 1. Primary Runtime and Languages

- **Dart** (`^3.7.2`) for app code and domain logic in `lib/`.
- **Flutter** (Material app) as the UI/runtime framework, app entry at `lib/main.dart` and root widget in `lib/app/app.dart`.
- **Kotlin** for Android host code in `android/app/src/main/kotlin/com/example/habitu/MainActivity.kt`.
- **Swift** for iOS host code in `ios/Runner/AppDelegate.swift`.

## 2. Package and Dependency Management

- Dependency manifest: `pubspec.yaml`.
- Lockfile: `pubspec.lock`.
- Package manager/workflow: `flutter pub`.

### Runtime dependencies (from `pubspec.yaml`)

- `firebase_core` (`^4.4.0`) - Firebase bootstrap.
- `firebase_auth` (`^6.1.4`) - authentication.
- `cloud_firestore` (`^6.1.2`) - primary data store.
- `firebase_messaging` (`^16.1.1`) - FCM push and token APIs.
- `flutter_local_notifications` (`^19.5.0`) - local notifications and scheduled reminders.
- `timezone` (`^0.10.1`) - timezone-aware scheduling.
- `shared_preferences` (`^2.2.2`) - declared; no active import usage in `lib/`.
- `cupertino_icons` (`^1.0.8`) - icon set.

### Dev dependencies

- `flutter_test` (SDK).
- `flutter_lints` (`^5.0.0`).

## 3. App Architecture Shape

- **UI/screens:** `lib/screens/` (`auth`, `setup`, `home`, `manage`, `settings`).
- **Services/data access:** `lib/services/` (`auth_service.dart`, `habit_service.dart`, `habits_meta_service.dart`, `user_prefs_service.dart`, `fcm_service.dart`, `notification_service.dart`).
- **Domain models:** `lib/models/habit.dart`, `lib/models/habit_meta.dart`.
- **Shared constants/helpers:** `lib/core/app_constants.dart`, `lib/core/ist_time.dart`.
- **Reusable widgets:** `lib/widgets/`.

## 4. Build Toolchain

### Android

- Gradle wrapper: `android/gradle/wrapper/gradle-wrapper.properties` (`gradle-8.10.2`).
- Android Gradle Plugin: `com.android.application` `8.7.0` in `android/settings.gradle.kts`.
- Kotlin Gradle plugin: `org.jetbrains.kotlin.android` `2.1.0` in `android/settings.gradle.kts`.
- Google services plugin: `com.google.gms.google-services` `4.3.15` in `android/build.gradle.kts` / `android/settings.gradle.kts`.
- Java/Kotlin target: Java 11 in `android/app/build.gradle.kts`.
- Firebase Android BOM: `34.9.0` in `android/app/build.gradle.kts`.

### iOS

- Flutter iOS host app under `ios/Runner/` with `FlutterAppDelegate` integration in `ios/Runner/AppDelegate.swift`.

## 5. Firebase Configuration Footprint

- Generated FlutterFire options: `lib/firebase_options.dart`.
- FlutterFire project mapping: `firebase.json`.
- Android app config file present: `android/app/google-services.json`.
- Firebase init and messaging bootstrap in `lib/main.dart`.

## 6. Platform Scope and Constraints

- Configured Firebase platforms in code: **Android + iOS** (`lib/firebase_options.dart`).
- Web/macOS/windows/linux are intentionally unsupported in current Firebase options (`UnsupportedError` paths in `lib/firebase_options.dart`).

## 7. Linting/Static Analysis

- Analyzer config: `analysis_options.yaml`.
- Baseline lint profile: `package:flutter_lints/flutter.yaml` (via include).
