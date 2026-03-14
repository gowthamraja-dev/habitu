# STRUCTURE

## Repository Layout
- `lib/` - Flutter/Dart application source
- `android/` - Android host app and manifest/channel config
- `ios/` - iOS host app
- `docs/` - project docs (`docs/FCM_SETUP.md`)
- `.planning/codebase/` - generated codebase mapping docs
- Root config: `pubspec.yaml`, `analysis_options.yaml`, `firebase.json`, `firestore.rules`

## Application Source Tree (`lib/`)

### Entrypoints and App Shell
- `lib/main.dart` - app bootstrap, Firebase init, FCM handlers, notification init
- `lib/app/app.dart` - `MaterialApp`, global navigator key, notification-open route handling
- `lib/firebase_options.dart` - FlutterFire-generated platform config

### Core Utilities
- `lib/core/app_constants.dart` - section IDs + age-group constants
- `lib/core/ist_time.dart` - IST timezone helpers and time conversion

### Domain Models
- `lib/models/habit.dart` - persisted user habit model
- `lib/models/habit_meta.dart` - habit catalog metadata model

### Services
- `lib/services/auth_service.dart` - Firebase Auth wrapper
- `lib/services/habit_service.dart` - Firestore CRUD + stream for `users/{uid}/habits`
- `lib/services/habits_meta_service.dart` - read/filter/group `habits_meta`
- `lib/services/user_prefs_service.dart` - setup completion flag in `users/{uid}`
- `lib/services/fcm_service.dart` - FCM token/permission/message stream helpers
- `lib/services/notification_service.dart` - local reminder schedule/cancel APIs

### Screens
- Auth:
  - `lib/screens/auth/auth_gate.dart`
  - `lib/screens/auth/login_screen.dart`
- Setup:
  - `lib/screens/setup/setup_gate.dart`
  - `lib/screens/setup/unified_setup_screen.dart`
  - `lib/screens/setup/age_selection.dart` (legacy path)
  - `lib/screens/setup/habits_selection.dart` (legacy path)
- Main/Home:
  - `lib/screens/home_screen.dart`
- Habit management:
  - `lib/screens/manage/manage_habits_screen.dart`
  - `lib/screens/manage/add_habits_screen.dart`
  - `lib/screens/manage/habit_form_sheet.dart`
  - `lib/screens/manage/habit_reminder_sheet.dart`
- Settings:
  - `lib/screens/settings/settings_screen.dart`

### Widgets
- `lib/widgets/orbit_habit_card.dart` - long-press completion interaction card
- `lib/widgets/fcm_token_registration.dart` - auth-scoped FCM token registration wrapper

## Platform Structure

### Android
- `android/app/src/main/AndroidManifest.xml` - notification permissions + default channel metadata
- `android/app/src/main/kotlin/com/example/habitu/MainActivity.kt` - channel creation (`habitu_default`)
- `android/app/build.gradle.kts` - Android app module build config
- `android/app/google-services.json` - Firebase Android app config

### iOS
- `ios/Runner/AppDelegate.swift` - iOS app delegate
- `ios/Runner/Info.plist` - iOS runtime settings
- `ios/Runner.xcodeproj/project.pbxproj` - Xcode project config

## Data/Infra Files
- `firestore.rules` - Firestore authz rules for user-scoped docs and read-only catalog
- `firebase.json` - Firebase CLI config and FlutterFire output mapping
- `docs/FCM_SETUP.md` - notification integration notes

## Dependency and Ownership Shape
- UI code is mostly feature-oriented by screen folder (`auth`, `setup`, `manage`, `settings`).
- Cross-feature business/data logic is centralized by technical concern in `lib/services/`.
- Shared constants and time policy live under `lib/core/` and are consumed broadly.
- No `test/` directory currently exists.
