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

    // LOGIC RESPONSIVE
    final size = MediaQuery.of(context).size;

    // Điều chỉnh tỷ lệ hiển thị (viewportFraction) dựa trên chiều rộng màn hình.
    // Màn hình nhỏ (< 600): 0.6 (60% màn hình) -> Thẻ to, rõ trên điện thoại.
    // Màn hình lớn (>= 600): 0.30 (30% màn hình) -> Thẻ nhỏ lại, vừa mắt, không bị vỡ ảnh.
    final double viewportFraction = size.width > 600 ? 0.30 : 0.6;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              "Weekly Rankings",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CarouselSlider.builder(
            itemCount: stories.length,
            itemBuilder: (context, index, realIndex) {
              final story = stories[index];
              // Đảm bảo RankingStoryCard được import đúng
              return RankingStoryCard(story: story, rank: index + 1);
            },
            options: CarouselOptions(
              height: 300,
              // Sử dụng biến Responsive đã tính
              viewportFraction: viewportFraction,
              enlargeCenterPage: true,
              // Giảm độ phóng to ở màn hình lớn để chuyển động mượt hơn
              enlargeFactor: size.width > 600 ? 0.2 : 0.3,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
            ),
          ),
        ],
      ),
    );
  }
}
