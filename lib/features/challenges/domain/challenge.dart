// Create `lib/features/challenges/domain/challenge.dart` — Immutable model with:
//    - `challengeId`, `title`, `description`, `duration`, `createdBy`
//    - `fromFirestore()`, `toFirestore()`, `copyWith()`

import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  const Challenge({
    this.challengeId = '',
    required this.title,
    required this.description,
    required this.duration,
    required this.createdBy,
  });

  final String challengeId;
  final String title;
  final String description;
  final int duration; // in days
  final String createdBy;

  factory Challenge.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return Challenge(
      challengeId: doc.id, 
      title: (data['title'] as String?) ?? 'Untitled Challenge',
      description: data['description'] as String? ?? '',
      duration: (data['duration'] as int?) ?? 0,
      createdBy: (data['createdBy'] as String?) ?? 'Unknown',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'createdBy': createdBy,
    };
  }

  Challenge copyWith({
    String? challengeId,
    String? title,
    String? description,
    int? duration,
    String? createdBy, 
  }) {
    return Challenge(
      challengeId: challengeId ?? this.challengeId,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}