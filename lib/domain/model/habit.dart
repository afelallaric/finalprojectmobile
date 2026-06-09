import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  const Habit({
    this.habitId = '',
    required this.userId,
    required this.title,
    required this.category,
    required this.targetFrequency,
    required this.createdAt,
  });

  final String habitId;
  final String userId;
  final String title;
  final String category;
  final int targetFrequency;
  final DateTime createdAt;

  factory Habit.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Habit(
      habitId: doc.id,
      userId: (data['userId'] as String?) ?? '',
      title: (data['title'] as String?) ?? 'Untitled Habit',
      category: (data['category'] as String?) ?? 'General',
      targetFrequency: (data['targetFrequency'] as int?) ?? 1,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'category': category,
      'targetFrequency': targetFrequency,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Habit copyWith({
    String? habitId,
    String? userId,
    String? title,
    String? category,
    int? targetFrequency,
    DateTime? createdAt,
  }) {
    return Habit(
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
