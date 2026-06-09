import 'package:act_for_earth/domain/model/user_reward.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'rewards';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  Stream<UserReward?> watchUserReward(String userId) {
    return _collection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return UserReward.fromFirestore(doc);
    });
  }

  Future<UserReward> getOrCreateUserReward(String userId) async {
    final doc = await _collection.doc(userId).get();
    if (doc.exists) {
      return UserReward.fromFirestore(doc);
    } else {
      final newReward = UserReward(
        id: userId,
        userId: userId,
        points: 0,
        badges: const [],
      );
      await _collection.doc(userId).set(newReward.toFirestore());
      return newReward;
    }
  }

  Future<void> updatePointsAndBadges(
    String userId,
    int newPoints,
    List<String> badges,
  ) async {
    await _collection.doc(userId).set({
      'userId': userId,
      'points': newPoints,
      'badges': badges,
    }, SetOptions(merge: true));
  }

  Future<void> addPoints(String userId, int amount) async {
    final current = await getOrCreateUserReward(userId);
    final nextPoints = (current.points + amount).clamp(0, 999999);
    await updatePointsAndBadges(userId, nextPoints, current.badges);
  }

  Future<void> subtractPoints(String userId, int amount) async {
    final current = await getOrCreateUserReward(userId);
    final nextPoints = (current.points - amount).clamp(0, 999999);
    await updatePointsAndBadges(userId, nextPoints, current.badges);
  }

  Future<void> addBadge(String userId, String badge) async {
    final current = await getOrCreateUserReward(userId);
    if (!current.badges.contains(badge)) {
      final updatedBadges = List<String>.from(current.badges)..add(badge);
      await updatePointsAndBadges(userId, current.points, updatedBadges);
    }
  }
}
