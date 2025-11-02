// import 'package:mycomicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:mycomicsapp/features/home/data/repositories/story_repository_impl.dart';
import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycomicsapp/features/home/domain/entities/story_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the singleton instance of the Supabase client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

// Provides the StoryRepository instance.
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StoryRepository(client);
});

// Provider to fetch the list of all stories.
final allStoriesProvider = FutureProvider<List<Story>>((ref) async {
  final repository = ref.watch(storyRepositoryProvider);
  return repository.getAllStories();
});

// It uses .family to pass the storyId as a parameter.
final storyDetailsProvider =
    FutureProvider.autoDispose.family<StoryDetails, String>((ref, storyId) {
  final storyRepository = ref.watch(storyRepositoryProvider);
  return storyRepository.getStoryDetails(storyId);
});
