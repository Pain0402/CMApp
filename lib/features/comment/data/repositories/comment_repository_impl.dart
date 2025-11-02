import 'dart:async';
import 'package:mycomicsapp/features/comment/domain/entities/comment_entity.dart';
import 'package:mycomicsapp/features/comment/domain/repositories/comment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentRepositoryImpl implements CommentRepository {
  final SupabaseClient _supabaseClient;

  CommentRepositoryImpl(this._supabaseClient);

  @override
  Stream<List<CommentEntity>> watchComments(String chapterId) {
    final controller = StreamController<List<CommentEntity>>();
    RealtimeChannel? channel;

    Future<void> fetchAndEmitComments() async {
      try {
        final data = await _supabaseClient
            .from('Comment')
            .select('*, profiles!inner(id, display_name, avatar_url, role)')
            .eq('chapter_id', chapterId)
            .order('created_at', ascending: true);

        final comments = data.map((map) => CommentEntity.fromMap(map)).toList();
        if (!controller.isClosed) {
          controller.add(comments);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    // Initial fetch.
    fetchAndEmitComments();

    // Listen for real-time changes.
    channel = _supabaseClient
        .channel('public:Comment:chapter_id=eq.$chapterId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'Comment',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chapter_id',
            value: chapterId,
          ),
          callback: (payload) {
            // Refetch the entire list on any change.
            fetchAndEmitComments();
          },
        )
        .subscribe();

    // Close channel and controller when the stream is cancelled.
    controller.onCancel = () {
      if (channel != null) {
        _supabaseClient.removeChannel(channel);
      }
      controller.close();
    };

    return controller.stream;
  }

  @override
  Future<void> postComment({
    required String content,
    required String chapterId,
    String? parentCommentId,
  }) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    try {
      await _supabaseClient.from('Comment').insert({
        'user_id': user.id,
        'chapter_id': chapterId,
        'content': content,
        'parent_comment_id': parentCommentId,
      });
    } catch (e) {
      rethrow;
    }
  }
}
