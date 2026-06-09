import 'package:act_for_earth/domain/model/habit_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitLogFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'habit_logs';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  Stream<List<HabitLog>> watchLogsForHabit(String habitId) {
    return _collection
        .where('habitId', isEqualTo: habitId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(HabitLog.fromFirestore).toList();
    });
  }

  Stream<List<HabitLog>> watchAllLogs() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map(HabitLog.fromFirestore).toList();
    });
  }

  Future<void> logHabit(String habitId, DateTime date, bool status) async {
    // Standardize date to year-month-day to prevent multiple logs per day
    final dateOnly = DateTime(date.year, date.month, date.day);
    final snapshot = await _collection
        .where('habitId', isEqualTo: habitId)
        .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await _collection.doc(snapshot.docs.first.id).update({'status': status});
    } else {
      final log = HabitLog(
        logId: '',
        habitId: habitId,
        date: dateOnly,
        status: status,
      );
      await _collection.add(log.toFirestore());
    }
  }
}
