import 'dart:io';
import 'package:mycomicsapp/features/auth/domain/entities/profile.dart';
import 'package:mycomicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:mycomicsapp/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mycomicsapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [ProfileRepository] implementation.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ProfileRepositoryImpl(supabaseClient);
});

/// A stream provider that fetches and provides the current user's profile.
final userProfileProvider = StreamProvider.autoDispose<Profile?>((ref) async* {
  final profileRepository = ref.watch(profileRepositoryProvider);
  yield await profileRepository.getUserProfile();
  // In the future, this could watch other streams for real-time updates.
});

/// A [StateNotifierProvider] to manage the state of profile update operations.
final profileUpdaterProvider =
    StateNotifierProvider<ProfileUpdaterNotifier, AsyncValue<void>>((ref) {
      return ProfileUpdaterNotifier(ref);
    });

class ProfileUpdaterNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ProfileUpdaterNotifier(this._ref) : super(const AsyncData(null));

  Future<void> updateProfile({
    required String displayName,
    File? avatarFile,
  }) async {
    state = const AsyncLoading();
    final user = _ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    try {
      await _ref
          .read(profileRepositoryProvider)
          .updateUserProfile(
            userId: user.id,
            displayName: displayName,
            avatarFile: avatarFile,
          );
      // Invalidate the profile provider to refetch the updated data.
      _ref.invalidate(userProfileProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
