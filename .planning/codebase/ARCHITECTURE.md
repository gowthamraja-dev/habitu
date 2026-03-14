# ARCHITECTURE

## System Overview
`habitu` is a Flutter mobile app (Android/iOS) for authenticated habit setup, habit management, and reminder notifications.

Primary architecture style is **UI + service layer over Firebase**:
- UI/state is implemented in Flutter widget trees under `lib/screens/` and `lib/widgets/`.
- Data access and external integration are concentrated in service classes under `lib/services/`.
- Domain models are thin DTO-like classes in `lib/models/`.
- Platform wiring for notifications lives in Flutter entrypoint + Android native config.

## Runtime Composition
Startup path:
1. `lib/main.dart` initializes Firebase, foreground/background FCM handlers, and local notification service.
2. `lib/app/app.dart` boots `MaterialApp` with global `appNavigatorKey`.
3. `lib/screens/auth/auth_gate.dart` selects auth flow vs signed-in flow.
4. Signed-in users go through `lib/screens/setup/setup_gate.dart` (setup complete?) to either:
   - `lib/screens/setup/unified_setup_screen.dart`, or
   - `lib/screens/home_screen.dart`.

## Module Boundaries

### Presentation Layer
- Auth UI: `lib/screens/auth/login_screen.dart`, `lib/screens/auth/auth_gate.dart`
- Setup UI: `lib/screens/setup/unified_setup_screen.dart` (+ legacy `lib/screens/setup/age_selection.dart`, `lib/screens/setup/habits_selection.dart`)
- Main app UI: `lib/screens/home_screen.dart`
- Habit CRUD UI: `lib/screens/manage/manage_habits_screen.dart`, `lib/screens/manage/add_habits_screen.dart`, `lib/screens/manage/habit_form_sheet.dart`, `lib/screens/manage/habit_reminder_sheet.dart`
- Settings/diagnostics UI: `lib/screens/settings/settings_screen.dart`
- Reusable widgets: `lib/widgets/orbit_habit_card.dart`, `lib/widgets/fcm_token_registration.dart`

### Service Layer
- Auth/session: `lib/services/auth_service.dart`
- User habits CRUD stream: `lib/services/habit_service.dart`
- Habit catalog metadata (age-filtered): `lib/services/habits_meta_service.dart`
- Setup completion flag: `lib/services/user_prefs_service.dart`
- Push token + message stream helpers: `lib/services/fcm_service.dart`
- Local notification scheduling/canceling: `lib/services/notification_service.dart`

### Domain/Utility Layer
- Habit entity: `lib/models/habit.dart`
- Habit catalog entity: `lib/models/habit_meta.dart`
- Shared constants/section taxonomy/age groups: `lib/core/app_constants.dart`
- Time conversion and fixed IST policy: `lib/core/ist_time.dart`

## Data Architecture
Firestore collections used:
- `users/{uid}`: setup status + FCM token metadata (`setupComplete`, `fcmToken`, timestamps)
- `users/{uid}/habits/{habitId}`: user-owned habit documents
- `habits_meta/{docId}`: read-only habit catalog metadata

Model mapping:
- `Habit` in `lib/models/habit.dart` maps habit docs, including reminder minute-of-day fields.
- `HabitMeta` in `lib/models/habit_meta.dart` maps compact catalog docs (`n`, `c`, `d`, `amin`, `amax`).

Security boundary:
- `firestore.rules` enforces per-user access for `users/{uid}` and `users/{uid}/habits/*`.
- `habits_meta/*` is authenticated read-only.

## Notification Architecture
Push + local notifications are split by responsibility:
- FCM lifecycle and tokening: `lib/services/fcm_service.dart`
- Foreground/background open handlers registration: `lib/main.dart`
- Token persistence per signed-in user: `lib/widgets/fcm_token_registration.dart`
- Local schedule/cancel logic with timezone policy: `lib/services/notification_service.dart`
- Android channel + manifest permissions: `android/app/src/main/kotlin/com/example/habitu/MainActivity.kt`, `android/app/src/main/AndroidManifest.xml`

Time strategy:
- Reminder times are stored as minutes since midnight.
- Scheduling is pinned to `Asia/Kolkata` via `lib/core/ist_time.dart` and `timezone` setup in `NotificationService`.

## Dependency Direction
Allowed direction in current codebase:
- `screens/widgets` -> `services`, `models`, `core`
- `services` -> Firebase SDKs, `models`, `core`
- `models/core` -> Flutter primitives / data types only

No dedicated repository/use-case layer exists between UI and services; screens call services directly.

## Architectural Characteristics
Strengths:
- Simple and fast to iterate (thin abstraction layers).
- Clear file-level separation of UI/services/models.
- Real-time habit updates via Firestore streams (`watchHabits`).

Tradeoffs:
- Business logic is partially duplicated across setup/manage flows.
- Some setup screens appear legacy/unwired (`age_selection.dart`, `habits_selection.dart`) while unified setup is active.
- Service instantiation is mostly ad hoc (`Service()` in widgets) rather than dependency injection.
