import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    this.id = '',
    required this.name,
    required this.points,
  });

  final String id;

  final String name;
  final int points;

  factory LeaderboardEntry.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return LeaderboardEntry(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Unknown',
      points: (data['points'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'points': points};
  }

  LeaderboardEntry copyWith({String? id, String? name, int? points}) {
    return LeaderboardEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
    );
  }
}
