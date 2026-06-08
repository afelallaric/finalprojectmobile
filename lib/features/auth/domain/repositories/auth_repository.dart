import '../models/user_model.dart';

abstract class AuthRepository {
  /// Register a new user with email and password
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  });

  /// Login user with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Logout the current user
  Future<void> logout();

  /// Get current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> get isAuthenticated;

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;
}
