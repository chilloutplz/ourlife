import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    // 데이터베이스 파일 경로 출력
    // debugPrint('Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    debugPrint('Creating database...');
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        preachedAt TEXT NOT NULL,
        pastor TEXT,
        biblePassage TEXT
      )
    ''');
    debugPrint('Database created successfully');
  }

  DateTime _parseDate(String dateStr) {
    try {
      debugPrint('Parsing date: $dateStr');
      if (dateStr.isEmpty) {
        debugPrint('Empty date string, returning current time');
        return DateTime.now();
      }
      
      // ISO 8601 형식이 아닌 경우를 처리
      if (!dateStr.contains('T')) {
        // YYYY-MM-DD 형식으로 변환
        final parts = dateStr.split(' ');
        if (parts.isNotEmpty) {
          final datePart = parts[0];
          if (datePart.contains('-')) {
            return DateTime.parse(datePart);
          }
        }
        debugPrint('Invalid date format: $dateStr, returning current time');
        return DateTime.now();
      }
      
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('Error parsing date: $dateStr, error: $e');
      return DateTime.now();
    }
  }

  Future<String> insertNote(Note note) async {
    final db = await instance.database;
    // debugPrint('Inserting note:');
    // debugPrint('ID: ${note.id}');
    // debugPrint('Title: ${note.title}');
    // debugPrint('Content: ${note.content}');
    // debugPrint('CreatedAt: ${note.createdAt}');
    // debugPrint('PreachedAt: ${note.preachedAt}');
    // debugPrint('Pastor: ${note.pastor}');
    // debugPrint('BiblePassage: ${note.biblePassage}');

    await db.insert(
      'notes',
      {
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'createdAt': note.createdAt.toIso8601String(),
        'preachedAt': note.preachedAt.toIso8601String(),
        'pastor': note.pastor,
        'biblePassage': note.biblePassage,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return note.id;
  }

  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'preachedAt DESC');
    // debugPrint('Retrieved ${maps.length} notes from database');
    
    return List.generate(maps.length, (i) {
      final map = maps[i];
      // debugPrint('Note $i:');
      // debugPrint('ID: ${map['id']}');
      // debugPrint('Title: ${map['title']}');
      // debugPrint('Content: ${map['content']}');
      // debugPrint('CreatedAt: ${map['createdAt']}');
      // debugPrint('PreachedAt: ${map['preachedAt']}');
      // debugPrint('Pastor: ${map['pastor']}');
      // debugPrint('BiblePassage: ${map['biblePassage']}');
      
      String? createdAt = map['createdAt'] as String?;
      String? preachedAt = map['preachedAt'] as String?;
      
      return Note(
        id: map['id'] as String,
        title: map['title'] as String,
        content: map['content'] as String,
        createdAt: createdAt != null ? _parseDate(createdAt) : DateTime.now(),
        preachedAt: preachedAt != null ? _parseDate(preachedAt) : DateTime.now(),
        pastor: map['pastor'] as String?,
        biblePassage: map['biblePassage'] as String?,
      );
    });
  }

  Future<Note?> getNote(String id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return Note(
      id: maps[0]['id'],
      title: maps[0]['title'],
      content: maps[0]['content'],
      createdAt: _parseDate(maps[0]['createdAt']),
      preachedAt: _parseDate(maps[0]['preachedAt']),
      pastor: maps[0]['pastor'],
      biblePassage: maps[0]['biblePassage'],
    );
  }

  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      {
        'title': note.title,
        'content': note.content,
        'preachedAt': note.preachedAt.toIso8601String(),
        'pastor': note.pastor,
        'biblePassage': note.biblePassage,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(String id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 