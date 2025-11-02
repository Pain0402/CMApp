import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphism-style bottom navigation bar for the reader screen.
class ReaderBottomBar extends StatelessWidget {
  final VoidCallback onChapterListTap;
  final VoidCallback onCommentTap;
  final VoidCallback onReadingModeTap;
  final IconData readingModeIcon;

  const ReaderBottomBar({
    super.key,
    required this.onChapterListTap,
    required this.onCommentTap,
    required this.onReadingModeTap,
    required this.readingModeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          color: theme.colorScheme.background.withOpacity(0.6),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconButton(
                context,
                icon: Icons.list_alt_rounded,
                label: 'Chapters',
                onPressed: onChapterListTap,
              ),
              _buildIconButton(
                context,
                icon: readingModeIcon,
                label: 'Read Mode',
                onPressed: onReadingModeTap,
              ),
              _buildIconButton(
                context,
                icon: Icons.comment_outlined,
                label: 'Comments',
                onPressed: onCommentTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.onSurface),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
