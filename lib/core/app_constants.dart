/// SharedPreferences key for setup completion.
const String kSetupCompleteKey = 'setup_complete';

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

  static final List<Map<String, dynamic>> ageGroups = [
    {
      "id": "child",
      "label": "Child",
      "age_min": 0,
      "age_max": 12,
      "count": 215,
    },
    {"id": "teen", "label": "Teen", "age_min": 13, "age_max": 17, "count": 215},
    {
      "id": "young_adult",
      "label": "Young adult",
      "age_min": 18,
      "age_max": 24,
      "count": 359,
    },
    {
      "id": "adult",
      "label": "Adult",
      "age_min": 25,
      "age_max": 39,
      "count": 447,
    },
    {
      "id": "midlife",
      "label": "Midlife",
      "age_min": 40,
      "age_max": 59,
      "count": 259,
    },
    {
      "id": "senior",
      "label": "Senior",
      "age_min": 60,
      "age_max": 120,
      "count": 158,
    },
  ];
}
