# Codebase Structure

**Analysis Date:** 2026-03-13

## Directory Layout

```
habitu/
├── lib/
│   ├── main.dart              # Entry point, Firebase init
│   ├── app/
│   │   └── app.dart            # HabituApp widget
│   ├── core/
│   │   ├── app_constants.dart # Constants, HabitSections
│   │   └── ist_time.dart      # Time utilities
│   ├── models/
│   │   ├── habit.dart         # Habit model
│   │   └── habit_meta.dart    # HabitMeta model
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── auth_gate.dart
│   │   │   └── login_screen.dart
│   │   ├── home_screen.dart   # Main habit list
│   │   ├── manage/
│   │   │   ├── manage_habits_screen.dart
│   │   │   ├── habit_form_sheet.dart
│   │   │   └── habit_reminder_sheet.dart
│   │   ├── settings/
│   │   │   └── settings_screen.dart
│   │   └── setup/
│   │       ├── setup_gate.dart
│   │       ├── unified_setup_screen.dart
│   │       ├── age_selection.dart
│   │       └── habits_selection.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── habit_service.dart
│   │   ├── habits_meta_service.dart
│   │   ├── user_prefs_service.dart
│   │   ├── fcm_service.dart
│   │   └── notification_service.dart
│   ├── widgets/
│   │   ├── orbit_habit_card.dart
│   │   └── fcm_token_registration.dart
│   └── firebase_options.dart   # Firebase config
├── pubspec.yaml               # Dependencies
├── android/                   # Android native config
├── ios/                      # iOS native config
└── docs/                     # Documentation
```

## Directory Purposes

**lib/:**
- Purpose: All Dart source code
- Contains: Entry point, app code, models, services, widgets

**lib/app/:**
- Purpose: Root app widget and configuration
- Contains: `HabituApp` MaterialApp with theme and navigator key

**lib/core/:**
- Purpose: Constants and utilities
- Contains: App constants (`HabitSections`, age groups), timezone utilities

**lib/models/:**
- Purpose: Data models with serialization
- Contains: `Habit` (user habits), `HabitMeta` (predefined habit templates)

**lib/screens/:**
- Purpose: UI screens/pages
- Contains: Auth, home, manage, settings, setup screens

**lib/services/:**
- Purpose: Business logic and external integrations
- Contains: Firebase wrappers, preferences, notifications

**lib/widgets/:**
- Purpose: Reusable UI components
- Contains: Custom cards, registration widgets

## Key File Locations

**Entry Points:**
- `lib/main.dart`: App bootstrap, Firebase init, FCM background handler

**Configuration:**
- `pubspec.yaml`: Dependencies (Flutter, Firebase SDKs, notifications)
- `lib/firebase_options.dart`: Firebase platform config
- `lib/core/app_constants.dart`: App constants

**Core Logic:**
- `lib/services/auth_service.dart`: Firebase Auth wrapper
- `lib/services/habit_service.dart`: Habit CRUD with Firestore streams
- `lib/services/habits_meta_service.dart`: Fetch habit suggestions

**Primary UI:**
- `lib/screens/home_screen.dart`: Main habit tracking screen
- `lib/screens/auth/auth_gate.dart`: Auth state routing
- `lib/screens/setup/setup_gate.dart`: Setup flow routing

## Naming Conventions

**Files:**
- Dart convention: `snake_case.dart` (e.g., `habit_service.dart`, `auth_gate.dart`)
- Screen files: `{feature}_screen.dart` or `{feature}_gate.dart`
- Model files: `{noun}.dart` (e.g., `habit.dart`)
- Service files: `{feature}_service.dart`

**Directories:**
- `lib/screens/`: Feature-based subdirectories for grouped screens
- `lib/services/`: Flat - all services in one directory
- `lib/models/`: Flat - all models in one directory

**Classes:**
- PascalCase: `HabitService`, `HomeScreen`, `OrbitHabitCard`
- Widgets: Often named with screen/component name (e.g., `AuthGate`)

## Where to Add New Code

**New Feature Screen:**
- Implementation: `lib/screens/{feature}/{feature}_screen.dart`
- Related: Add supporting files in same directory

**New Service:**
- Implementation: `lib/services/{feature}_service.dart`
- Follow existing service pattern: wrap Firebase or external SDK

**New Model:**
- Implementation: `lib/models/{noun}.dart`
- Include `fromMap`, `toMap` for Firestore serialization, `copyWith` for immutability

**New Reusable Widget:**
- Implementation: `lib/widgets/{widget_name}.dart`
- Keep focused on single responsibility

**New Utility:**
- Implementation: `lib/core/` for app-wide utilities
- Avoid - prefer placing in appropriate service or model

## Special Directories

**android/, ios/:**
- Purpose: Native platform configuration
- Generated: Partially (Firebase config needs to be committed)
- Committed: Yes - `google-services.json`, `GoogleService-Info.plist` should be added

**docs/:**
- Purpose: Documentation
- Generated: No
- Committed: Yes

---

*Structure analysis: 2026-03-13*
