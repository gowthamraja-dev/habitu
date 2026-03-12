# Coding Conventions

**Analysis Date:** 2026-03-13

## Language & Framework

**Language:** Dart 3.7.2
**Framework:** Flutter
**Project Type:** Mobile app (Android/iOS)

## Naming Patterns

**Files:**
- Use snake_case: `habit_service.dart`, `orbit_habit_card.dart`
- Suffix: `*_service.dart` for services, `*_screen.dart` for screens, `*_widget.dart` for widgets

**Classes:**
- PascalCase: `HabitService`, `OrbitHabitCard`, `LoginScreen`
- Private classes prefixed with underscore: `_SectionHeader`, `_OrbitHabitCardState`

**Functions & Variables:**
- LowerCamelCase: `watchHabits()`, `currentUser`, `reminderTimeMinutes`

**Constants:**
- LowerCamelCase with `k` prefix: `kSetupCompleteKey`

**Private Members:**
- Prefix with underscore: `_fillController`, `_auth`, `_habitsCollection()`

## Code Style

**Formatting:**
- Tool: Dart formatter (default Flutter tooling)
- Indentation: 2 spaces
- Trailing commas used for readability in multi-line lists/maps

**Linting:**
- Tool: `flutter_lints` package (v5.0.0)
- Configuration: `analysis_options.yaml` with default Flutter rules
- Additional rules can be enabled via `linter.rules` section

**Example from `lib/models/habit.dart`:**
```dart
const Habit({
  required this.id,
  required this.name,
  required this.section,
  required this.order,
  required this.createdAt,
  required this.updatedAt,
  this.colorHex,
  this.iconName,
  this.reminderTimeMinutes,
});
```

**Use of const:**
- Always use `const` constructors where possible
- Use `const` for static widget instances
- Example: `const HomeScreen({super.key});`

## Import Organization

**Order (in Dart files):**
1. Dart SDK imports (`dart:async`, `dart:math`)
2. Package imports (`package:flutter/...`, `package:firebase_auth/...`)
3. Relative imports (`../models/...`, `./widgets/...`)

**Example from `lib/screens/home_screen.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:habitu/core/app_constants.dart';
import 'package:habitu/models/habit.dart';
import 'package:habitu/screens/manage/manage_habits_screen.dart';
// ... more relative imports
```

**Path Aliases:**
- Uses `package:` imports for all external packages
- Relative imports for local modules (`package:habitu/...`)

## Error Handling

**Patterns:**

1. **Return null for "not found":**
   ```dart
   // From lib/services/habit_service.dart
   Future<Habit?> getById(String id) async {
     final doc = await _habitsCollection().doc(id).get();
     if (doc.exists && doc.data() != null) {
       return Habit.fromMap(doc.id, doc.data()!);
     }
     return null;
   }
   ```

2. **Throw StateError for programming errors:**
   ```dart
   CollectionReference<Map<String, dynamic>> _habitsCollection() {
     final uid = _auth.currentUser?.uid;
     if (uid == null) {
       throw StateError('HabitService requires an authenticated user');
     }
     return _firestore.collection('users').doc(uid).collection('habits');
   }
   ```

3. **Try/catch with specific exceptions:**
   ```dart
   // From lib/screens/auth/login_screen.dart
   try {
     if (_isSignUp) {
       await _auth.signUpWithEmailAndPassword(email: email, password: password);
     } else {
       await _auth.signInWithEmailAndPassword(email: email, password: password);
     }
   } on FirebaseAuthException catch (e) {
     setState(() {
       _errorMessage = _authErrorMessage(e.code);
       _loading = false;
     });
   }
   ```

4. **PlatformException handling:**
   ```dart
   // From lib/services/notification_service.dart
   try {
     await _plugin.zonedSchedule(...);
   } on PlatformException catch (e) {
     if (e.code == 'exact_alarms_not_permitted') {
       // Fallback to inexact scheduling
       await _plugin.zonedSchedule(..., androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle);
       return;
     }
     rethrow;
   }
   ```

5. **Silent catch with empty body (rare):**
   ```dart
   void _onSelect(NotificationResponse response) {
     if (response.payload != null && response.payload!.isNotEmpty) {
       try {
         final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
         final habitId = payload['habitId'] as String?;
         if (habitId != null) {}
       } catch (_) {}
     }
   }
   ```

## Documentation

**When to Document:**
- Public classes and methods use Dart doc comments (`///`)
- Complex business logic has inline comments explaining rationale

**Example from `lib/models/habit.dart`:**
```dart
/// Represents a single habit stored in Firestore.
class Habit {
  // ...
  
  /// Set [clearReminder] to true to remove the daily reminder.
  Habit copyWith({
    String? id,
    // ...
    bool clearReminder = false,
  }) { ... }

  /// Reminder time as TimeOfDay, or null if no reminder.
  TimeOfDay? get reminderTimeOfDay { ... }
}
```

**Example from `lib/core/app_constants.dart`:**
```dart
/// SharedPreferences key for setup completion.
const String kSetupCompleteKey = 'setup_complete';

/// Section identifiers for habits (stored in Firestore).
class HabitSections { ... }
```

## Function Design

**Size:**
- Functions typically under 30 lines
- Complex widgets (like `HomeScreen`) separate private widget builders

**Parameters:**
- Use named parameters with `required` for mandatory args
- Optional params use default values or nullability

**Return Values:**
- Use nullable types (`Habit?`) for potentially missing data
- Use `Future<void>` for side-effect-only operations
- Use `Stream<T>` for reactive data sources

## Module Design

**Exports:**
- Direct exports from individual files (no barrel files)
- Services are instantiated where needed or as static singletons

**Service Pattern:**
- Singleton via factory constructor: `NotificationService._()` and `factory NotificationService() => _instance;`
- Static instance in StatelessWidget: `static final HabitService _habitService = HabitService();`

**Model Pattern:**
- Immutable data classes with `const` constructors
- `copyWith()` method for modifications
- `toMap()` and `fromMap()` factory for serialization

**Example from `lib/models/habit.dart`:**
```dart
class Habit {
  final String id;
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
