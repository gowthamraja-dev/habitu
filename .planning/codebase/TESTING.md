# Testing Strategy

## Current State
- There is currently no `test/` or `integration_test/` directory in this repository.
- `flutter_test` is available in `pubspec.yaml`, so test infrastructure can be added without dependency changes.
- Existing automated checks today are mainly static analysis (`analysis_options.yaml` + `flutter analyze`).

## Quality Gates to Use Now
- Run static analysis on every change:
- `flutter analyze`
- Run formatting checks before commit:
- `dart format lib`

## Recommended Test Layout
Create these directories for scalable coverage:
- `test/models/`
- `test/core/`
- `test/services/`
- `test/widgets/`
- `test/screens/`
- `integration_test/`

## Unit Test Priorities

### Models and Mapping
- `test/models/habit_test.dart` for:
- `Habit.toMap`/`Habit.fromMap` round-trips from `lib/models/habit.dart`.
- `Habit.copyWith` behavior including `clearReminder`.
- Reminder conversion helper `reminderTimeOfDay`.
- `test/models/habit_meta_test.dart` for:
- `HabitMeta.fromMap` defaults and lowercasing logic.
- `matchesAgeRange` overlap correctness for boundary ages.

### Core Utilities
- `test/core/ist_time_test.dart` for:
- `IstTime.toMinutes` and `IstTime.fromMinutes` round-trips from `lib/core/ist_time.dart`.
- Clamping behavior for out-of-range minute values.
- `IstTime.formatMinutes` stable AM/PM formatting.

### Service Logic (with fakes/mocks)
- `test/services/habits_meta_service_test.dart` for:
- `groupByCategory` and `getCategories` from `lib/services/habits_meta_service.dart`.
- `test/services/notification_service_test.dart` for:
- notification ID stability and scheduling fallback behavior in `lib/services/notification_service.dart`.
- `test/services/habit_service_test.dart` for:
- auth precondition behavior and CRUD mapping in `lib/services/habit_service.dart`.

## Widget and Screen Test Priorities
- `test/screens/auth/auth_gate_test.dart`:
- unauthenticated path renders `LoginScreen`; authenticated path renders `SetupGate` from `lib/screens/auth/auth_gate.dart`.
- `test/screens/setup/setup_gate_test.dart`:
- setup complete vs incomplete rendering logic from `lib/screens/setup/setup_gate.dart`.
- `test/screens/manage/habit_form_sheet_test.dart`:
- validates save callback values and field behavior from `lib/screens/manage/habit_form_sheet.dart`.
- `test/widgets/orbit_habit_card_test.dart`:
- long-press completion callback behavior from `lib/widgets/orbit_habit_card.dart`.

## Integration Test Priorities
- `integration_test/auth_to_home_flow_test.dart`:
- login -> setup gate -> home route flow anchored by `lib/app/app.dart` and `lib/screens/auth/auth_gate.dart`.
- `integration_test/habit_management_flow_test.dart`:
- add/edit/delete reminder flows through `lib/screens/manage/manage_habits_screen.dart`.
- `integration_test/notification_smoke_test.dart`:
- permission prompt and local-notification test action from `lib/screens/settings/settings_screen.dart`.

## Firebase Test Approach
- For unit/widget tests, isolate Firebase dependencies behind service seams and inject fakes where possible.
- For integration tests that require Firestore/Auth behavior, run against Firebase Emulator Suite with project config from `firebase.json` and rules in `firestore.rules`.
- Keep FCM-specific behavior mostly unit-tested at service boundaries (`lib/services/fcm_service.dart`) and validated manually on-device for token/permission specifics.

## Practical Commands
- Analyze: `flutter analyze`
- Run unit/widget tests: `flutter test`
- Run integration tests (after adding `integration_test/`): `flutter test integration_test`

## Coverage Plan (Order of Implementation)
1. Add deterministic model/core unit tests (`test/models/`, `test/core/`).
2. Add pure-service tests that do not require live Firebase (`test/services/`).
3. Add screen/widget tests around gate logic and form behavior (`test/screens/`, `test/widgets/`).
4. Add critical happy-path integration tests for auth/setup/manage flows (`integration_test/`).
