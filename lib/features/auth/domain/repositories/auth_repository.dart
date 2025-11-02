import 'package:supabase_flutter/supabase_flutter.dart';

/// Defines the contract for authentication functionalities.
/// This abstract class is independent of the specific auth provider (e.g., Supabase, Firebase).
abstract class AuthRepository {
  /// Stream that emits user authentication state changes (e.g., login, logout).
  Stream<User?> get authStateChanges;

  /// Gets the currently authenticated user, if any.
  User? get currentUser;

  /// Signs in a user with email and password.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  /// Signs up a new user with email and password.
  Future<void> signUp({required String email, required String password});

  /// Signs in a user using Google OAuth.
  Future<void> signInWithGoogle();

  /// Signs out the current user.
  Future<void> signOut();
}
