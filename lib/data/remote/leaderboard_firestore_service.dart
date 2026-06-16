import 'package:act_for_earth/domain/model/leaderboard_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardFirestoreService {
  LeaderboardFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore;

  static const String collectionName = 'leaderboard_entries';

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _db.collection(collectionName);
  }

  /// Watch all leaderboard entries, sorted descending by points.
  Stream<List<LeaderboardEntry>> watchEntries() {
    return _collection
        .orderBy('points', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(LeaderboardEntry.fromFirestore)
              .toList(growable: false),
        );
  }

  /// Seed the leaderboard with non-user placeholder entries if the collection
  /// is empty. The current user's entry is always upserted separately via
  /// [upsertUserEntry].
  Future<void> seedDefaults(List<LeaderboardEntry> defaults) async {
    final snapshot = await _collection.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final batch = _db.batch();
    for (final entry in defaults) {
      final docRef = entry.id.isEmpty
          ? _collection.doc()
          : _collection.doc(entry.id);
      batch.set(docRef, entry.toFirestore());
    }

    await batch.commit();
  }

  /// Upsert the logged-in user's leaderboard entry using their UID as doc ID.
  /// This keeps reward points and the leaderboard in sync.
  Future<void> upsertUserEntry({
    required String userId,
    required String displayName,
    required int points,
  }) async {
    await _collection.doc(userId).set({
      'name': displayName,
      'points': points,
      'isCurrentUser': true,
    }, SetOptions(merge: true));
  }
}
