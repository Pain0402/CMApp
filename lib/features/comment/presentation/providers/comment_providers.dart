import 'package:mycomicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:mycomicsapp/features/comment/data/repositories/comment_repository_impl.dart';
import 'package:mycomicsapp/features/comment/domain/entities/comment_entity.dart';
import 'package:mycomicsapp/features/comment/domain/repositories/comment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides an instance of [CommentRepository].
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return CommentRepositoryImpl(supabaseClient);
});

/// A stream provider that watches the flat list of comments for a chapter.
final commentsStreamProvider = StreamProvider.autoDispose.family<List<CommentEntity>, String>((ref, chapterId) {
  final commentRepository = ref.watch(commentRepositoryProvider);
  return commentRepository.watchComments(chapterId);
});

/// A provider that transforms the flat list of comments into a nested (tree) structure.
final nestedCommentsProvider = Provider.autoDispose.family<List<CommentEntity>, String>((ref, chapterId) {
  final commentsAsync = ref.watch(commentsStreamProvider(chapterId));

  return commentsAsync.when(
    data: (flatList) {
      final repliesMap = <String, List<CommentEntity>>{};
      final topLevelComments = <CommentEntity>[];

      // Group comments by their parent ID.
      for (final comment in flatList) {
        if (comment.parentId != null) {
          (repliesMap[comment.parentId!] ??= []).add(comment);
        } else {
          topLevelComments.add(comment);
        }
      }

      // Assign replies to their parent comments.
      final result = topLevelComments.map((parentComment) {
        if (repliesMap.containsKey(parentComment.id)) {
          return parentComment.copyWith(replies: repliesMap[parentComment.id]);
        }
        return parentComment;
      }).toList();

      return result;
    },
    loading: () => [],
    error: (e, st) => [],
  );
});

/// A [StateNotifierProvider] to manage the state of posting a comment.
final commentPostControllerProvider = StateNotifierProvider.autoDispose<CommentPostController, AsyncValue<void>>((ref) {
  return CommentPostController(ref.watch(commentRepositoryProvider));
});

class CommentPostController extends StateNotifier<AsyncValue<void>> {
  final CommentRepository _commentRepository;

  CommentPostController(this._commentRepository) : super(const AsyncData(null));

  /// Posts a comment and manages the loading/error states.
  Future<void> postComment({
    required String content,
    required String chapterId,
    String? parentCommentId,
  }) async {
    state = const AsyncLoading();
    try {
      await _commentRepository.postComment(
        content: content,
        chapterId: chapterId,
        parentCommentId: parentCommentId,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
