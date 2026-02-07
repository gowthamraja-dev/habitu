import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitu/models/habit_meta.dart';

const String _collection = 'habits_meta';

class HabitsMetaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  /// Fetches all habits_meta and filters by age range.
  /// Returns list of [HabitMeta] where habit's amin..amax overlaps [userAgeMin]..[userAgeMax].
  Future<List<HabitMeta>> fetchForAgeRange(int userAgeMin, int userAgeMax) async {
    final snap = await _col.get();
    final list = <HabitMeta>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data.isEmpty) continue;
      final meta = HabitMeta.fromMap(doc.id, data);
      if (meta.matchesAgeRange(userAgeMin, userAgeMax)) {
        list.add(meta);
      }
    }
    return list;
  }

  /// Groups habits by category (field "c"). Returns map category -> list of HabitMeta.
  static Map<String, List<HabitMeta>> groupByCategory(List<HabitMeta> habits) {
    final map = <String, List<HabitMeta>>{};
    for (final h in habits) {
      final c = h.category.isEmpty ? 'general' : h.category;
      map.putIfAbsent(c, () => []).add(h);
    }
    return map;
  }

  /// Returns distinct category names, title-cased for display.
  static List<String> getCategories(Map<String, List<HabitMeta>> grouped) {
    final keys = grouped.keys.toList()..sort();
    return keys.map((k) => k.isEmpty ? 'General' : _titleCase(k)).toList();
  }

  static String _titleCase(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
