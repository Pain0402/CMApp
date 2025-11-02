import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// StateProvider to manage the current brightness value of the slider.
final brightnessProvider = StateProvider.autoDispose<double>((ref) => 0.5);

/// A bottom sheet for displaying reader settings, like screen brightness.
class ReaderSettingsBottomSheet extends ConsumerWidget {
  const ReaderSettingsBottomSheet({super.key});

  /// Asynchronously gets the current system brightness and updates the provider.
  Future<void> _getCurrentBrightness(WidgetRef ref) async {
    try {
      final double brightness = await ScreenBrightness().current;
      ref.read(brightnessProvider.notifier).state = brightness;
    } catch (e) {
      print("Failed to get screen brightness: $e");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a FutureBuilder to fetch the initial brightness only once.
    return FutureBuilder(
      future: _getCurrentBrightness(ref),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final brightnessValue = ref.watch(brightnessProvider);

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: theme.colorScheme.background.withOpacity(0.7),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Display Settings', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.brightness_low_rounded),
                      Expanded(
                        child: Slider(
                          value: brightnessValue,
                          onChanged: (value) {
                            ref.read(brightnessProvider.notifier).state = value;
                            ScreenBrightness().setScreenBrightness(value);
                          },
                        ),
                      ),
                      const Icon(Icons.brightness_high_rounded),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
