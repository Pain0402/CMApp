import 'package:mycomicsapp/features/home/presentation/widgets/story_card.dart';
import 'package:mycomicsapp/features/search/presentation/providers/search_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycomicsapp/features/search/presentation/widgets/filter_bottom_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(searchResultsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // Lắng nghe bộ lọc để kiểm tra xem có đang lọc không
    final currentFilters = ref.watch(filterOptionsProvider);
    final bool hasActiveFilters = currentFilters.genreIds.isNotEmpty;

    final theme = Theme.of(context);

    // LOGIC RESPONSIVE
    final size = MediaQuery.of(context).size;

    // Nếu màn hình rộng > 600px (Tablet/Ngang) -> 4 cột, ngược lại 2 cột
    final int gridColumns = size.width > 600 ? 4 : 2;

    // Màn hình nhỏ: 0.65 (cao hơn để chứa chữ), Màn hình lớn: 0.72 (cân đối hơn)
    final double childAspectRatio = size.width > 600 ? 0.72 : 0.65;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // THANH TÌM KIẾM
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  autofocus: false,
                  textAlignVertical: TextAlignVertical.center,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search for comics...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () =>
                                ref.read(searchQueryProvider.notifier).state =
                                    '',
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (query) {
                    ref.read(searchQueryProvider.notifier).state = query;
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            // NÚT LỌC
            Stack(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    // Nếu đang lọc -> Đổi màu nền thành màu Chính (Primary)
                    // Nếu không -> Giữ màu xám
                    color: hasActiveFilters
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune,
                      // Nếu đang lọc -> Icon màu trắng
                      // Nếu không -> Icon màu chữ thường
                      color: hasActiveFilters
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                    onPressed: () {
                      // Ẩn bàn phím trước khi mở bộ lọc
                      FocusManager.instance.primaryFocus?.unfocus();

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: theme.colorScheme.surface,
                        showDragHandle: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => const FilterBottomSheet(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: searchResults.when(
        data: (stories) {
          if (searchQuery.isEmpty && !hasActiveFilters) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 80,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start searching for your favorite comics.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          if (stories.isEmpty) {
            return const Center(child: Text('No results found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            // Tự động ẩn bàn phím khi cuộn
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumns, //RESPONSIVE
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio, //RESPONSIVE
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              // Animation
              return StoryCard(story: story)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                  .slideY(begin: 0.1, end: 0);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('An error occurred: $error')),
      ),
    );
  }
}
