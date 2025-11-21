import 'package:mycomicsapp/features/auth/domain/entities/profile.dart';
import 'package:mycomicsapp/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';

class HomeSliverAppBar extends ConsumerWidget {
  const HomeSliverAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    return SliverAppBar(
      pinned: true,
      expandedHeight: 180.0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: theme.scaffoldBackgroundColor.withOpacity(0),
            child: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'ComicsVerse',
                style: theme.textTheme.headlineSmall?.copyWith(
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: _buildExpandedBackground(context, userProfileAsync),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Badge(child: Icon(Icons.notifications_outlined, size: 24)),
        ),
        IconButton(
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.search_rounded),
          iconSize: 26,
        ),
        const SizedBox(width: 1),
      ],
    );
  }

  Widget _buildExpandedBackground(
    BuildContext context,
    AsyncValue<Profile?> userProfileAsync,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 70),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userProfileAsync.when(
            data: (profile) => Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: profile?.avatarUrl != null
                        ? NetworkImage(profile!.avatarUrl!)
                        : null,
                    child: profile?.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 24,
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Welcome to My ComicsApp,",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        profile?.displayName ?? 'Guest',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            loading: () => Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.withOpacity(0.3),
                  highlightColor: Colors.grey.withOpacity(0.1),
                  child: const CircleAvatar(radius: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.withOpacity(0.3),
                    highlightColor: Colors.grey.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 16, width: 100, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 24, width: 180, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            error: (e, s) => Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.errorContainer,
                  child: Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Hi,",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'ComicsVerse',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
