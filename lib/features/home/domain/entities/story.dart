import 'package:mycomicsapp/features/auth/domain/entities/profile.dart';

/// Represents the data model for a single story.
class Story {
  final String storyId;
  final Profile author;
  final String title;
  final String? synopsis;
  final String? coverImageUrl;
  final String status;
  final bool isVipOnly;
  final double averageRating;
  final int totalReads;
  final DateTime createdAt;
  final DateTime updatedAt;

  Story({
    required this.storyId,
    required this.author,
    required this.title,
    this.synopsis,
    this.coverImageUrl,
    required this.status,
    required this.isVipOnly,
    required this.averageRating,
    required this.totalReads,
    required this.createdAt,
    required this.updatedAt,
  });

  /// A robust factory constructor to create a Story instance from a map.
  /// It handles potential null values and data type inconsistencies from the database.
  factory Story.fromMap(Map<String, dynamic> map) {
    final num totalReadsNum = map['total_reads'] ?? 0;

    return Story(
      storyId: map['story_id'] ?? '',
      // Handle cases where 'profiles' might be null or not a map.
      author: map['profiles'] is Map<String, dynamic>
          ? Profile.fromEmbeddedMap(map['profiles'] as Map<String, dynamic>)
          : Profile(id: map['author_id'] ?? '', displayName: 'Unknown Author'),
      title: map['title'] ?? 'No Title',
      synopsis: map['synopsis'],
      coverImageUrl: map['cover_image_url'],
      status: map['status'] ?? 'draft',
      isVipOnly: map['is_vip_only'] ?? false,
      // Safely convert any number type to double.
      averageRating: (map['average_rating'] as num?)?.toDouble() ?? 0.0,
      // Safely convert from num (int or double) to int.
      totalReads: totalReadsNum.toInt(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }
}

