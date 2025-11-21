import 'package:mycomicsapp/features/home/presentation/providers/home_providers.dart';
import 'package:mycomicsapp/features/home/presentation/widgets/for_you_grid_section.dart';
import 'package:mycomicsapp/features/home/presentation/widgets/home_sliver_app_bar.dart';
import 'package:mycomicsapp/features/home/presentation/widgets/ranking_carousel_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mycomicsapp/core/utils/toast_utils.dart';
import 'package:mycomicsapp/features/auth/presentation/providers/auth_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  void _checkLoginStatus() {
    final justLoggedIn = ref.read(justLoggedInProvider);

    if (justLoggedIn) {
      ToastUtils.showSuccess(context, 'Login successful! Welcome back.');
      ref.read(justLoggedInProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsyncValue = ref.watch(allStoriesProvider);

    // --- LOGIC RESPONSIVE (Đồng bộ với Library) ---
    final size = MediaQuery.of(context).size;

    // Màn hình rộng > 600px (Tablet/Ngang) -> 4 cột, ngược lại 2 cột
    final int gridColumns = size.width > 600 ? 4 : 2;

    // Màn hình nhỏ: 0.62 (cao hơn để chứa chữ), Màn hình lớn: 0.72
    final double cardAspectRatio = size.width > 600 ? 0.72 : 0.62;
    // --------------------------------------------

    return Scaffold(
      body: storiesAsyncValue.when(
        // Truyền tham số vào Skeleton để khớp giao diện
        loading: () =>
            _buildLoadingSkeleton(context, gridColumns, cardAspectRatio),
        error: (error, stackTrace) =>
            Center(child: Text('Error loading data: ${error.toString()}')),
        data: (stories) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(allStoriesProvider.future),
            child: CustomScrollView(
              slivers: [
                const HomeSliverAppBar(),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                RankingCarouselSection(stories: stories.take(5).toList()),

                // Truyền tham số Responsive vào ForYouGridSection
                ForYouGridSection(
                  stories: stories.skip(5).toList(),
                  crossAxisCount: gridColumns,
                  childAspectRatio: cardAspectRatio,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a shimmer loading skeleton for the home screen.
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Dùng biến Responsive
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: childAspectRatio, // Dùng biến Responsive
              ),
              itemCount: 6, // Tăng số lượng dummy item
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
