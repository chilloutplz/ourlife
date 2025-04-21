import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/constants.dart';
import 'models.dart';

class BibleService {
  static Future<List<Version>> getVersions() async {
    final res = await http.get(Uri.parse('${ApiConstants.baseUrl}bible/'));
    final list = jsonDecode(res.body) as List;
    return list.map((j) => Version.fromJson(j)).toList();
  }

  static Future<List<Book>> getBooks(String version) async {
    final res = await http.get(Uri.parse('${ApiConstants.baseUrl}bible/$version/'));
    final list = jsonDecode(res.body) as List;
    return list.map((j) => Book.fromJson(j)).toList();
  }

  static Future<List<int>> getChapters(String version, String book) async {
    final res = await http.get(Uri.parse('${ApiConstants.baseUrl}bible/$version/$book/'));
    final list = jsonDecode(res.body) as List;
    return list.map((n) => n as int).toList();
  }

  static Future<List<Verse>> getVerses(String version, String book, int chapter) async {
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}bible/$version/$book/$chapter/'));
    final list = jsonDecode(res.body) as List;
    return list.map((j) => Verse.fromJson(j)).toList();
  }

  static Future<List<Verse>> search(String q) async {
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}bible/search/?q=$q'));
    final list = jsonDecode(res.body) as List;
    return list.map((j) => Verse.fromJson(j)).toList();
  }
}
