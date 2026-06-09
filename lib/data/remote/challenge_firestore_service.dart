import 'package:act_for_earth/domain/model/challenge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        createdBy: 'app',
      ),
      Challenge(
        title: 'Carbon Footprint Reduction',
        description: 'Reduce your carbon footprint by 20% this month.',
        duration: 30,
        createdBy: 'app',
      ),
      Challenge(
        title: 'No Plastic for 3 Days',
        description:
            'Challenge yourself to go plastic-free for 3 consecutive days.',
        duration: 3,
        createdBy: 'app',
      ),
      Challenge(
        title: 'Plant a Tree',
        description: 'Plant at least one tree in your community.',
        duration: 14,
        createdBy: 'app',
      ),
      Challenge(
        title: 'Energy Conservation Week',
        description: 'Reduce your energy consumption by 30% for one week.',
        duration: 7,
        createdBy: 'app',
      ),
    ];

    for (final challenge in defaultChallenges) {
      final docRef = challengesRef.doc();
      batch.set(docRef, challenge.toFirestore());
    }

    await batch.commit();
  }
}
