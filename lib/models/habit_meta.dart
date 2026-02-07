/// Metadata document from Firestore collection [habits_meta].
/// Fields: n (name), c (category), d (difficulty), amin (age min), amax (age max).
class HabitMeta {
  final String id;
  final String name;  // n
  final String category;  // c
  final String difficulty;  // d
  final int ageMin;  // amin
  final int ageMax;  // amax

  const HabitMeta({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.ageMin,
    required this.ageMax,
  });

  factory HabitMeta.fromMap(String id, Map<String, dynamic> map) {
    return HabitMeta(
      id: id,
      name: map['n'] as String? ?? '',
      category: (map['c'] as String? ?? '').toLowerCase(),
      difficulty: map['d'] as String? ?? 'easy',
      ageMin: (map['amin'] as num?)?.toInt() ?? 0,
      ageMax: (map['amax'] as num?)?.toInt() ?? 120,
    );
  }

  /// Whether this habit's age range overlaps with [userAgeMin]..[userAgeMax].
  bool matchesAgeRange(int userAgeMin, int userAgeMax) {
    return ageMin <= userAgeMax && ageMax >= userAgeMin;
  }
}
