class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime preachedAt;
  final String pastor; // 추가
  final String? biblePassage; // 추가

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.preachedAt,
    required this.pastor,
    this.biblePassage,
  });
}