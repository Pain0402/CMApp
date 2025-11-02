import 'package:cached_network_image/cached_network_image.dart';
import 'package:mycomicsapp/features/comment/domain/entities/comment_entity.dart';
import 'package:flutter/material.dart';

/// A utility function to format a [DateTime] into a relative time string (e.g., "5 minutes ago").
String timeAgo(DateTime date) {
  final duration = DateTime.now().difference(date);
  if (duration.inDays > 365) return '${(duration.inDays / 365).floor()} years ago';
  if (duration.inDays > 30) return '${(duration.inDays / 30).floor()} months ago';
  if (duration.inDays > 0) return '${duration.inDays} days ago';
  if (duration.inHours > 0) return '${duration.inHours} hours ago';
  if (duration.inMinutes > 0) return '${duration.inMinutes} minutes ago';
  return 'Just now';
}

/// A widget to display a single comment item and its replies recursively.
class CommentListItem extends StatelessWidget {
  final CommentEntity comment;
  final Function(CommentEntity) onReply;
  final int depth;

  const CommentListItem({
    super.key,
    required this.comment,
    required this.onReply,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReply = depth > 0;

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 36.0 : 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isReply ? 16 : 20,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  backgroundImage:
                      comment.author.avatarUrl != null ? CachedNetworkImageProvider(comment.author.avatarUrl!) : null,
                  child: comment.author.avatarUrl == null ? Icon(Icons.person, size: isReply ? 16 : 20) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.author.displayName ?? 'User',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${timeAgo(comment.createdAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(comment.content, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => onReply(comment),
                        child: Text(
                          'Reply',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Recursively build replies.
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: comment.replies
                    .map((reply) => CommentListItem(
                          comment: reply,
                          onReply: onReply,
                          depth: depth + 1,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
