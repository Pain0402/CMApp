import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:mycomicsapp/features/home/presentation/providers/home_providers.dart';
import 'package:mycomicsapp/features/home/presentation/widgets/story_card.dart'; // For resolveImageUrl
import 'package:shimmer/shimmer.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final tabs = [
      {'label': 'Top Weekly', 'type': RankingType.weekly},
      {'label': 'Top Monthly', 'type': RankingType.monthly},
      {'label': 'Trending', 'type': RankingType.trending},
      {'label': 'Newcomers', 'type': RankingType.newcomers},
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: tabs.map((t) => Tab(text: t['label'] as String)).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((t) {
            return _RankingList(rankingType: t['type'] as RankingType);
          }).toList(),
        ),
      ),
    );
  }
}

class _RankingList extends ConsumerWidget {
  final RankingType rankingType;

  const _RankingList({required this.rankingType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(rankingStoriesProvider(rankingType));
    final theme = Theme.of(context);

    return rankingAsync.when(
      loading: () => _buildLoadingSkeleton(context),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (stories) {
        if (stories.isEmpty) {
          return const Center(child: Text('No stories found in this ranking.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            final story = stories[index];
            final rank = index + 1;
            
            Color rankColor;
            if (rank == 1) {
              rankColor = const Color(0xFFFFD700); // Vàng
            } else if (rank == 2) {
              rankColor = const Color(0xFFC0C0C0); // Bạc
            } else if (rank == 3) {
              rankColor = const Color(0xFFCD7F32); // Đồng
            } else {
              rankColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.5);
            }

            final imageUrl = resolveImageUrl(story.coverImageUrl);

            return InkWell(
              onTap: () => context.push('/story/${story.storyId}', extra: story),
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Rank Number
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            '#$rank',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: rankColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Story Cover
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 60,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.grey[300]),
                                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                              )
                            : Container(
                                width: 60,
                                height: 80,
                                color: Colors.grey,
                                child: const Icon(Icons.image_not_supported),
                              ),
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story.author.displayName ?? 'Unknown Author',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.remove_red_eye_outlined, size: 14, color: theme.colorScheme.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${story.totalReads}',
                                  style: theme.textTheme.labelSmall,
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.star_rate_rounded, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  story.averageRating.toStringAsFixed(1),
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Arrow
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(width: 40, height: 40, color: Colors.white),
              const SizedBox(width: 12),
              Container(width: 60, height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 150, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 100, color: Colors.white),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}