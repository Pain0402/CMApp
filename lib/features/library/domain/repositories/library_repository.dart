import 'package:mycomicsapp/features/home/domain/entities/story.dart';

abstract class LibraryRepository {
  /// Fetches a list of all stories bookmarked by the current user.
  Future<List<Story>> getBookmarkedStories();

  /// Checks if a specific story is bookmarked by the current user.
  Future<bool> isStoryBookmarked(String storyId);

  /// Adds a story to the current user's bookmarks.
  Future<void> addStoryToBookmarks(String storyId);

  /// Removes a story from the current user's bookmarks.
  Future<void> removeStoryFromBookmarks(String storyId);
}
