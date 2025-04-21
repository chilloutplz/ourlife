// lib/services/bible_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class BiblePreferences {
  static const _keyVersion = 'last_version';
  static const _keyBook = 'last_book';
  static const _keyChapter = 'last_chapter';
  static const _keyVerse = 'last_verse';

  /// 마지막 읽은 위치 저장
  static Future<void> saveLastLocation({
    required String version,
    required String book,
    required int chapter,
    required int verse,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVersion, version);
    await prefs.setString(_keyBook, book);
    await prefs.setInt(_keyChapter, chapter);
    await prefs.setInt(_keyVerse, verse);
  }

  /// 마지막 읽은 위치 불러오기
  static Future<Map<String, dynamic>> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'version': prefs.getString(_keyVersion) ?? '개역개정',
      'book': prefs.getString(_keyBook) ?? '창',
      'chapter': prefs.getInt(_keyChapter) ?? 1,
      'verse': prefs.getInt(_keyVerse) ?? 1,
    };
  }

  /// 마지막 위치 초기화 (옵션)
  static Future<void> clearLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyVersion);
    await prefs.remove(_keyBook);
    await prefs.remove(_keyChapter);
    await prefs.remove(_keyVerse);
  }
}
