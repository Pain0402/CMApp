class Chapter {
  final String chapterId;
  final String storyId;
  final int chapterNumber;
  final String title;
  final bool isVip;
  final DateTime releaseDate;

  Chapter({
    required this.chapterId,
    required this.storyId,
    required this.chapterNumber,
    required this.title,
    required this.isVip,
    required this.releaseDate,
  });

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      chapterId: map['chapter_id'] ?? '',
      storyId: map['story_id'] ?? '',
      chapterNumber: map['chapter_number'] as int? ?? 0,
      title: map['title'] ?? 'No Title',
      isVip: map['is_vip'] ?? false,
      releaseDate: map['release_date'] != null ? DateTime.parse(map['release_date']) : DateTime.now(),
    );
  }
}
