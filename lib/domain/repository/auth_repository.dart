import 'package:act_for_earth/domain/model/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<UserModel> login({required String email, required String password});

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<bool> get isAuthenticated;

  Stream<UserModel?> get authStateChanges;
}
