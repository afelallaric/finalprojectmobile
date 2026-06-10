import 'package:act_for_earth/domain/model/user_challenge.dart';
import 'package:act_for_earth/data/remote/reward_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserChallengeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RewardFirestoreService _rewardService;

  UserChallengeFirestoreService({
    RewardFirestoreService? rewardService,
  }) : _rewardService = rewardService ?? RewardFirestoreService();

  Stream<List<UserChallenge>> watchUserChallenges(String userId) {
    return _firestore
        .collection('user_challenges')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserChallenge.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> joinChallenge(String userId, String challengeId) async {
    final userChallenge = UserChallenge(
      userId: userId,
      challengeId: challengeId,
    );
    await _firestore
        .collection('user_challenges')
        .add(userChallenge.toFirestore());
  }

  Future<void> updateProgress(String userChallengeId, int progress) async {
    await _firestore.collection('user_challenges').doc(userChallengeId).update({
      'progress': progress,
    });
  }

  Future<void> completeChallenge(
    String userChallengeId, {
    String? userId,
    String? challengeId,
    int? points,
  }) async {
    await _firestore.collection('user_challenges').doc(userChallengeId).update({
      'status': 'completed',
      'progress': 100,
      if (userId != null && points != null && points > 0)
        'pointsAwarded': true,
    });

    // Award points to user if parameters provided and points > 0
    if (userId != null && points != null && points > 0) {
      await _rewardService.addPoints(userId, points);
    }
  }

  Future<void> leaveChallenge(String userChallengeId) async {
    await _firestore
        .collection('user_challenges')
        .doc(userChallengeId)
        .delete();
  }
}
