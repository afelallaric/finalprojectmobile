import 'package:act_for_earth/domain/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class UserFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';

  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e, stack) {
      FirebaseCrashlytics.instance.log('Failed to create user profile: id=${user.id}');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Create user profile firestore error');
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
    } catch (e, stack) {
      FirebaseCrashlytics.instance.log('Failed to get user profile: id=$userId');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Get user profile firestore error');
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update(data);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.log('Failed to update user profile: id=$userId');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Update user profile firestore error');
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
        .handleError((error, stack) {
          FirebaseCrashlytics.instance.log('Failed to watch user profile: id=$userId');
          FirebaseCrashlytics.instance.recordError(error, stack, reason: 'Watch user profile stream error');
          throw Exception('Failed to watch user profile: $error');
        });
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.log('Failed to delete user profile: id=$userId');
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Delete user profile firestore error');
      throw Exception('Failed to delete user profile: $e');
    }
  }
}
