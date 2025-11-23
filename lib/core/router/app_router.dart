import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mycomicsapp/features/home/domain/entities/story.dart';
import 'package:mycomicsapp/features/home/domain/entities/chapter.dart';
import 'package:mycomicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:mycomicsapp/features/auth/presentation/screens/login_screen.dart';
import 'package:mycomicsapp/features/auth/presentation/screens/signup_screen.dart';
import 'package:mycomicsapp/features/home/presentation/screens/home_screen.dart';
import 'package:mycomicsapp/features/home/presentation/screens/story_details_screen.dart';
import 'package:mycomicsapp/features/library/presentation/screens/library_screen.dart';
import 'package:mycomicsapp/features/profile/presentation/screens/profile_screen.dart';
import 'package:mycomicsapp/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:mycomicsapp/features/reader/presentation/screens/reader_screen.dart';
import 'package:mycomicsapp/features/search/presentation/screens/search_screen.dart';
import 'package:mycomicsapp/presentation/screens/scaffold_with_nav_bar.dart';
import 'package:mycomicsapp/presentation/screens/splash_screen.dart';
import 'package:mycomicsapp/features/home/presentation/screens/ranking_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

CustomTransitionPage buildPageWithSlideTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

CustomTransitionPage buildPageWithFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeIn).animate(animation),
        child: child,
      );
    },
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Standalone screens
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildPageWithFadeTransition(
          context: context, 
          state: state, 
          child: const LoginScreen()
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context: context, 
          state: state, 
          child: const SignUpScreen()
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context: context, 
          state: state, 
          child: const EditProfileScreen()
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          context: context, 
          state: state, 
          child: const SearchScreen()
        ),
      ),

      // Story details and reader screens
      GoRoute(
        path: '/story/:storyId',
        pageBuilder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          final story = state.extra as Story?;
          return buildPageWithSlideTransition(
            context: context,
            state: state,
            child: StoryDetailsScreen(storyId: storyId, story: story),
          );
        },
        routes: [
          GoRoute(
            path: 'chapter/:chapterId',
            pageBuilder: (context, state) {
              final storyId = state.pathParameters['storyId']!;
              final extra = state.extra as Map<String, dynamic>?;

              final storyTitle = extra?['storyTitle'] as String? ?? 'Loading...';
              final chapter = extra?['chapter'] as Chapter?;
              final allChapters = extra?['allChapters'] as List<Chapter>? ?? [];

              if (chapter == null) {
                return buildPageWithSlideTransition(
                  context: context,
                  state: state,
                  child: const Scaffold(
                    body: Center(child: Text("Error: Chapter info not found.")),
                  ),
                );
              }

              return buildPageWithSlideTransition(
                context: context,
                state: state,
                child: ReaderScreen(
                  storyId: storyId,
                  storyTitle: storyTitle,
                  chapter: chapter,
                  allChapters: allChapters,
                ),
              );
            },
          ),
        ],
      ),

      StatefulShellRoute(
        navigatorContainerBuilder: (context, navigationShell, children) {
          return ScaffoldWithNavBar(
            navigationShell: navigationShell,
            children: children,
          );
        },
        builder: (context, state, navigationShell) {
          return navigationShell;
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ranking',
                builder: (context, state) => const RankingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) {
        return null; 
      }

      final isLoggedIn = authState.valueOrNull != null;
      final location = state.uri.toString();
      final isAtSplash = location == '/splash';
      final isAtAuthScreen = location == '/login' || location == '/signup';

      if (isAtSplash) {
        return isLoggedIn ? '/home' : '/login';
      }

      if (isLoggedIn && isAtAuthScreen) {
        return '/home';
      }

      if (!isLoggedIn && !isAtAuthScreen) {
        return '/login';
      }

      return null;
    },
  );
});