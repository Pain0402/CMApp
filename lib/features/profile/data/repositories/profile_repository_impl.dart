import 'dart:io';
import 'package:mycomicsapp/features/auth/domain/entities/profile.dart';
import 'package:mycomicsapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabaseClient;

  ProfileRepositoryImpl(this._supabaseClient);

  @override
  Future<Profile?> getUserProfile() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      // Use an RPC to get combined profile and stats data.
      final data = await _supabaseClient
          .rpc('get_user_profile_details', params: {'p_user_id': user.id})
          .single();

      return Profile.fromMap(data);
    } catch (e) {
      print('Error fetching profile details: $e');
      return null;
    }
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    File? avatarFile,
  }) async {
    try {
      String? avatarUrl;
      if (avatarFile != null) {
        final fileName =
            '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'avatars/$userId/$fileName';

        // Upload to the 'public_avatar' bucket.
        await _supabaseClient.storage
            .from('public_avatar')
            .upload(
              filePath,
              avatarFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        avatarUrl = _supabaseClient.storage
            .from('public_avatar')
            .getPublicUrl(filePath);
      }

      final updates = <String, dynamic>{'display_name': displayName};

      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      await _supabaseClient.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }
}
