import 'package:cached_network_image/cached_network_image.dart';
import 'package:mycomicsapp/features/home/domain/entities/chapter.dart';
import 'package:mycomicsapp/features/reader/presentation/providers/reader_providers.dart';
import 'package:mycomicsapp/features/reader/presentation/widgets/bottom_sheets/chapter_list_bottom_sheet.dart';
import 'package:mycomicsapp/features/reader/presentation/widgets/bottom_sheets/comments_bottom_sheet.dart';
import 'package:mycomicsapp/features/reader/presentation/widgets/bottom_sheets/reader_settings_bottom_sheet.dart';
import 'package:mycomicsapp/features/reader/presentation/widgets/reader_app_bar.dart';
import 'package:mycomicsapp/features/reader/presentation/widgets/reader_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

enum ReadingMode { vertical, horizontal }

class ReaderScreen extends ConsumerStatefulWidget {
  final String storyId;
  final String storyTitle;
  final Chapter chapter;
  final List<Chapter> allChapters;

  const ReaderScreen({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.chapter,
    required this.allChapters,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _showControls = true;
  ReadingMode _readingMode = ReadingMode.vertical;

  /// Shows a modal bottom sheet with a glassmorphism effect.
  void _showGlassBottomSheet(BuildContext context, {required Widget child}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapterContentAsync = ref.watch(chapterContentProvider(widget.chapter.chapterId));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _showControls
          ? ReaderAppBar(
              storyTitle: widget.storyTitle,
              chapterTitle: 'Chapter ${widget.chapter.chapterNumber}: ${widget.chapter.title}',
              onSettingsTap: () => _showGlassBottomSheet(context, child: const ReaderSettingsBottomSheet()),
            )
          : null,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: chapterContentAsync.when(
          loading: () => _buildLoadingSkeleton(),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${error.toString()}', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
            ),
          ),
          data: (imageUrls) {
            if (imageUrls.isEmpty) {
              return const Center(child: Text('This chapter has no content.', style: TextStyle(color: Colors.white)));
            }
            return _readingMode == ReadingMode.vertical
                ? _buildVerticalReader(imageUrls)
                : _buildHorizontalReader(imageUrls);
          },
        ),
      ),
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _showControls
            ? ReaderBottomBar(
                onChapterListTap: () => _showGlassBottomSheet(
                  context,
                  child: ChapterListBottomSheet(
                    storyId: widget.storyId,
                    storyTitle: widget.storyTitle,
                    allChapters: widget.allChapters,
                    currentChapter: widget.chapter,
                  ),
                ),
                onCommentTap: () => _showGlassBottomSheet(
                  context,
                  child: CommentsBottomSheet(chapterId: widget.chapter.chapterId),
                ),
                onReadingModeTap: () {
                  setState(() {
                    _readingMode = _readingMode == ReadingMode.vertical ? ReadingMode.horizontal : ReadingMode.vertical;
                  });
                },
                readingModeIcon: _readingMode == ReadingMode.vertical ? Icons.swap_horiz_rounded : Icons.swap_vert_rounded,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildVerticalReader(List<String> imageUrls) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: imageUrls.length,
      itemBuilder: (context, index) => _buildChapterImage(imageUrls[index]),
    );
  }

  Widget _buildHorizontalReader(List<String> imageUrls) {
    return PageView.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index) => _buildChapterImage(imageUrls[index]),
    );
  }

  Widget _buildChapterImage(String imageUrl) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.fitWidth,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[900]!,
          highlightColor: Colors.grey[800]!,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.black,
          ),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              SizedBox(height: 8),
              Text('Could not load image', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          3,
          (index) => Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            margin: const EdgeInsets.only(bottom: 8),
          ),
        ),
      ),
    );
  }
}
