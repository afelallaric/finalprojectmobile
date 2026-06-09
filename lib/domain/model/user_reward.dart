import 'package:cloud_firestore/cloud_firestore.dart';

class UserReward {
  final String id;
  final String userId;
  final int points;
  final List<String> badges;

  const UserReward({
    required this.id,
    required this.userId,
    required this.points,
    required this.badges,
  });

  factory UserReward.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserReward(
      id: doc.id,
      userId: (data['userId'] as String?) ?? doc.id,
      points: (data['points'] as int?) ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'points': points,
      'badges': badges,
    };
  }

  UserReward copyWith({
    String? id,
    String? userId,
    int? points,
    List<String>? badges,
  }) {
    return UserReward(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      badges: badges ?? this.badges,
    );
  }
}
