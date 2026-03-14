# Codebase Concerns

**Analysis Date:** 2026-03-14

## Critical

### 1) User document overwrite can delete profile fields
- Concern: setup completion writes the entire user document without merge.
- Evidence: `lib/services/user_prefs_service.dart` uses `.set({_setupCompleteField: true})`.
- Why this matters: existing fields like `fcmToken` written by `lib/services/fcm_service.dart` can be lost.
- Fix direction: use `SetOptions(merge: true)` for setup updates.

### 2) Notification deep-link routing can throw on unknown routes
- Concern: push payload route is sent directly to named navigation, but app route table is not defined.
- Evidence: `lib/app/app.dart` calls `Navigator.of(context).pushNamed(route)`; same file `MaterialApp` has no `routes`/`onGenerateRoute`.
- Why this matters: a payload with any non-registered route can fail at runtime.
- Fix direction: validate route values and/or implement `onGenerateRoute` with safe fallback.

## High

### 3) Release builds are signed with debug config
- Concern: Android release type uses debug signing.
- Evidence: `android/app/build.gradle.kts` sets `signingConfig = signingConfigs.getByName("debug")` for `release`.
- Why this matters: not production-safe for store delivery and key management.
- Fix direction: add real release signing config and environment-based key handling.

### 4) Firestore rules are not versioned in repo
- Concern: no Firestore security rules file is present.
- Evidence: no `firestore.rules` found from project root; `firebase.json` does not reference Firestore rules.
- Why this matters: access policy is not auditable in source control.
- Fix direction: add `firestore.rules` and wire it in `firebase.json`.

### 5) No automated tests in project
- Concern: no unit/widget/integration tests exist.
- Evidence: no `test/` directory; test docs in `.planning/codebase/TESTING.md` confirm absence.
- Why this matters: high regression risk for auth, Firestore serialization, and notification scheduling.
- Fix direction: start with model/service tests for `lib/models/` and `lib/services/`.

## Medium

### 6) Expensive client-side metadata filtering
- Concern: all `habits_meta` docs are fetched then filtered in app code.
- Evidence: `lib/services/habits_meta_service.dart` calls `_col.get()` then loops with `matchesAgeRange(...)`.
- Why this matters: reads and latency scale poorly with metadata growth.
- Fix direction: remodel data/query strategy for server-side filtering.

### 7) Sequential writes in setup/add flows
- Concern: habit creation loops write one document at a time.
- Evidence: `lib/screens/setup/unified_setup_screen.dart`, `lib/screens/setup/habits_selection.dart`, and `lib/screens/manage/add_habits_screen.dart` each `await _habitService.create(...)` inside loops.
- Why this matters: slow onboarding/add flows and partial-write failure windows.
- Fix direction: batch writes (`WriteBatch`) or parallelized constrained writes with rollback handling.

### 8) Notification payload errors are silently swallowed
- Concern: notification tap payload parse failures are ignored.
- Evidence: empty catch block in `lib/services/notification_service.dart` (`catch (_) {}`).
- Why this matters: debugging routing/tap issues is difficult.
- Fix direction: log or surface parse failures.

### 9) Notification ID collision risk
- Concern: reminder IDs are derived from hash modulo int range.
- Evidence: `_notificationIdForHabit` in `lib/services/notification_service.dart` uses `habitId.hashCode.abs() % 0x7FFFFFFF`.
- Why this matters: collisions can overwrite/cancel the wrong reminder.
- Fix direction: persist a deterministic unique numeric ID per habit.

### 10) Setup gate has no explicit error state
- Concern: failed setup preference read is treated like loading forever.
- Evidence: `lib/screens/setup/setup_gate.dart` only checks `!snapshot.hasData` then shows spinner; no `snapshot.hasError` branch.
- Why this matters: transient backend issues can strand users on indefinite loading UI.
- Fix direction: add error UI + retry path.

### 11) Home “progress” is hardcoded, not data-backed
- Concern: UI shows static completion value and completion toast without persistence.
- Evidence: `lib/screens/home_screen.dart` hardcodes `"92%"`; completion action in `lib/widgets/orbit_habit_card.dart` only triggers callback/toast.
- Why this matters: misleading product behavior and unclear completion model.
- Fix direction: add completion fields/history to `lib/models/habit.dart` and persist updates.

### 12) Forced IST for all users
- Concern: notifications and displayed reminder times always use IST.
- Evidence: `lib/services/notification_service.dart` forces `tz.setLocalLocation(IstTime.location())`; `lib/core/ist_time.dart` hardcodes `Asia/Kolkata`.
- Why this matters: incorrect reminder timing for non-IST users.
- Fix direction: store user timezone or use device timezone with migration strategy.

## Low / Cleanup

### 13) Font family reference may not be bundled
- Concern: UI references `Satoshi` font without font asset configuration.
- Evidence: `lib/widgets/orbit_habit_card.dart` sets `fontFamily: 'Satoshi'`; `pubspec.yaml` has no custom `fonts:` entry.
- Why this matters: inconsistent rendering across devices.
- Fix direction: declare bundled font assets or remove custom family.

### 14) Stale and inconsistent docs
- Concern: project docs no longer describe actual implementation.
- Evidence: `README.md` is default Flutter boilerplate; `docs/FCM_SETUP.md` says no local notifications while `pubspec.yaml` and `lib/services/notification_service.dart` actively use `flutter_local_notifications`.
- Why this matters: onboarding and operational confusion.
- Fix direction: align docs to current architecture and flows.

### 15) Dead/legacy setup artifacts still present
- Concern: unused constants/dependencies and legacy screens remain.
- Evidence: `lib/core/app_constants.dart` defines `kSetupCompleteKey` not used; `pubspec.yaml` includes `shared_preferences` but app writes setup status via Firestore in `lib/services/user_prefs_service.dart`; `lib/screens/setup/age_selection.dart` and `lib/screens/setup/habits_selection.dart` are not used by current gate flow in `lib/screens/setup/setup_gate.dart`.
- Why this matters: maintenance noise and confusion about canonical setup path.
- Fix direction: remove or clearly mark deprecated paths.

### 16) Platform support intentionally incomplete but uncaptured as product constraint
- Concern: web/desktop Firebase options throw unsupported errors.
- Evidence: `lib/firebase_options.dart` throws for web, macOS, Windows, Linux.
- Why this matters: accidental multi-platform builds fail late.
- Fix direction: document supported platforms and enforce in CI/build scripts.

## Suggested Priority Order
1. Prevent user-doc field loss (`lib/services/user_prefs_service.dart`).
2. Harden notification routing (`lib/app/app.dart` + route table/fallbacks).
3. Add Firestore rules to repo and deployment config (`firebase.json` + `firestore.rules`).
4. Introduce baseline tests for models/services.
5. Address query/write scalability in setup and catalog flows.

---

*Concerns audit refreshed: 2026-03-14*
