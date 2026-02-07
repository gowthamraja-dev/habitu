/// Section identifiers for habits (stored in Firestore).
class HabitSections {
  static const String morning = 'MORNING_SYSTEM';
  static const String afternoon = 'AFTERNOON_SYSTEM';
  static const String evening = 'EVENING_SYSTEM';

  static const List<String> all = [morning, afternoon, evening];

  static String displayName(String section) {
    switch (section) {
      case morning:
        return 'MORNING SYSTEM';
      case afternoon:
        return 'AFTERNOON SYSTEM';
      case evening:
        return 'EVENING SYSTEM';
      default:
        return section.replaceAll('_', ' ');
    }
  }
}
