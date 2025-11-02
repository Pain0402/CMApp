import 'package:mycomicsapp/features/home/presentation/providers/home_providers.dart';
import 'package:mycomicsapp/features/home/presentation/widgets/for_you_grid_section.dart';
import 'package:mycomicsapp/features/home/presentation/widgets/home_sliver_app_bar.dart';
import 'package:mycomicsapp/features/home/presentation/widgets/ranking_carousel_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsyncValue = ref.watch(allStoriesProvider);

    return Scaffold(
      body: storiesAsyncValue.when(
        loading: () => _buildLoadingSkeleton(context),
        error: (error, stackTrace) => Center(
          child: Text('Error loading data: ${error.toString()}'),
        ),
        data: (stories) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(allStoriesProvider.future),
            child: CustomScrollView(
              slivers: [
                const HomeSliverAppBar(),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                RankingCarouselSection(stories: stories.take(5).toList()),
                ForYouGridSection(stories: stories.skip(5).toList()),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a shimmer loading skeleton for the home screen.
  Widget _buildLoadingSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const HomeSliverAppBar(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          // Shimmer for Ranking Carousel
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(height: 28, width: 200, color: Colors.white),
                ),
                Container(
                  height: 250,
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Shimmer for "For You" grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Container(height: 24, width: 150, color: Colors.white),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.6,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

