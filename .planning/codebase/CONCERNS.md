# CONCERNS

## Scope
- Snapshot based on current repository state under `lib/`, platform configs under `android/` and `ios/`, plus docs/config files.
- Focus here is production risk, data integrity, operability, and maintainability.

## Critical

### 1) User document overwrite risk (can drop fields like FCM token)
- Evidence: `UserPrefsService.setSetupComplete()` uses `set({'setupComplete': true})` without merge in `lib/services/user_prefs_service.dart`.
- Related writes use merge and expect shared fields in the same document (`fcmToken`, `fcmTokenUpdatedAt`) in `lib/services/fcm_service.dart`.
- Why this matters: completing setup can replace the entire `users/{uid}` document and remove previously stored fields.
- Recommended fix:
  - Change write to merge mode in `lib/services/user_prefs_service.dart`.
  - Standardize user-profile writes through one service API to avoid accidental full-document replacement.

### 2) No automated tests for core flows
- Evidence: there is no `test/` directory in repo; core logic is in `lib/services/*.dart` and multi-step flows are in `lib/screens/setup/unified_setup_screen.dart` and `lib/screens/manage/*.dart`.
- Why this matters: auth, Firestore CRUD, setup gating, and notification scheduling can regress silently.
- Recommended fix:
  - Add unit tests for `Habit`, `HabitMeta`, `IstTime`, and services in `lib/services/`.
  - Add widget/integration tests for `AuthGate` -> `SetupGate` -> `HomeScreen` path (`lib/screens/auth/auth_gate.dart`, `lib/screens/setup/setup_gate.dart`, `lib/screens/home_screen.dart`).

## High

### 3) Setup/add flows can create duplicate habits
- Evidence:
  - Setup completion loops and creates habits directly from selected metadata in `lib/screens/setup/unified_setup_screen.dart`.
  - Add flow also creates selected catalog habits directly in `lib/screens/manage/add_habits_screen.dart`.
  - No dedupe check by name/meta id before create in `lib/services/habit_service.dart`.
- Why this matters: users can accumulate duplicate habits across setup/add operations, reducing data quality and UX clarity.
- Recommended fix:
  - Persist source metadata id on `Habit` model in `lib/models/habit.dart`.
  - Check existing habits before create in `lib/services/habit_service.dart` or perform idempotent upsert logic.

### 4) Notification-open routing is fragile
- Evidence: `HabituApp.handleNotificationOpen()` calls `Navigator.pushNamed(route)` from FCM payload in `lib/app/app.dart`, but `MaterialApp` in the same file has no named route table.
- Why this matters: payload route values can trigger unknown-route runtime failures or no-op behavior.
- Recommended fix:
  - Define `routes` / `onGenerateRoute` in `lib/app/app.dart`.
  - Validate and whitelist route values before navigation.

### 5) FCM token exposed via production `print`
- Evidence: `print('FCM Token: $token')` in `lib/widgets/fcm_token_registration.dart`; also reported by `flutter analyze` as `avoid_print`.
- Why this matters: token leakage in device logs is a security/privacy concern and noisy in production diagnostics.
- Recommended fix:
  - Remove print or gate behind debug-only logging in `lib/widgets/fcm_token_registration.dart`.

## Medium

### 6) README and setup docs are out of sync with implementation
- Evidence:
  - `README.md` is still default Flutter template.
  - `docs/FCM_SETUP.md` states no local notification plugin, but repo uses `flutter_local_notifications` in `pubspec.yaml` and `lib/services/notification_service.dart`.
- Why this matters: onboarding and operations are error-prone when docs do not match current behavior.
- Recommended fix:
  - Replace `README.md` with real setup/run/deploy instructions.
  - Update `docs/FCM_SETUP.md` to reflect current hybrid FCM + local notifications implementation.

### 7) Firestore reads are broad for metadata catalog
- Evidence: `HabitsMetaService.fetchForAgeRange()` reads full `habits_meta` collection then filters in app (`lib/services/habits_meta_service.dart`).
- Why this matters: cost and latency scale linearly with catalog size.
- Recommended fix:
  - Move filtering server-side with query constraints and required indexes.
  - Consider caching or paginating catalog reads for startup flows.

### 8) Tight sequential writes in setup/add can be slow on weak networks
- Evidence:
  - Per-item awaited writes in loops in `lib/screens/setup/unified_setup_screen.dart` and `lib/screens/manage/add_habits_screen.dart`.
- Why this matters: long wait times and partial completion risk if mid-loop failure occurs.
- Recommended fix:
  - Use Firestore batch writes in `lib/services/habit_service.dart`.
  - Return structured result for partial failures and UI retry behavior.

## Low

### 9) Analyzer config is mostly default and not enforcing stricter safeguards
- Evidence: `analysis_options.yaml` includes `flutter_lints` defaults without additional project-specific rules.
- Why this matters: weaker guardrails for async error handling, production logging, and API misuse.
- Recommended fix:
  - Enable stricter lint set (for example, disallow `print`, require `const` where possible, and tighten async style rules).

## Verification Notes
- Static analysis run (`flutter analyze`) currently reports 2 info-level issues:
  - Deprecated `DropdownButtonFormField.value` usage in `lib/screens/manage/habit_form_sheet.dart`.
  - Production `print` in `lib/widgets/fcm_token_registration.dart`.
