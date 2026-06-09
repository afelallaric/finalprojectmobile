import 'package:act_for_earth/domain/model/habit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitRemoteDataSource {
  HabitRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore;

  static const String collectionName = 'habits';

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
