import 'package:act_for_earth/domain/model/habit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
        )
        .handleError((error, stack) {
          FirebaseCrashlytics.instance.log('Failed to watch habits: userId=$userId');
          FirebaseCrashlytics.instance.recordError(error, stack, reason: 'Watch habits stream error');
          throw error;
        });
  }

  Future<void> createHabit(Habit habit) async {
    try {
      await _collection.add(habit.toFirestore());
    } catch (e, stack) {
      FirebaseCrashlytics.instance.log('Failed to create habit: title=${habit.title}');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Create habit firestore error');
      rethrow;
    }
  }

  Future<void> updateHabit(Habit habit) async {
    if (habit.habitId.isEmpty) {
      throw ArgumentError('Habit id cannot be empty for update.');
    }

    try {
      await _collection.doc(habit.habitId).update(habit.toFirestore());
    } catch (e, stack) {
      FirebaseCrashlytics.instance.log('Failed to update habit: id=${habit.habitId}');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Update habit firestore error');
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    if (habitId.isEmpty) {
      throw ArgumentError('Habit id cannot be empty for delete.');
    }

    try {
      await _collection.doc(habitId).delete();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.log('Failed to delete habit: id=$habitId');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Delete habit firestore error');
      rethrow;
    }
  }
}
