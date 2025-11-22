import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:mycomicsapp/features/auth/domain/entities/profile.dart';
import 'package:mycomicsapp/features/home/domain/entities/story_details.dart';
import 'package:mycomicsapp/features/home/presentation/providers/home_providers.dart';

class StoryRepository {
  final SupabaseClient _client;
  StoryRepository(this._client);

  /// Fetches all stories, ordered by the most recently updated.
  Future<List<Story>> getAllStories() async {
    try {
      final data = await _client.from('Story').select().order('updated_at', ascending: false);
      return data.map((item) => Story.fromMap(item)).toList();
    } catch (e) {
      // In a real application, use a proper logging system.
      print('Error fetching stories: $e');
      rethrow;
    }
  }

  /// Fetches detailed information for a single story using an RPC.
  Future<StoryDetails> getStoryDetails(String storyId) async {
    try {
      final rpcResponse = await _client.rpc(
        'get_story_details',
        params: {'p_story_id': storyId},
      );
      final initialDetails = StoryDetails.fromRpcResponse(rpcResponse as Map<String, dynamic>);

      final storyData = await _client
          .from('Story')
          .select('*, profiles:author_id(*)') 
          .eq('story_id', storyId)
          .single();
      
      final richStory = Story.fromMap(storyData);
      return StoryDetails(
        story: richStory,
        chapters: initialDetails.chapters,
      );
    } catch (e) {
      print('Error fetching story details: $e');
      rethrow;
    }
  }

   /// Fetches ranked stories based on the specified type.
  Future<List<Story>> getRankedStories(RankingType type) async {
    try {
      dynamic query = _client.from('Story').select('*, profiles:author_id(*)');

      switch (type) {
        case RankingType.weekly:
        case RankingType.monthly:
          query = query.order('total_reads', ascending: false);
          break;
        case RankingType.trending:
          query = query.order('average_rating', ascending: false);
          break;
        case RankingType.newcomers:
          query = query.order('created_at', ascending: false);
          break;
      }

      final data = await query.limit(20);
      return (data as List).map((item) => Story.fromMap(item)).toList();
    } catch (e) {
      print('Error fetching ranked stories: $e');
      rethrow;
    }
  }

  /// Fetches the profile of the current user.
  Future<Profile?> getUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final data = await _client.from('profiles').select().eq('id', user.id).single();
      return Profile.fromMap(data);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}
