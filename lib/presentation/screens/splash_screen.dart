import 'package:flutter/material.dart';

/// A simple screen that displays a loading indicator.
/// Shown while the app determines the user's authentication state on startup.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
