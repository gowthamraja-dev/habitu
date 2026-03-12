# Testing Patterns

**Analysis Date:** 2026-03-13

## Test Framework

**Status:** No tests exist in this codebase

**Runner:**
- Package: `flutter_test` (included in `dev_dependencies` of `pubspec.yaml`)
- No test runner configuration found (uses Flutter defaults)

**No test files present:**
- No `test/` directory exists
- No `*_test.dart` or `*_spec.dart` files found

## Test File Organization

**Location:** Not applicable - no tests exist

**Naming Pattern (if tests were to be added):**
- Dart/Flutter standard: `test/` directory at project root
- File naming: `*_test.dart`

**Recommended Structure (based on code structure):**
```
test/
├── models/
│   ├── habit_test.dart
│   └── habit_meta_test.dart
├── services/
│   ├── habit_service_test.dart
│   ├── auth_service_test.dart
│   └── notification_service_test.dart
└── widgets/
    └── orbit_habit_card_test.dart
```

## Existing "Test" Code

**Manual Testing Methods:**

The `NotificationService` class contains manual test helpers that can be invoked from the Settings screen:

**From `lib/services/notification_service.dart`:**
```dart
/// Show a local notification immediately (for testing).
Future<void> showTestNow({String title = 'Local notification test', String body = 'It works'}) async {
  await initialize();
  await _plugin.show(...);
}

/// Test: wait [seconds] then show a notification (reliable when app is open).
/// Does not use AlarmManager, so keep app in foreground for the delay.
Future<void> scheduleTestInSeconds({
  int seconds = 10,
  String title = 'Scheduled local test',
  String? body,
}) async { ... }
```

**From `lib/screens/settings/settings_screen.dart`:**
- Buttons to trigger `showTestNow()` and `scheduleTestInSeconds()`

## Test Patterns to Implement

Based on the codebase structure, here are the recommended patterns:

### Unit Test Pattern (Models)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:habitu/models/habit.dart';

void main() {
  group('Habit', () {
    test('copyWith creates new instance with updated values', () {
      final original = Habit(
        id: '1',
        name: 'Test',
        section: 'MORNING_SYSTEM',
        order: 0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      
      final updated = original.copyWith(name: 'Updated');
      
      expect(updated.name, 'Updated');
      expect(updated.id, original.id);
    });
    
    test('toMap serializes correctly', () { ... });
    
    test('fromMap deserializes correctly', () { ... });
  });
}
```

### Service Test Pattern (with Mocks)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@GenerateMocks([FirebaseFirestore, FirebaseAuth, CollectionReference])
void main() {
  group('HabitService', () {
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late HabitService service;
    
    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      service = HabitService();
    });
    
    test('watchHabits returns empty stream when not authenticated', () { ... });
  });
}
```

### Widget Test Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:habitu/widgets/orbit_habit_card.dart';
import 'package:habitu/models/habit.dart';

void main() {
  group('OrbitHabitCard', () {
    testWidgets('displays habit name', (tester) async {
      final habit = Habit(...);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrbitHabitCard(
              habit: habit,
              onComplete: () {},
            ),
          ),
        ),
      );
      
      expect(find.text(habit.name), findsOneWidget);
    });
  });
}
```

## Mocking

**Recommended Packages:**
- `mockito` - Mocking framework
- `mocktail` - Alternative (no code generation)

**Firebase Mocks:**
- Use `mockito` with `@GenerateMocks` for Firebase classes
- Mock `FirebaseFirestore`, `FirebaseAuth`, `FirebaseMessaging`

## Coverage

**Current Status:** No coverage enforcement

**Recommended Target:** 70% minimum for services, 50% overall

**View Coverage Command:**
```bash
flutter test --coverage
```

## Test Types Missing

1. **Unit Tests:** Needed for all models and services
2. **Widget Tests:** Needed for custom widgets (`OrbitHabitCard`)
3. **Integration Tests:** Needed for auth flow and navigation

## Recommendations

1. **Add test dependency:**
   ```yaml
   dev_dependencies:
     flutter_test:
       sdk: flutter
     mockito: ^5.4.0
     build_runner: ^2.4.0
   ```

2. **Create test directory structure**

3. **Priority order:**
   - Model serialization (`Habit`, `HabitMeta`)
   - Service business logic (`HabitService`, `AuthService`)
   - Widget rendering (`OrbitHabitCard`)

4. **CI Integration:**
   - Add `flutter test` to CI pipeline
   - Consider coverage reporting with `flutter_coverage`

---

*Testing analysis: 2026-03-13*
