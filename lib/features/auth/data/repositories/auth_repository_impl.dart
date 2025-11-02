import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

/// Supabase implementation of the [AuthRepository].
/// All Supabase-specific authentication logic resides here.
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Stream<User?> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange.map((authState) => authState.session?.user);

  @override
  User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Re-throw the exception to be handled by the presentation layer.
      rethrow;
    }
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _supabaseClient.auth.signUp(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      // This function automatically opens a web view for the user to sign in
      // and handles the redirect back to the app, thanks to the native configurations.
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        // The URL to which the browser will redirect after a successful sign-in.
        redirectTo: 'com.example.mycomicsapp://callback',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
