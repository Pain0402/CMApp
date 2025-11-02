import 'package:mycomicsapp/features/home/domain/entities/chapter.dart';
import 'package:mycomicsapp/features/home/domain/entities/story.dart';

/// A model that combines story information with its list of chapters.
class StoryDetails {
  final Story story;
  final List<Chapter> chapters;

  StoryDetails({required this.story, required this.chapters});

  /// Creates a [StoryDetails] instance from a Supabase RPC response.
  factory StoryDetails.fromRpcResponse(Map<String, dynamic> response) {
    final storyData = response['story'];
    final chaptersData = response['chapters'] as List?;

    return StoryDetails(
      story: Story.fromMap(storyData as Map<String, dynamic>),
      chapters: chaptersData?.map((c) => Chapter.fromMap(c as Map<String, dynamic>)).toList() ?? [],
    );
  }
}
