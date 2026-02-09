import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitu/models/habit.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _habitsCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('HabitService requires an authenticated user');
    }
    return _firestore.collection('users').doc(uid).collection('habits');
  }

  /// Stream all habits for the current user, ordered by section then order.
  Stream<List<Habit>> watchHabits() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }
    return _habitsCollection()
        .orderBy('section')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Habit.fromMap(doc.id, doc.data())).toList());
  }

  Future<Habit> create(Habit habit) async {
    final col = _habitsCollection();
    final doc = col.doc();
    final now = DateTime.now();
    final toSave = habit.copyWith(id: doc.id, createdAt: now, updatedAt: now);
    await doc.set(toSave.toMap());
    return toSave;
  }

  Future<void> update(Habit habit) async {
    final updated = habit.copyWith(updatedAt: DateTime.now());
    await _habitsCollection().doc(habit.id).update(updated.toMap());
  }

  Future<void> delete(String habitId) async {
    await _habitsCollection().doc(habitId).delete();
  }

  Future<Habit?> getById(String id) async {
    final doc = await _habitsCollection().doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Habit.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}
