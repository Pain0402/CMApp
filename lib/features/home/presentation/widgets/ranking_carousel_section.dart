import 'package:carousel_slider/carousel_slider.dart';
import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:mycomicsapp/features/home/presentation/widgets/story_card.dart';
import 'package:flutter/material.dart';

/// A widget that displays a horizontal carousel of ranked stories.
class RankingCarouselSection extends StatelessWidget {
  final List<Story> stories;
  const RankingCarouselSection({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              "Weekly Rankings",
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          CarouselSlider.builder(
            itemCount: stories.length,
            itemBuilder: (context, index, realIndex) {
              final story = stories[index];
              return RankingStoryCard(story: story, rank: index + 1);
            },
            options: CarouselOptions(
              height: 250,
              // Make the central card larger.
              viewportFraction: 0.6,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
            ),
          ),
        ],
      ),
    );
  }
}

