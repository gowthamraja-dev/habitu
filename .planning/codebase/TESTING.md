# Testing

## Current State
- Dart/Flutter automated tests are not present: there is no `test/` directory and no `*_test.dart` files in the repo.
- `flutter_test` is configured in `pubspec.yaml` under `dev_dependencies`, so the project is test-ready but currently unimplemented.
- iOS scaffold test target exists at `ios/RunnerTests/RunnerTests.swift` (default placeholder XCTest file).

## Available Validation Paths Today
- Static analysis: `flutter analyze` using rules from `analysis_options.yaml`.
- Runtime/manual validation via app flows:
  - Auth gate: `lib/screens/auth/auth_gate.dart`, `lib/screens/auth/login_screen.dart`
  - Setup gate and onboarding: `lib/screens/setup/setup_gate.dart`, `lib/screens/setup/unified_setup_screen.dart`
  - Habit management: `lib/screens/home_screen.dart`, `lib/screens/manage/manage_habits_screen.dart`, `lib/screens/manage/add_habits_screen.dart`
  - Notifications + push diagnostics UI: `lib/screens/settings/settings_screen.dart`

## Built-In Manual Test Hooks
- Local notification immediate send: `NotificationService.showTestNow` in `lib/services/notification_service.dart`, triggered from Settings (`Test local (now)` action in `lib/screens/settings/settings_screen.dart`).
- Delayed local notification: `NotificationService.scheduleTestInSeconds` in `lib/services/notification_service.dart`, triggered from Settings (`Test local (10s)`).
- Push token visibility/copy flow: `FcmService.getToken` and token display/copy actions in `lib/screens/settings/settings_screen.dart`.

## Highest-Value Automated Tests To Add First
- Model unit tests:
  - `lib/models/habit.dart`: `toMap`, `fromMap`, `copyWith(clearReminder: true)`, `reminderTimeOfDay`.
  - `lib/models/habit_meta.dart`: `fromMap` defaults and `matchesAgeRange`.
- Core utility tests:
  - `lib/core/ist_time.dart`: minute conversion boundaries and `formatMinutes` output.
- Service unit tests (with Firebase abstractions/mocks):
  - `lib/services/habit_service.dart`: unauthenticated behavior (`watchHabits` empty stream vs `StateError` paths), update timestamp behavior.
  - `lib/services/habits_meta_service.dart`: category grouping/title-casing.
- Widget tests:
  - `lib/screens/auth/auth_gate.dart`: loading/authenticated/unauthenticated branches.
  - `lib/screens/setup/setup_gate.dart`: setup-complete vs setup-required branch.
  - `lib/widgets/orbit_habit_card.dart`: long-press completion flow invokes callback.

## Suggested Test Layout
- `test/models/habit_test.dart`
- `test/models/habit_meta_test.dart`
- `test/core/ist_time_test.dart`
- `test/services/habit_service_test.dart`
- `test/services/habits_meta_service_test.dart`
- `test/widgets/auth_gate_test.dart`
- `test/widgets/setup_gate_test.dart`
- `test/widgets/orbit_habit_card_test.dart`

## Testing Risks to Account For
- Many services construct Firebase singletons internally (`FirebaseAuth.instance`, `FirebaseFirestore.instance`, `FirebaseMessaging.instance`), which increases mock/setup complexity in pure unit tests (`lib/services/auth_service.dart`, `lib/services/habit_service.dart`, `lib/services/fcm_service.dart`).
- Notification scheduling depends on plugin platform channels and timezone initialization (`lib/services/notification_service.dart`), so unit tests should isolate ID/time computation logic and keep plugin calls mocked/faked.
