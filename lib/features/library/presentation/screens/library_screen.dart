import 'package:mycomicsapp/features/home/presentation/widgets/story_card.dart';
import 'package:mycomicsapp/features/library/presentation/providers/library_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookmarkedStoriesAsync = ref.watch(bookmarkedStoriesProvider);

    // --- LOGIC RESPONSIVE ---
    final size = MediaQuery.of(context).size;

    // Nếu màn hình rộng > 600px (Tablet/Ngang) -> 4 cột, ngược lại 2 cột
    final int gridColumns = size.width > 600 ? 4 : 2;

    // Điều chỉnh tỉ lệ thẻ (Width / Height)
    // Màn hình nhỏ: Cần thẻ cao hơn để chứa chữ -> 0.62
    // Màn hình lớn: Thẻ có thể rộng hơn -> 0.72
    final double cardAspectRatio = size.width > 600 ? 0.72 : 0.62;
    // ------------------------

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Library',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: bookmarkedStoriesAsync.when(
        // Truyền tham số layout vào Skeleton để khớp với giao diện thật
        loading: () =>
            _buildLoadingSkeleton(context, gridColumns, cardAspectRatio),
        error: (error, stackTrace) =>
            Center(child: Text('Error loading library: ${error.toString()}')),
        data: (stories) {
          if (stories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_remove_outlined,
                    size: 80,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your library is empty',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your favorite stories here!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(bookmarkedStoriesProvider.future),
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridColumns, // Sử dụng biến Responsive
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: cardAspectRatio, // Sử dụng biến Responsive
              ),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return StoryCard(story: story);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton(
    BuildContext context,
    int crossAxisCount,
    double childAspectRatio,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // Đồng bộ số cột với giao diện chính
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio:
              childAspectRatio, // Đồng bộ tỉ lệ với giao diện chính
        ),
        itemCount: 12, // Tăng số lượng item giả lập lên một chút cho đẹp
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              12,
            ), // Bo góc giống StoryCard (thường là 12 hoặc 8)
          ),
        ),
      ),
    );
  }
}
