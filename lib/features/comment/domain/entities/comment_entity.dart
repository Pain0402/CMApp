import 'package:mycomicsapp/features/auth/domain/entities/profile.dart';

class CommentEntity {
  final String id;
  final String content;
  final DateTime createdAt;
  final Profile author;
  final String? parentId;
  final List<CommentEntity> replies;

  CommentEntity({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.author,
    this.parentId,
    List<CommentEntity>? replies,
  }) : replies = replies ?? []; // Default to an empty list if null.

  /// Creates a [CommentEntity] from a map (JSON data) from Supabase.
  factory CommentEntity.fromMap(Map<String, dynamic> map) {
    return CommentEntity(
      id: map['comment_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      author: map['profiles'] != null && map['profiles'] is Map<String, dynamic>
          ? Profile.fromEmbeddedMap(map['profiles'] as Map<String, dynamic>)
          : Profile(id: map['user_id'], displayName: 'Anonymous User'),
      parentId: map['parent_comment_id'] as String?,
    );
  }

  /// Creates a copy of this comment with new replies.
  CommentEntity copyWith({
    List<CommentEntity>? replies,
  }) {
    return CommentEntity(
      id: id,
      content: content,
      createdAt: createdAt,
      author: author,
      parentId: parentId,
      replies: replies ?? this.replies,
    );
  }
}
