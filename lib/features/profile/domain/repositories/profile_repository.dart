import 'dart:io';
import 'package:mycomicsapp/features/auth/domain/entities/profile.dart';

abstract class ProfileRepository {
  /// Fetches the profile information of the current user.
  Future<Profile?> getUserProfile();

  /// Updates the user's profile information.
  Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    File? avatarFile,
  });

  /// Signs out the current user.
  Future<void> signOut();
}
