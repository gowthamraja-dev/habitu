# Codebase Conventions

## Scope
This document records conventions currently used in this Flutter app and the expected patterns for new code.

## Project Layout
- App bootstrap and global navigation live in `lib/main.dart` and `lib/app/app.dart`.
- Shared constants and time utilities live in `lib/core/app_constants.dart` and `lib/core/ist_time.dart`.
- Firestore-backed domain models live in `lib/models/habit.dart` and `lib/models/habit_meta.dart`.
- Firebase/Firestore/device integration logic lives in `lib/services/` (`lib/services/auth_service.dart`, `lib/services/habit_service.dart`, `lib/services/habits_meta_service.dart`, `lib/services/user_prefs_service.dart`, `lib/services/fcm_service.dart`, `lib/services/notification_service.dart`).
- UI route composition lives in `lib/screens/` with feature folders: `lib/screens/auth/`, `lib/screens/setup/`, `lib/screens/manage/`, `lib/screens/settings/`.
- Shared UI primitives/components live in `lib/widgets/` (`lib/widgets/orbit_habit_card.dart`, `lib/widgets/fcm_token_registration.dart`).

## Naming and File Rules
- Use `snake_case.dart` filenames (`setup_gate.dart`, `habit_service.dart`).
- Name classes in `UpperCamelCase` (`HabitService`, `UnifiedSetupScreen`).
- Name methods/fields in `lowerCamelCase` (`watchHabits`, `requestPermission`).
- Prefix private library members with `_` (`_habitsCollection`, `_loadToken`, `_selectedIds`).
- Keep one primary class per file unless helper widgets are file-private to the same screen (for example `_SectionHeader` in `lib/screens/home_screen.dart`).

## UI Conventions
- Use dark-theme-first styling with explicit colors in screens (`Color(0xFF0A0A0C)` appears across `lib/screens/*`).
- Use `StatelessWidget` when no local mutable state is needed (`HomeScreen`, `SetupGate`, `AuthGate`).
- Use `StatefulWidget` for async calls, form control, or selection state (`LoginScreen`, `UnifiedSetupScreen`, `SettingsScreen`).
- Use async data builders at boundaries:
- `StreamBuilder` for real-time Firestore/auth streams (`lib/screens/home_screen.dart`, `lib/screens/manage/manage_habits_screen.dart`, `lib/screens/auth/auth_gate.dart`).
- `FutureBuilder` for one-shot reads (`lib/screens/setup/setup_gate.dart`).
- Keep modal workflows in dedicated bottom-sheet widgets (`lib/screens/manage/habit_form_sheet.dart`, `lib/screens/manage/habit_reminder_sheet.dart`).

## Service and Data Access Conventions
- Keep Firebase APIs behind service classes; screens should call services rather than raw SDK APIs.
- Enforce auth preconditions in services (`lib/services/habit_service.dart` throws `StateError` when no user for collection operations).
- Persist Firestore timestamps using `Timestamp.fromDate(...)` on write and `Timestamp.toDate()` on read (`lib/models/habit.dart`).
- Use `SetOptions(merge: true)` when writing additive user profile fields (`saveFcmTokenToFirestore` in `lib/services/fcm_service.dart`).
- Keep reminder time storage normalized as minutes since midnight; convert at edges with `IstTime` (`lib/core/ist_time.dart`, `lib/models/habit.dart`, `lib/screens/manage/habit_reminder_sheet.dart`).

## Async and State Safety
- Guard `setState` and navigation with `if (!mounted) return;` after awaits (common in `lib/screens/auth/login_screen.dart`, `lib/screens/settings/settings_screen.dart`, `lib/screens/setup/unified_setup_screen.dart`).
- Keep loading/error state explicit (`_loading`, `_error` patterns across setup/manage/settings screens).
- Prefer user-visible recovery actions on failures (retry buttons and snack bars in `lib/screens/setup/habits_selection.dart`, `lib/screens/settings/settings_screen.dart`).

## Navigation Conventions
- App-level gate flow is: `AuthGate` -> `SetupGate` -> `HomeScreen`.
- Use `MaterialPageRoute` for most in-app navigation (`lib/screens/home_screen.dart`, `lib/screens/manage/manage_habits_screen.dart`).
- Use `pushAndRemoveUntil` after setup completion to prevent returning to onboarding (`lib/screens/setup/unified_setup_screen.dart`, `lib/screens/setup/habits_selection.dart`).
- Keep notification-open routing centralized via `HabituApp.handleNotificationOpen` in `lib/app/app.dart`.

## Linting and Static Analysis
- Analyzer config extends `package:flutter_lints/flutter.yaml` via `analysis_options.yaml`.
- Run `flutter analyze` before merging behavior changes.
- Prefer fixing warnings in code instead of adding ignore directives.

## Platform and Config Boundaries
- Firebase client config belongs in `lib/firebase_options.dart`, `android/app/google-services.json`, and platform runners under `ios/Runner/`.
- Firestore rule updates live in `firestore.rules` and project-level Firebase config in `firebase.json`.
- FCM setup/operational notes should stay in `docs/FCM_SETUP.md`.

## Practical Checklist for New Code
- Add or update a service in `lib/services/` for any new backend/device integration.
- Add or update models in `lib/models/` when Firestore schema changes.
- Keep screens focused on composition/state; avoid embedding raw persistence logic in widgets.
- Keep all new file-path references and imports package-qualified (`package:habitu/...`) as used across `lib/`.
