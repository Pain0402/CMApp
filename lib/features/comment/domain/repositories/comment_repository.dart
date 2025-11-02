import 'package:mycomicsapp/features/comment/domain/entities/comment_entity.dart';

/// Abstract interface for managing comment data.
abstract class CommentRepository {
  /// Watches and returns a stream of comments for a specific chapter.
  /// Uses a [Stream] for real-time updates.
  Stream<List<CommentEntity>> watchComments(String chapterId);

  /// Posts a new comment.
  Future<void> postComment({
    required String content,
    required String chapterId,
    String? parentCommentId,
  });
}
