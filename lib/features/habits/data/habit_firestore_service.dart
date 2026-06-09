import 'package:act_for_earth/features/habits/domain/habit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitFirestoreService {
  HabitFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore;

  static const String collectionName = 'habits';
  static const String currentUserId = 'current_user';

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _db.collection(collectionName);
  }

  Stream<List<Habit>> watchHabits(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(Habit.fromFirestore).toList(growable: false),
        );
  }

  Future<void> seedDefaultHabits({required String userId}) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final batch = _db.batch();
    final createdAt = DateTime.now();
    final defaults = [
      Habit(
        userId: userId,
        title: 'Recycle plastic waste',
        category: 'Waste',
        targetFrequency: 7,
        createdAt: createdAt,
      ),
      Habit(
        userId: userId,
        title: 'Bike to school',
        category: 'Transport',
        targetFrequency: 3,
        createdAt: createdAt,
      ),
      Habit(
        userId: userId,
        title: 'Save electricity at night',
        category: 'Energy',
        targetFrequency: 5,
        createdAt: createdAt,
      ),
    ];

    for (final habit in defaults) {
      final docRef = _collection.doc();
      batch.set(docRef, habit.toFirestore());
    }

    await batch.commit();
  }

  Future<void> createHabit(Habit habit) async {
    await _collection.add(habit.toFirestore());
  }

  Future<void> updateHabit(Habit habit) async {
    if (habit.habitId.isEmpty) {
      throw ArgumentError('Habit id cannot be empty for update.');
    }

    await _collection.doc(habit.habitId).update(habit.toFirestore());
  }

  Future<void> deleteHabit(String habitId) async {
    if (habitId.isEmpty) {
      throw ArgumentError('Habit id cannot be empty for delete.');
    }

    await _collection.doc(habitId).delete();
  }
}
