import 'package:cloud_firestore/cloud_firestore.dart';

class HabitLog {
  final String logId;
  final String habitId;
  final DateTime date;
  final bool status;

  const HabitLog({
    required this.logId,
    required this.habitId,
    required this.date,
    required this.status,
  });

  factory HabitLog.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return HabitLog(
      logId: doc.id,
      habitId: (data['habitId'] as String?) ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: (data['status'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'habitId': habitId,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }

  HabitLog copyWith({
    String? logId,
    String? habitId,
    DateTime? date,
    bool? status,
  }) {
    return HabitLog(
      logId: logId ?? this.logId,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
