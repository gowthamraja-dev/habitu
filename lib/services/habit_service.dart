import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitu/models/habit.dart';

const String _collection = 'habits';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _habits =>
      _firestore.collection(_collection);

  /// Stream all habits ordered by section then order.
  Stream<List<Habit>> watchHabits() {
    return _habits.orderBy('section').orderBy('order').snapshots().map((snap) {
      return snap.docs.map((doc) => Habit.fromMap(doc.id, doc.data())).toList();
    });
  }

  /// Create a new habit.
  Future<Habit> create(Habit habit) async {
    final doc = _habits.doc();
    final now = DateTime.now();
    final toSave = habit.copyWith(id: doc.id, createdAt: now, updatedAt: now);
    await doc.set(toSave.toMap());
    return toSave;
  }

  /// Update an existing habit.
  Future<void> update(Habit habit) async {
    final updated = habit.copyWith(updatedAt: DateTime.now());
    await _habits.doc(habit.id).update(updated.toMap());
  }

  /// Delete a habit by id.
  Future<void> delete(String habitId) async {
    await _habits.doc(habitId).delete();
  }

  /// Get a single habit by id (optional, for edit screen).
  Future<Habit?> getById(String id) async {
    final doc = await _habits.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Habit.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}
