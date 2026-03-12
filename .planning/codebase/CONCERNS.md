# Codebase Concerns

**Analysis Date:** 2026-03-13

## Tech Debt

**Hardcoded Placeholder Stats:**
- Issue: Header in `home_screen.dart` displays hardcoded "92%" that never changes
- Files: `lib/screens/home_screen.dart` (line 184)
- Impact: User sees fake momentum percentage with no real calculation
- Fix approach: Implement actual habit completion tracking and calculate real momentum percentage

**Hardcoded Font Family:**
- Issue: `OrbitHabitCard` references 'Satoshi' font family that may not be bundled
- Files: `lib/widgets/orbit_habit_card.dart` (line 104)
- Impact: Text may render with fallback font, causing inconsistent UI
- Fix approach: Add font to pubspec.yaml assets or remove fontFamily reference to use default

**Empty Notification Handler:**
- Issue: `_onSelect` in notification service has empty catch block that silently swallows errors
- Files: `lib/services/notification_service.dart` (lines 55-63)
- Impact: Notification tap payload parsing failures are invisible
- Fix approach: Add logging for debugging, handle navigation based on payload

**Client-Side Filtering:**
- Issue: `HabitsMetaService.fetchForAgeRange` fetches ALL habits_meta documents then filters in Dart
- Files: `lib/services/habits_meta_service.dart` (lines 13-25)
- Impact: W bandwidth on large datasets, slower performance
- Fix approach: Use Firestore compound queries to filter server-side

## Known Bugs

**Web Platform Not Supported:**
- Issue: Firebase options explicitly throw for web platform
- Files: `lib/firebase_options.dart` (lines 19-23)
- Trigger: Running `flutter build web`
- Workaround: None - web platform not implemented

**Missing macOS/Windows/Linux Support:**
- Issue: Firebase options not configured for desktop platforms
- Files: `lib/firebase_options.dart` (lines 30-44)
- Impact: Cannot build for desktop platforms

## Security Considerations

**Firestore Security Rules:**
- Risk: No `firestore.rules` file found in the project
- Files: None detected
- Current mitigation: Assumed Firebase default (deny all)
- Recommendations: Add firestore.rules with user-owned document rules

**Exposed FCM Tokens:**
- Risk: Settings screen displays and allows copying FCM tokens
- Files: `lib/screens/settings/settings_screen.dart` (lines 186-227)
- Current mitigation: Debug-only feature
- Recommendations: Consider adding debug-only compile flag or removing from production builds

**No Input Validation:**
- Risk: Email format validation relies only on Firebase backend
- Files: `lib/services/auth_service.dart`, `lib/models/habit.dart`
- Current mitigation: Firebase handles validation
- Recommendations: Add client-side validation for better UX

## Performance Bottlenecks

**No Offline Persistence:**
- Problem: App relies on Firestore real-time listeners with no offline cache
- Files: `lib/services/habit_service.dart`, `lib/services/habits_meta_service.dart`
- Cause: No `FirestoreSettings` with cache/timeout configured
- Improvement path: Enable `FirestoreSettings` with `cacheSizeBytes` and `persistenceEnabled`

**No Pagination:**
- Problem: All habits loaded at once without pagination
- Files: `lib/services/habit_service.dart` (lines 18-27)
- Cause: Simple `snapshots()` without limit
- Improvement path: Add pagination support for users with many habits

## Fragile Areas

**Auth State Race Conditions:**
- Why fragile: Multiple places check `_auth.currentUser?.uid` without waiting for auth state
- Files: `lib/services/auth_service.dart`, `lib/services/habit_service.dart`
- Safe modification: Use `authStateChanges` stream consistently everywhere
- Test coverage: Not tested

**Notification ID Collision Risk:**
- Why fragile: `habitId.hashCode.abs() % 0x7FFFFFFF` could collide for different habits
- Files: `lib/services/notification_service.dart` (lines 79-81)
- Safe modification: Use UUID-based IDs or store ID mapping in Firestore
- Test coverage: Not tested

## Scaling Limits

**Firestore Document Count:**
- Current capacity: Assumes reasonable number of habits per user
- Limit: Firestore recommends <10,000 documents per collection
- Scaling path: Add archiving for old completed habits

**Notification Scheduling:**
- Current capacity: Android/iOS limits (Android 12+ exact alarms restricted)
- Limit: System notification scheduling limits apply
- Scaling path: Already handles inexact fallback gracefully

## Dependencies at Risk

**Firebase Packages:**
- Risk: Using older versions (e.g., firebase_auth: ^6.1.4)
- Impact: Security patches may be missing
- Migration plan: Run `flutter pub upgrade --major-versions` to get latest stable

**Flutter Version:**
- Risk: Using SDK ^3.7.2 - may be behind current stable
- Impact: Newer Dart features and fixes unavailable
- Migration plan: Update SDK version in pubspec.yaml

## Missing Critical Features

**No Tests:**
- Problem: Zero test files found in project
- Blocks: Safe refactoring, regression detection
- Priority: High

**No Error Boundaries:**
- Problem: No Flutter error handling/widget fallback for crashes
- Blocks: Graceful degradation when errors occur
- Priority: Medium

**No Analytics:**
- Problem: No crash reporting or usage analytics
- Blocks: Understanding user behavior, debugging production issues
- Priority: Medium

## Test Coverage Gaps

**Untested Services:**
- What's not tested: All services (AuthService, HabitService, FcmService, NotificationService)
- Files: `lib/services/*.dart`
- Risk: Authentication bugs, database errors could go unnoticed
- Priority: High

**Untested Models:**
- What's not tested: Habit model serialization/deserialization
- Files: `lib/models/habit.dart`, `lib/models/habit_meta.dart`
- Risk: Data corruption from field mismatches
- Priority: High

**Untested Widgets:**
- What's not tested: All custom widgets
- Files: `lib/widgets/*.dart`
- Risk: UI bugs in production
- Priority: High

**Untested Screens:**
- What's not tested: All screens
- Files: `lib/screens/**/*.dart`
- Risk: Navigation and state management bugs
- Priority: High

---

*Concerns audit: 2026-03-13*
