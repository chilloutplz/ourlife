import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ourlife/features/bible/services/bible_service.dart';
import 'package:ourlife/features/bible/models.dart';

class BibleHomeScreen extends StatefulWidget {
  const BibleHomeScreen({super.key});

  @override
  State<BibleHomeScreen> createState() => _BibleHomeScreenState();
}

class _BibleHomeScreenState extends State<BibleHomeScreen> {
  List<Version> allVersions = [];
  List<Book> allBooks = [];
  List<int> allChapters = [];

  List<String> selectedVersions = [];
  String book = '창';
  int chapter = 1;

  Map<String, List<Verse>> versesByVersion = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersions = prefs.getStringList('selected_versions') ?? ['우리말'];
    final savedBook = prefs.getString('last_book') ?? '창';
    final savedChapter = prefs.getInt('last_chapter') ?? 1;

    final versions = await BibleService.getVersions();
    final books = await BibleService.getBooks(savedVersions.first);
    final chapters = await BibleService.getChapters(savedVersions.first, savedBook);

    setState(() {
      allVersions = versions;
      allBooks = books;
      allChapters = chapters;
      selectedVersions = savedVersions;
      book = savedBook;
      chapter = savedChapter;
    });

    await _loadVerses();
  }

  Future<void> _loadVerses() async {
    setState(() {
      isLoading = true;
      versesByVersion.clear();
    });

    for (var v in selectedVersions) {
      final verses = await BibleService.getVerses(v, book, chapter);
      versesByVersion[v] = verses;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_book', book);
    await prefs.setInt('last_chapter', chapter);

    setState(() {
      isLoading = false;
    });
  }

  void _selectVersions() async {
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final temp = Set<String>.from(selectedVersions);
        return AlertDialog(
          title: const Text('성경 버전 선택'),
          content: SingleChildScrollView(
            child: Column(
              children: allVersions.map((v) {
                final checked = temp.contains(v.name);
                return CheckboxListTile(
                  title: Text(v.name),
                  value: checked,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        temp.add(v.name);
                      } else {
                        temp.remove(v.name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, temp.toList()),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    if (selected != null && selected.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selected_versions', selected);
      final chapters = await BibleService.getChapters(selected.first, book);

      setState(() {
        selectedVersions = selected;
        allChapters = chapters;
      });

      await _loadVerses();
    }
  }

  Widget _buildVerseComparison() {
  final verseCount = versesByVersion.values.isNotEmpty
      ? versesByVersion.values.first.length
      : 0;

  return ListView.builder(
    itemCount: verseCount,
    itemBuilder: (context, index) {
      return Card(
        color: Colors.brown, // 원하는 배경색
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}절',
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              ...selectedVersions.map((v) {
                final verses = versesByVersion[v] ?? [];
                final text = (index < verses.length)
                    ? verses[index].text
                    : '[없음]';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: '$v ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        TextSpan(text: text),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('말씀'),
        actions: [
          IconButton(
            onPressed: _selectVersions,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: book,
                          isExpanded: true,
                          onChanged: (newBook) async {
                            if (newBook == null) return;
                            final chapters =
                                await BibleService.getChapters(selectedVersions.first, newBook);
                            setState(() {
                              book = newBook;
                              chapter = 1;
                              allChapters = chapters;
                            });
                            await _loadVerses();
                          },
                          items: allBooks.map((b) {
                            return DropdownMenuItem<String>(
                              value: b.slug,
                              child: Text(b.name),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: chapter,
                        onChanged: (newChapter) {
                          if (newChapter != null) {
                            setState(() {
                              chapter = newChapter;
                            });
                            _loadVerses();
                          }
                        },
                        items: allChapters.map((c) {
                          return DropdownMenuItem<int>(
                            value: c,
                            child: Text('$c장'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildVerseComparison()),
              ],
            ),
    );
  }
}
