import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A scaffold that includes a bottom navigation bar for the main app sections.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        // The type of the bottom navigation bar.
        type: BottomNavigationBarType.fixed,
        // The index of the currently selected navigation bar item.
        currentIndex: navigationShell.currentIndex,
        // Called when one of the items is tapped.
        onTap: (index) {
          navigationShell.goBranch(
            index,
            // Support navigating to the initial location when tapping the item that is
            // already active.
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        // The items to display on the navigation bar.
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
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
    );
  }
}

