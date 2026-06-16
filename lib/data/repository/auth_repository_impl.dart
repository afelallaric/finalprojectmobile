import 'package:act_for_earth/data/remote/firebase_auth_service.dart';
import 'package:act_for_earth/data/remote/user_firestore_service.dart';
import 'package:act_for_earth/domain/model/user_model.dart';
import 'package:act_for_earth/domain/repository/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _firebaseAuthService;
  final UserFirestoreService _userFirestoreService;

  AuthRepositoryImpl({
    required FirebaseAuthService firebaseAuthService,
    required UserFirestoreService userFirestoreService,
  }) : _firebaseAuthService = firebaseAuthService,
       _userFirestoreService = userFirestoreService;

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final firebaseUser = await _firebaseAuthService.signUpWithEmail(
        email: email,
        password: password,
      );

      if (firebaseUser == null) {
        throw Exception('Registration failed: User is null');
      }

      final userModel = UserModel(
        id: firebaseUser.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _userFirestoreService.createUserProfile(userModel);

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final firebaseUser = await _firebaseAuthService.signInWithEmail(
        email: email,
        password: password,
      );

      if (firebaseUser == null) {
        throw Exception('Login failed: User is null');
      }

      final userModel = await _userFirestoreService.getUserProfile(
        firebaseUser.uid,
      );

      if (userModel == null) {
        throw Exception('User profile not found in Firestore');
      }

      return userModel;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuthService.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuthService.getCurrentUser();

      if (firebaseUser == null) {
        return null;
      }

      return await _userFirestoreService.getUserProfile(firebaseUser.uid);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<bool> get isAuthenticated async {
    return _firebaseAuthService.getCurrentUser() != null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuthService.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      try {
        return await _userFirestoreService.getUserProfile(firebaseUser.uid);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      final user = _firebaseAuthService.getCurrentUser();
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('No user is currently signed in.');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      // 1. Delete user from Firestore collections
      await _userFirestoreService.deleteUserProfile(userId);
      
      // Delete rewards collection entry for the user
      await FirebaseFirestore.instance.collection('rewards').doc(userId).delete();
      
      // Delete leaderboard collection entry for the user
      await FirebaseFirestore.instance.collection('leaderboard_entries').doc(userId).delete();

      // 2. Delete user from Firebase Auth
      final user = _firebaseAuthService.getCurrentUser();
      if (user != null) {
        await user.delete();
      } else {
        throw Exception('No user is currently signed in.');
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
