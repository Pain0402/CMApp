import 'package:cached_network_image/cached_network_image.dart';
import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


String? resolveImageUrl(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.startsWith('http')) return value;
  return Supabase.instance.client.storage.from('stories').getPublicUrl(value);
}

// Helper functions for shimmer colors based on theme.
Color _baseShimmer(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;

Color _highlightShimmer(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

/// A card widget to display a summary of a story, used in grids.
class StoryCard extends StatelessWidget {
  final Story story;
  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = resolveImageUrl(story.coverImageUrl);

    return InkWell(
      onTap: () {
        // Navigate to the story details screen, passing the story object
        // for the Hero animation to work.
        context.push('/story/${story.storyId}', extra: story);
      },
      borderRadius: BorderRadius.circular(16), // Ripple effect border radius
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        elevation: 0.5,
        color: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image takes up a fixed portion of the card height.
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'story-cover-${story.storyId}',
                child: imageUrl == null
                    ? Container(
                        color: theme.colorScheme.surfaceVariant,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported_outlined),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: _baseShimmer(context),
                          highlightColor: _highlightShimmer(context),
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceVariant,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
            ),
            // Text content takes the remaining space.
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // UPDATE: Changed to spaceEvenly
                  children: [
                    Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A specialized card for the ranked stories carousel.
class RankingStoryCard extends StatelessWidget {
  final Story story;
  final int rank;
  const RankingStoryCard({super.key, required this.story, required this.rank});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = resolveImageUrl(story.coverImageUrl);

    return InkWell(
      onTap: () {
        context.push('/story/${story.storyId}', extra: story);
      },
      borderRadius: BorderRadius.circular(24),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'story-cover-${story.storyId}',
              child: imageUrl == null
                  ? Container(
                      color: theme.colorScheme.surfaceVariant,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: _baseShimmer(context),
                        highlightColor: _highlightShimmer(context),
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
            // Gradient overlay for better text readability.
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.85),
                  ],
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Rank chip
            Positioned(
              top: 12,
              left: 12,
              child: Chip(
                label: Text('TOP $rank'),
                backgroundColor: theme.colorScheme.secondaryContainer,
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            // Title
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Text(
                story.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

