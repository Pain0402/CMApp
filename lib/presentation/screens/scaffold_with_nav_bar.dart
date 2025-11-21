import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A scaffold that includes a bottom navigation bar for the main app sections.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true, 
      body: navigationShell,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.7),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0, 
              type: BottomNavigationBarType.fixed,
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard_outlined),
                  activeIcon: Icon(Icons.leaderboard_rounded),
                  label: 'Ranking',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_outlined),
                  activeIcon: Icon(Icons.book_rounded),
                  label: 'Library',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          )
        )
      )
    );
  }
}

