import 'package:mycomicsapp/features/auth/domain/entities/profile.dart';
import 'package:mycomicsapp/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class HomeSliverAppBar extends ConsumerWidget { 
  const HomeSliverAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    final theme = Theme.of(context);
    // final userProfileAsync = ref.watch(userProfileProvider);

    return SliverAppBar(
      pinned: true,
      expandedHeight: 180.0,
      backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text('Explore', style: theme.textTheme.headlineMedium),
        // background: _buildExpandedBackground(context, userProfileAsync),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.search_rounded),
          iconSize: 28,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildExpandedBackground(
    BuildContext context,
    AsyncValue<Profile?> userProfileAsync,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 56),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: userProfileAsync.when(
          data: (profile) => [
            Text(
              "Good Morning,",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              profile?.displayName ?? 'Guest',
              style: theme.textTheme.headlineLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          loading: () => [
            Shimmer.fromColors(
              baseColor: Colors.grey.withOpacity(0.3),
              highlightColor: Colors.grey.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 120, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 30, width: 200, color: Colors.white),
                ],
              ),
            ),
          ],
          error: (e, s) => [
            Text(
              "HI,",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'ComicsVerse',
              style: theme.textTheme.headlineLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}