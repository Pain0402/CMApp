import 'package:mycomicsapp/features/auth/domain/entities/profile.dart';
import 'package:mycomicsapp/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';
import 'dart:async'; 
import 'package:mycomicsapp/core/services/notification_service.dart';

class HomeSliverAppBar extends ConsumerWidget {
  const HomeSliverAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    return SliverAppBar(
      pinned: true,
      expandedHeight: 120.0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 200, 
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32, 
              width: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            
            Text(
              'MyComicsApp',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface, 
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      
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
              titlePadding: EdgeInsets.zero, 
              title: null, 
              background: _buildExpandedBackground(context, userProfileAsync),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            // Gọi hàm hiển thị thông báo
            await NotificationService().showNotification(
              id: 1,
              title: 'New Chapter Available! 📖',
              body: 'One Piece Chapter 1100 has just been released. Read now!',
            );
          },
          icon: const Badge(
            label: Text('1'), 
            child: Icon(Icons.notifications_outlined, size: 24)
          ),
          tooltip: 'Test Notification',
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
    const String welcomeText = "ようこそ、マンガアプリへ！";
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
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
                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TypewriterText(
                        text: welcomeText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w900,
                        ),
                        typingDuration: const Duration(milliseconds: 2000), // Thời gian gõ
                        pauseDuration: const Duration(seconds: 3), // Thời gian nghỉ trước khi lặp lại
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

/// Widget riêng để xử lý hiệu ứng gõ chữ lặp lại
class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration typingDuration;
  final Duration pauseDuration;

  const _TypewriterText({
    required this.text,
    this.style,
    this.typingDuration = const Duration(milliseconds: 2000),
    this.pauseDuration = const Duration(seconds: 3),
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _typingAnimation;
  Timer? _pauseTimer;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: widget.typingDuration,
    );

    _typingAnimation = IntTween(begin: 0, end: widget.text.length).animate(_controller);

    _startAnimationLoop();
  }

  void _startAnimationLoop() {
    // 1. Bắt đầu hiệu ứng gõ chữ
    _controller.forward().then((_) {
      // 2. Sau khi gõ xong, đợi một khoảng thời gian (pauseDuration)
      _pauseTimer = Timer(widget.pauseDuration, () {
        if (mounted) {
          // 3. Reset về 0 (xóa chữ) ngay lập tức 
          _controller.value = 0; 
          // 4. Lặp lại
          _startAnimationLoop();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pauseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        String textToShow = widget.text.substring(0, _typingAnimation.value);
        return Text(
          textToShow,
          style: widget.style,
        );
      },
    );
  }
}
