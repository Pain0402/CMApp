import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:mycomicsapp/features/library/domain/repositories/library_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final SupabaseClient _supabaseClient;

  LibraryRepositoryImpl(this._supabaseClient);

  @override
  Future<void> addStoryToBookmarks(String storyId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw const AuthException('User is not authenticated');

    await _supabaseClient.from('User_Bookmarked_Stories').insert({
      'user_id': user.id,
      'story_id': storyId,
    });
  }

  @override
  Future<List<Story>> getBookmarkedStories() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return [];

    // Select bookmarked stories and join with the Story and Profile tables.
    final data = await _supabaseClient
        .from('User_Bookmarked_Stories')
        .select('*, Story!inner(*, profiles:author_id(*))')
        .eq('user_id', user.id)
        .order('bookmarked_at', ascending: false);

    return data.map((item) => Story.fromMap(item['Story'])).toList();
  }

  @override
  Future<bool> isStoryBookmarked(String storyId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return false;

    final data = await _supabaseClient
        .from('User_Bookmarked_Stories')
        .select()
        .eq('user_id', user.id)
        .eq('story_id', storyId)
        .limit(1)
        .maybeSingle();

    return data != null;
  }

  @override
  Future<void> removeStoryFromBookmarks(String storyId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw const AuthException('User is not authenticated');

    await _supabaseClient.from('User_Bookmarked_Stories').delete().eq('user_id', user.id).eq('story_id', storyId);
  }
}
