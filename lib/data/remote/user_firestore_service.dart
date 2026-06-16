import 'package:act_for_earth/domain/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';

  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Stream<UserModel?> watchUserProfile(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return null;
          }
          return UserModel.fromFirestore(doc);
        })
        .handleError((error) {
          throw Exception('Failed to watch user profile: $error');
        });
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }
}
