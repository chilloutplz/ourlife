// ourlife/lib/features/notes/models/note.dart
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime preachedAt;
  final String? pastor;
  final String? biblePassage;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.preachedAt,
    this.pastor,
    this.biblePassage,
  });
}