import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    required this.children, 
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children; 

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBody: true,
      
      body: AnimatedBranchContainer(
        currentIndex: navigationShell.currentIndex,
        children: children,
      ),
      
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                backgroundColor: Colors.transparent,
                indicatorColor: theme.colorScheme.primary.withOpacity(0.2),
                elevation: 0,
              ),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _goBranch,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: theme.colorScheme.primary.withOpacity(0.25),
                height: 70, 
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: 'Ranking',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.local_library_outlined),
                    selectedIcon: Icon(Icons.local_library),
                    label: 'Library',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget hỗ trợ Animation chuyển đổi giữa các tab (Giữ nguyên)
class AnimatedBranchContainer extends StatelessWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return IgnorePointer(
          ignoring: index != currentIndex,
          child: AnimatedOpacity(
            opacity: index == currentIndex ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: TickerMode(
              enabled: index == currentIndex,
              child: child,
            ),
          ),
        );
      }).toList(),
    );
  }
}