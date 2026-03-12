# Architecture

**Analysis Date:** 2026-03-13

## Pattern Overview

**Overall:** Clean Architecture with Flutter-specific UI patterns

**Key Characteristics:**
- **Service Layer Pattern**: Business logic encapsulated in service classes that wrap Firebase SDKs
- **Stream-based Reactivity**: UI uses Dart Streams to reactively update from Firestore
- **Gate-based Navigation**: Authentication and setup flows use gate widgets that route based on state
- **Model-View Separation**: Models are pure data classes; screens/widgets handle presentation

## Layers

**1. Entry Layer:**
- Location: `lib/main.dart`
- Contains: App bootstrap, Firebase initialization, FCM background handler registration
- Responsibilities: Initialize Firebase, configure push notifications, start the app

**2. App Configuration Layer:**
- Location: `lib/app/app.dart`
- Contains: `HabituApp` - root MaterialApp widget with global navigator key
- Responsibilities: Define app theme, set up global navigation key for FCM-triggered navigation

**3. Authentication Layer:**
- Location: `lib/screens/auth/`
- Contains: `AuthGate`, `LoginScreen`
- Responsibilities: Route to login or app based on auth state

**4. Setup Flow Layer:**
- Location: `lib/screens/setup/`
- Contains: `SetupGate`, `UnifiedSetupScreen`, `AgeSelection`, `HabitsSelection`
- Responsibilities: Onboard new users - collect age, present habit suggestions

**5. Main App Layer:**
- Location: `lib/screens/home_screen.dart`, `lib/screens/manage/`, `lib/screens/settings/`
- Contains: Primary screens for viewing and managing habits
- Responsibilities: Display habits, handle habit completion UI, manage habit CRUD

**6. Service Layer:**
- Location: `lib/services/`
- Contains: `AuthService`, `HabitService`, `UserPrefsService`, `HabitsMetaService`, `FcmService`, `NotificationService`
- Responsibilities: Business logic, Firebase interactions, data transformation

**7. Model Layer:**
- Location: `lib/models/`
- Contains: `Habit`, `HabitMeta`
- Responsibilities: Data models with serialization/deserialization to Firestore

**8. Core/Utilities:**
- Location: `lib/core/`
- Contains: `app_constants.dart`, `ist_time.dart`
- Responsibilities: Constants, shared utilities

**9. UI Components:**
- Location: `lib/widgets/`
- Contains: `OrbitHabitCard`, `FcmTokenRegistration`
- Responsibilities: Reusable UI widgets

## Data Flow

**Authentication Flow:**

1. App starts → `main.dart` initializes Firebase
2. `HabituApp` builds `AuthGate`
3. `AuthGate` listens to `AuthService.authStateChanges` stream
4. If unauthenticated → show `LoginScreen`
5. If authenticated → show `FcmTokenRegistration` → `SetupGate`

**Setup Flow:**

1. `SetupGate` checks `UserPrefsService.isSetupComplete(uid)`
2. If incomplete → show `UnifiedSetupScreen`
3. User selects age group → filter `habits_meta` collection by age range
4. User selects habits → create in Firestore via `HabitService`
5. Mark setup complete → navigate to `HomeScreen`

**Habit Management Flow:**

1. `HomeScreen` uses `HabitService.watchHabits()` stream
2. Habits grouped by section (MORNING/AFTERNOON/EVENING)
3. Display in `OrbitHabitCard` with long-press-to-complete animation
4. `ManageHabitsScreen` for adding/editing habits

**Push Notification Flow:**

1. App starts → `FcmService` registers FCM token
2. Background messages → `_firebaseMessagingBackgroundHandler` in `main.dart`
3. Foreground messages → handled by `FcmService.setForegroundHandler`
4. Show as local notification via `NotificationService`

## Key Abstractions

**Habit Model:**
- Purpose: Represents a user's habit stored in Firestore
- Examples: `lib/models/habit.dart`
- Pattern: Immutable class with `copyWith`, `toMap`, `fromMap` for Firestore serialization

**HabitMeta Model:**
- Purpose: Predefined habit templates from `habits_meta` collection
- Examples: `lib/models/habit_meta.dart`
- Pattern: Includes age-range filtering for personalized suggestions

**Service Classes:**
- Purpose: Wrap Firebase SDKs and provide app-specific business logic
- Examples: `HabitService`, `AuthService`, `UserPrefsService`
- Pattern: Singleton-like pattern (instantiated per-use), expose async methods and streams

## Entry Points

**App Entry:**
- Location: `lib/main.dart`
- Triggers: App launch (cold start or background)
- Responsibilities: Firebase init, FCM setup, notification init, run `HabituApp`

**FCM Background Handler:**
- Location: `lib/main.dart` (top-level function `_firebaseMessagingBackgroundHandler`)
- Triggers: Push notification when app is in background/terminated
- Responsibilities: Initialize Firebase in isolate, minimal processing

**Auth Gate:**
- Location: `lib/screens/auth/auth_gate.dart`
- Triggers: App build, auth state changes
- Responsibilities: Determine initial route (login vs app)

**Setup Gate:**
- Location: `lib/screens/setup/setup_gate.dart`
- Triggers: User authenticated
- Responsibilities: Check if onboarding complete, route to setup or home

## Error Handling

**Strategy:** Basic error handling with user-facing messages

**Patterns:**
- StreamBuilder with error snapshot display (see `lib/screens/home_screen.dart` lines 84-93)
- Firebase exceptions propagated as `StateError` in services (e.g., `HabitService` line 12)
- No global error boundary - errors display inline in UI

## Cross-Cutting Concerns

**Logging:** Not implemented - uses `print` statements only

**Validation:** Minimal - service methods assume valid input

**Authentication:** Firebase Auth with email/password; `AuthService` wraps `FirebaseAuth` instance

---

*Architecture analysis: 2026-03-13*
