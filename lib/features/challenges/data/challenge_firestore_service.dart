// 3. Create `lib/features/challenges/data/challenge_firestore_service.dart`:
//    - CRUD: `createChallenge()`, `watchChallenges()`, `deleteChallenge()`
//    - Seed: `seedDefaultChallenges()` (eco-themed: plastic-free, carbon footprint, etc.)
//    - Batch operations for efficiency
//    - Collection: `challenges`

import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/challenge.dart';

class ChallengeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createChallenge(Challenge challenge) async {
    await _firestore.collection('challenges').add(challenge.toFirestore());
  } 

  Stream<List<Challenge>> watchChallenges() {
    return _firestore.collection('challenges').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Challenge.fromFirestore(doc)).toList();
    }); 
  } 

  Future<void> deleteChallenge(String challengeId) async {
    await _firestore.collection('challenges').doc(challengeId).delete();
  }

  Future<void> seedDefaultChallenges() async {
    final batch = _firestore.batch();
    final challengesRef = _firestore.collection('challenges');

    final defaultChallenges = [
      Challenge(
        title: 'Plastic-Free Week',
        description: 'Avoid using single-use plastics for one week.',
        duration: 7,
        createdBy: 'admin',
      ),
      Challenge(
        title: 'Carbon Footprint Reduction',
        description: 'Reduce your carbon footprint by 20% this month.',
        duration: 30,
        createdBy: 'admin',
      ),
    ];

    for (var challenge in defaultChallenges) {
      final docRef = challengesRef.doc();
      batch.set(docRef, challenge.toFirestore());
    }
  }
}