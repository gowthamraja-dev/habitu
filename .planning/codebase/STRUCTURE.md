# Codebase Structure

**Analysis Date:** 2026-03-14

## Repository Layout

```text
habitu/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── app/
│   │   └── app.dart
│   ├── core/
│   │   ├── app_constants.dart
│   │   └── ist_time.dart
│   ├── models/
│   │   ├── habit.dart
│   │   └── habit_meta.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── auth_gate.dart
│   │   │   └── login_screen.dart
│   │   ├── setup/
│   │   │   ├── setup_gate.dart
│   │   │   ├── unified_setup_screen.dart
│   │   │   ├── age_selection.dart
│   │   │   └── habits_selection.dart
│   │   ├── manage/
│   │   │   ├── manage_habits_screen.dart
│   │   │   ├── add_habits_screen.dart
│   │   │   ├── habit_form_sheet.dart
│   │   │   └── habit_reminder_sheet.dart
│   │   ├── settings/
│   │   │   └── settings_screen.dart
│   │   └── home_screen.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── habit_service.dart
│   │   ├── habits_meta_service.dart
│   │   ├── user_prefs_service.dart
│   │   ├── fcm_service.dart
│   │   └── notification_service.dart
│   └── widgets/
│       ├── orbit_habit_card.dart
│       └── fcm_token_registration.dart
├── docs/
│   └── FCM_SETUP.md
├── android/
├── ios/
├── pubspec.yaml
├── pubspec.lock
└── analysis_options.yaml
```

## Module Map

### App bootstrap and shell
- `lib/main.dart`: process bootstrap, Firebase init, FCM lifecycle hooks, local notification init.
- `lib/app/app.dart`: root `MaterialApp`, navigator key, notification route forwarding.
- `lib/firebase_options.dart`: generated Firebase configuration.

### Core utilities
- `lib/core/app_constants.dart`: habit section ids and age-group definitions.
- `lib/core/ist_time.dart`: IST helpers for reminder time conversion/formatting.

### Models
- `lib/models/habit.dart`: Firestore-backed habit entity + serialization.
- `lib/models/habit_meta.dart`: catalog metadata entity (`n/c/d/amin/amax`).

### Services
- `lib/services/auth_service.dart`: Firebase Auth wrapper.
- `lib/services/habit_service.dart`: user-scoped habit CRUD and stream query.
- `lib/services/habits_meta_service.dart`: habit catalog fetch and category grouping.
- `lib/services/user_prefs_service.dart`: setup completion read/write in Firestore user doc.
- `lib/services/fcm_service.dart`: permission/token/open-message API + token persistence helper.
- `lib/services/notification_service.dart`: local notification init, scheduling, cancellation, test notifications.

### Screens and flows
- Auth flow: `lib/screens/auth/auth_gate.dart`, `lib/screens/auth/login_screen.dart`.
- Setup gate + active setup UI: `lib/screens/setup/setup_gate.dart`, `lib/screens/setup/unified_setup_screen.dart`.
- Main app screen: `lib/screens/home_screen.dart`.
- Manage feature: `lib/screens/manage/manage_habits_screen.dart`, `lib/screens/manage/add_habits_screen.dart`, `lib/screens/manage/habit_form_sheet.dart`, `lib/screens/manage/habit_reminder_sheet.dart`.
- Settings/notification diagnostics: `lib/screens/settings/settings_screen.dart`.

### Reusable widgets
- `lib/widgets/orbit_habit_card.dart`: long-press completion visual component.
- `lib/widgets/fcm_token_registration.dart`: authenticated token registration wrapper.

## Active Entry Paths

- App launch: `lib/main.dart` -> `lib/app/app.dart` -> `lib/screens/auth/auth_gate.dart`.
- Signed-in path: `lib/screens/auth/auth_gate.dart` -> `lib/screens/setup/setup_gate.dart` -> (`lib/screens/setup/unified_setup_screen.dart` or `lib/screens/home_screen.dart`).
- Manage path: `lib/screens/home_screen.dart` -> `lib/screens/manage/manage_habits_screen.dart` -> add/edit/reminder sheets.

## Data Ownership by File Area

- Firestore user habit records are read/written through `lib/services/habit_service.dart`.
- Firestore setup/user flags are read/written through `lib/services/user_prefs_service.dart` and `lib/services/fcm_service.dart`.
- FCM token lifecycle is coordinated by `lib/widgets/fcm_token_registration.dart` + `lib/services/fcm_service.dart`.
- Reminder scheduling state is coordinated by `lib/screens/manage/habit_reminder_sheet.dart` + `lib/services/notification_service.dart`.

## Native and Platform Files

- Android manifest and permissions: `android/app/src/main/AndroidManifest.xml`.
- Android notification channel: `android/app/src/main/kotlin/com/example/habitu/MainActivity.kt`.
- Android Firebase/Gradle wiring: `android/app/build.gradle.kts`, `android/app/google-services.json`.
- iOS bootstrap: `ios/Runner/AppDelegate.swift`.

## Notable Legacy or Secondary Paths

- Legacy onboarding screens remain in tree but are not used by gate routing:
  - `lib/screens/setup/age_selection.dart`
  - `lib/screens/setup/habits_selection.dart`
- Supporting documentation exists under `docs/`, including `docs/FCM_SETUP.md`.

## Conventions in This Repository

- File naming is `snake_case.dart`.
- Services are flat under `lib/services/`.
- Feature screens are grouped by subdirectory under `lib/screens/` when the feature has multiple files.
- No dedicated test directory currently exists (`test/` not present in repository tree).
