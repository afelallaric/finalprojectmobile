import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_auth_service.dart';
import '../services/user_firestore_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _firebaseAuthService;
  final UserFirestoreService _userFirestoreService;

  AuthRepositoryImpl({
    required FirebaseAuthService firebaseAuthService,
    required UserFirestoreService userFirestoreService,
  })  : _firebaseAuthService = firebaseAuthService,
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

      final userModel = await _userFirestoreService.getUserProfile(firebaseUser.uid);

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
}
