# Coding Conventions

## Scope
- This document reflects the current Flutter/Dart app code under `lib/` plus platform shells in `android/` and `ios/`.
- Lint baseline is `analysis_options.yaml` (`include: package:flutter_lints/flutter.yaml`).

## Project Layout
- App entry and bootstrap live in `lib/main.dart` and `lib/app/app.dart`.
- Core constants/time helpers are in `lib/core/app_constants.dart` and `lib/core/ist_time.dart`.
- Firestore/auth domain models are in `lib/models/habit.dart` and `lib/models/habit_meta.dart`.
- Firebase/data/notification services are in `lib/services/`.
- UI is split by feature in `lib/screens/` (`auth/`, `setup/`, `manage/`, `settings/`) plus reusable widgets in `lib/widgets/`.

## Naming and File Patterns
- Files use `snake_case` (examples: `lib/services/habit_service.dart`, `lib/screens/home_screen.dart`).
- Types use `PascalCase` (`HabitService`, `UnifiedSetupScreen`, `OrbitHabitCard`).
- Private members/types use leading `_` (`_habitsCollection`, `_SettingsScreenState`, `_SectionTitle`).
- Screen files generally end with `_screen.dart`; service files generally end with `_service.dart`.

## Imports
- Imports are package-style, including local code (`package:habitu/...`) rather than relative paths.
- Typical ordering in files: Dart SDK imports, third-party package imports, then `package:habitu/...` imports.
- Example files: `lib/widgets/orbit_habit_card.dart`, `lib/services/notification_service.dart`, `lib/main.dart`.

## Data and Serialization Conventions
- Firestore mappers are explicit `toMap`/`fromMap` methods on model classes (`lib/models/habit.dart`, `lib/models/habit_meta.dart`).
- `Habit` stores reminder time as minutes since midnight (`reminderTimeMinutes`) with conversion helpers in `lib/core/ist_time.dart`.
- `HabitMeta` uses compact Firestore keys (`n`, `c`, `d`, `amin`, `amax`) and normalizes category casing in `lib/models/habit_meta.dart`.

## Service Conventions
- Services generally wrap SDK singletons as instance fields (examples in `lib/services/habit_service.dart`, `lib/services/auth_service.dart`, `lib/services/fcm_service.dart`).
- `NotificationService` is an explicit singleton (`factory NotificationService() => _instance`) in `lib/services/notification_service.dart`.
- Auth-scoped services validate user context and may throw `StateError` when called without an authenticated user (`lib/services/habit_service.dart`).

## Async and UI-State Conventions
- Async UI methods use `setState` before/after awaits and guard UI updates with `if (!mounted) return` (examples: `lib/screens/auth/login_screen.dart`, `lib/screens/settings/settings_screen.dart`, `lib/screens/setup/unified_setup_screen.dart`).
- Setup/auth routing relies on builders over auth/profile state: `StreamBuilder` in `lib/screens/auth/auth_gate.dart`, `FutureBuilder` in `lib/screens/setup/setup_gate.dart`.
- Navigation uses imperative `Navigator` APIs (`push`, `pushAndRemoveUntil`, modal sheets/dialogs) across `lib/screens/`.

## Error Handling Conventions
- Expected SDK failures are caught as specific exception types where useful (`FirebaseAuthException` in `lib/screens/auth/login_screen.dart`, `PlatformException` in `lib/services/notification_service.dart`).
- Non-critical parsing/notification payload errors may be swallowed in tight callbacks (`catch (_) {}` in `lib/services/notification_service.dart`).
- Null-return pattern is used for not-found data (`Future<Habit?> getById` in `lib/services/habit_service.dart`).

## Firebase and Notification Conventions
- Firebase initializes at startup in `lib/main.dart`; background FCM handler is a top-level `@pragma('vm:entry-point')` function.
- FCM token save pattern is merge-write to `users/{uid}` (`lib/services/fcm_service.dart`).
- Local reminders are timezone-forced to IST (`Asia/Kolkata`) via `timezone` setup in `lib/services/notification_service.dart` and `lib/core/ist_time.dart`.

## Style and Formatting
- Code uses standard Flutter formatting (2-space indentation, trailing commas in multiline widget trees).
- `const` constructors/widgets are used where practical (examples throughout `lib/screens/home_screen.dart` and `lib/screens/auth/login_screen.dart`).
- Public API surfaces frequently include concise doc comments (`///`) in models/services/core helpers.
  final String name;
  // ...
  
  const Habit({ required this.id, required this.name, ... });
  
  Map<String, dynamic> toMap() { ... }
  
  factory Habit.fromMap(String id, Map<String, dynamic> map) { ... }
  
  Habit copyWith({ ... }) { ... }
}
```

---

*Convention analysis: 2026-03-13*
