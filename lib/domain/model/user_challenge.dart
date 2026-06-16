import 'package:cloud_firestore/cloud_firestore.dart';

class UserChallenge {
  const UserChallenge({
    this.userChallengeId = '',
    required this.userId,
    required this.challengeId,
    this.progress = 0,
    this.status = 'joined',
    this.pointsAwarded = false,
  });

  final String userChallengeId;
  final String userId;
  final String challengeId;
  final int progress;
  final String status;
  final bool pointsAwarded;

  factory UserChallenge.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return UserChallenge(
      userChallengeId: doc.id,
      userId: (data['userId'] as String?) ?? 'Unknown User',
      challengeId: (data['challengeId'] as String?) ?? 'Unknown Challenge',
      progress: (data['progress'] as int?) ?? 0,
      status: (data['status'] as String?) ?? 'joined',
      pointsAwarded: (data['pointsAwarded'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'progress': progress,
      'status': status,
      'pointsAwarded': pointsAwarded,
    };
  }

  UserChallenge copyWith({
    String? userChallengeId,
    String? userId,
    String? challengeId,
    int? progress,
    String? status,
    bool? pointsAwarded,
  }) {
    return UserChallenge(
      userChallengeId: userChallengeId ?? this.userChallengeId,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
    );
  }
}
