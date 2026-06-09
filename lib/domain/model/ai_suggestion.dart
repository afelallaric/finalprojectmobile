import 'package:cloud_firestore/cloud_firestore.dart';

class AISuggestion {
  final String suggestionId;
  final String userId;
  final String text;
  final String status; // 'pending' or 'completed'
  final DateTime createdAt;

  const AISuggestion({
    required this.suggestionId,
    required this.userId,
    required this.text,
    required this.status,
    required this.createdAt,
  });

  factory AISuggestion.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return AISuggestion(
      suggestionId: doc.id,
      userId: (data['userId'] as String?) ?? '',
      text: (data['suggestionText'] as String?) ?? (data['text'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'suggestionText': text,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AISuggestion copyWith({
    String? suggestionId,
    String? userId,
    String? text,
    String? status,
    DateTime? createdAt,
  }) {
    return AISuggestion(
      suggestionId: suggestionId ?? this.suggestionId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
