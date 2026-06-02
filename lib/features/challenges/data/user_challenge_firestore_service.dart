import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/userChallenge.dart';

class UserChallengeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserChallenge>> watchUserChallenges(String userId) {
    return _firestore
        .collection('user_challenges')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => UserChallenge.fromFirestore(doc)).toList();
        }); 
  }

  Future<void> joinChallenge(String userId, String challengeId) async {
    final userChallenge = UserChallenge(
      userId: userId,
      challengeId: challengeId,
    );
    await _firestore.collection('user_challenges').add(userChallenge.toFirestore());
  }

  Future<void> updateProgress(String userChallengeId, int progress) async {
    await _firestore.collection('user_challenges').doc(userChallengeId).update({
      'progress': progress,
    });
  }

  Future<void> completeChallenge(String userChallengeId) async {
    await _firestore.collection('user_challenges').doc(userChallengeId).update({
      'status': 'completed',
      'progress': 100,
    });
  }

  Future<void> leaveChallenge(String userChallengeId) async {
    await _firestore.collection('user_challenges').doc(userChallengeId).delete();
  }
}