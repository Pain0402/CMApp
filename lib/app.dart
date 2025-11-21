import 'package:mycomicsapp/core/config/theme/app_theme.dart';
import 'package:mycomicsapp/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the GoRouter provider to integrate it with MaterialApp.
    final router = ref.watch(goRouterProvider);

    

    final themeMode = ref.watch(themeModeProvider);


    return Container(
  
      child: MaterialApp.router(
        title: 'ComicsVerse',
        debugShowCheckedModeBanner: false,

        // Configure the light theme.
        theme: AppTheme.lightTheme,
        // Configure the dark theme.
        darkTheme: AppTheme.darkTheme,
        // Automatically select theme based on system settings.
        themeMode: themeMode,

        // Set the router configuration.
        routerConfig: router,
        builder: (context, child) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          
          return Container(
            decoration: BoxDecoration(
              gradient: isDarkMode 
                  ? AppTheme.darkLinearGradient 
                  : AppTheme.lightLinearGradient,
            ),
            child: child, 
          );
        },
      ),
    );
  }
}