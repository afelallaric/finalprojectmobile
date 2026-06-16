import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  const Challenge({
    this.challengeId = '',
    required this.title,
    required this.description,
    required this.duration,
    required this.createdBy,
    this.points,
  });

  final String challengeId;
  final String title;
  final String description;
  final int duration;
  final String createdBy;
  final int? points;

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
      points: data['points'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'createdBy': createdBy,
      if (points != null) 'points': points,
    };
  }

  Challenge copyWith({
    String? challengeId,
    String? title,
    String? description,
    int? duration,
    String? createdBy,
    int? points,
  }) {
    return Challenge(
      challengeId: challengeId ?? this.challengeId,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      createdBy: createdBy ?? this.createdBy,
      points: points ?? this.points,
    );
  }
}
