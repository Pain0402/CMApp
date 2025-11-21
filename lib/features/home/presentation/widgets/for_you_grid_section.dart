import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:mycomicsapp/features/home/presentation/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A widget that displays a grid of stories, typically in a "For You" section.
class ForYouGridSection extends StatelessWidget {
  final List<Story> stories;
  //Responsive
  final int crossAxisCount;
  final double childAspectRatio;

  const ForYouGridSection({
    super.key,
    required this.stories,
    required this.crossAxisCount,
    required this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                "For You",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (stories.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false, // Đảm bảo không gây lỗi cuộn khi rỗng
              child: Center(child: Text("No stories found.")),
            )
          else
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Sử dụng giá trị từ HomeScreen
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio:
                    childAspectRatio, // Sử dụng giá trị từ HomeScreen
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                // Giữ nguyên hiệu ứng Animate của bạn
                return StoryCard(story: stories[index])
                    .animate()
                    .fadeIn(delay: (index * 70).ms, duration: 400.ms)
                    .slideY(begin: 0.2);
              }, childCount: stories.length),
            ),

          // Giữ lại khoảng trống dưới cùng
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
