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

    return MaterialApp.router(
      title: 'ComicsVerse',
      debugShowCheckedModeBanner: false,

      // Configure the light theme.
      theme: AppTheme.lightTheme,
      // Configure the dark theme.
      darkTheme: AppTheme.darkTheme,
      // Automatically select theme based on system settings.
      themeMode: ThemeMode.system,

      // Set the router configuration.
      routerConfig: router,
    );
  }
}
