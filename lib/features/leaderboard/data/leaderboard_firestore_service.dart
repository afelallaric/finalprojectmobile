import 'package:act_for_earth/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardFirestoreService {
  LeaderboardFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore;

  static const String collectionName = 'leaderboard_entries';
  static const String currentUserDocId = 'current_user';

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _db.collection(collectionName);
  }

  Stream<List<LeaderboardEntry>> watchEntries() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs
          .map(LeaderboardEntry.fromFirestore)
          .toList(growable: false),
    );
  }

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

  Future<void> createEntry({required String name, required int points}) async {
    await _collection.add({'name': name, 'points': points});
  }

  Future<void> updateEntry(LeaderboardEntry entry) async {
    if (entry.id.isEmpty) {
      throw ArgumentError('Entry id cannot be empty for update.');
    }

    await _collection.doc(entry.id).update(entry.toFirestore());
  }

  Future<void> setCurrentUserPoints(int points) async {
    await _collection.doc(currentUserDocId).set({
      'name': 'You',
      'points': points,
    }, SetOptions(merge: true));
  }

  Future<void> deleteEntry(String id) async {
    if (id == currentUserDocId) {
      return;
    }

    await _collection.doc(id).delete();
  }
}
