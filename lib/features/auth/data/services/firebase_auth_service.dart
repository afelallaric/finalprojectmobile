import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Sign up user with email and password
  /// Throws FirebaseAuthException on failure
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in user with email and password
  /// Throws FirebaseAuthException on failure
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Get current authenticated user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  /// Handle Firebase Auth exceptions with user-friendly messages
  FirebaseAuthException _handleAuthException(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found with this email address.',
      );
    } else if (e.code == 'wrong-password') {
      throw FirebaseAuthException(
        code: 'wrong-password',
        message: 'Incorrect password. Please try again.',
      );
    } else if (e.code == 'email-already-in-use') {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'An account already exists with this email.',
      );
    } else if (e.code == 'weak-password') {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Password should be at least 6 characters.',
      );
    } else if (e.code == 'invalid-email') {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter a valid email address.',
      );
    } else {
      return e;
    }
  }
}
