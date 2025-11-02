import 'package:mycomicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:mycomicsapp/features/library/data/repositories/library_repository_impl.dart';
import 'package:mycomicsapp/features/library/domain/repositories/library_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides an instance of [LibraryRepository].
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return LibraryRepositoryImpl(supabaseClient);
});

/// Fetches the list of bookmarked stories.
final bookmarkedStoriesProvider = FutureProvider<List<Story>>((ref) async {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  return libraryRepository.getBookmarkedStories();
});

/// A [StateNotifierProvider] to manage the bookmark status of a specific story.
final isBookmarkedProvider = StateNotifierProvider.family<IsBookmarkedNotifier, AsyncValue<bool>, String>((ref, storyId) {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  return IsBookmarkedNotifier(libraryRepository, storyId);
});

class IsBookmarkedNotifier extends StateNotifier<AsyncValue<bool>> {
  final LibraryRepository _libraryRepository;
  final String _storyId;

  IsBookmarkedNotifier(this._libraryRepository, this._storyId) : super(const AsyncValue.loading()) {
    _checkIfBookmarked();
  }

  Future<void> _checkIfBookmarked() async {
    try {
      final isBookmarked = await _libraryRepository.isStoryBookmarked(_storyId);
      state = AsyncValue.data(isBookmarked);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Toggles the bookmark status of the story.
  Future<void> toggleBookmark() async {
    final previousState = state.value;
    if (previousState == null) return;

    // Optimistically update the UI for a faster user experience.
    state = AsyncValue.data(!previousState);

    try {
      if (!previousState) {
        await _libraryRepository.addStoryToBookmarks(_storyId);
      } else {
        await _libraryRepository.removeStoryFromBookmarks(_storyId);
      }
    } catch (e, st) {
      // If an error occurs, revert to the previous state.
      state = AsyncValue.data(previousState);
      print('Error toggling bookmark: $e');
    }
  }
}
