// bible_home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ourlife/features/bible/services/bible_service.dart';
import 'package:ourlife/features/bible/models.dart';


// 성경 본문 보기 화면 위젯
class BibleHomeScreen extends StatefulWidget {
  const BibleHomeScreen({super.key});

  @override
  State<BibleHomeScreen> createState() => _BibleHomeScreenState();
}

// BibleHomeScreen의 상태를 관리하는 클래스
class _BibleHomeScreenState extends State<BibleHomeScreen> {
  // 자동 스크롤을 위한 ScrollController
  final ScrollController _scrollController = ScrollController();

  // 성경 버전, 책, 장 리스트, 절 위젯용 키 목록
  List<Version> allVersions = [];
  List<Book> allBooks = [];
  List<int> allChapters = [];
  List<GlobalKey> _verseKeys = [];

  // 선택된 버전 및 현재 선택된 책/장 정보
  List<String> selectedVersions = [];
  String testament = 'OT'; // 구약(OT), 신약(NT)
  String book = '창'; // 책 이름 (slug)
  int chapter = 1; // 장

  // 폰트 크기
  double _fontSize = 16.0;

  // 각 버전별 절 본문 데이터
  Map<String, List<Verse>> versesByVersion = {};

  // 로딩 상태 플래그
  bool isLoading = true;

  // 자동 스크롤을 위한 저장된 절 번호 및 오프셋
  int? _verseToScroll;
  double? _savedScrollOffset;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData().then((_) async {
      final prefs = await SharedPreferences.getInstance();
      _savedScrollOffset = prefs.getDouble('last_scroll_offset');
      _verseToScroll = prefs.getInt('last_verse');
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 스크롤 시 현재 절 위치와 오프셋 저장
  void _onScroll() async {
    if (_scrollController.hasClients) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_scroll_offset', _scrollController.offset);

      final firstVisibleItem = _getFirstVisibleVerse();
      if (firstVisibleItem != null) {
        await prefs.setInt('last_verse', firstVisibleItem + 1);
      }
    }
  }

  // 현재 화면에 보이는 첫 번째 절 인덱스를 계산
  int? _getFirstVisibleVerse() {
    if (!_scrollController.hasClients || _verseKeys.isEmpty) return null;

    final scrollPosition = _scrollController.position;
    final viewportHeight = scrollPosition.viewportDimension;
    final scrollOffset = scrollPosition.pixels + viewportHeight * 0.1;

    for (int i = 0; i < _verseKeys.length; i++) {
      final keyContext = _verseKeys[i].currentContext;
      if (keyContext != null) {
        final box = keyContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        if (position.dy <= scrollOffset) {
          return i;
        }
      }
    }
    return null;
  }

  // 초기 설정값 및 성경 데이터 불러오기
  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersions = prefs.getStringList('selected_versions') ?? ['우리말'];
    final savedTestament = prefs.getString('last_testament_overall');
    final savedBook = prefs.getString('last_book_overall') ?? 
                     prefs.getString('last_book_$testament') ?? '창';
    final savedChapter = prefs.getInt('last_chapter_overall') ?? 
                        prefs.getInt('last_chapter_$testament') ?? 1;

    if (savedTestament != null) {
      testament = savedTestament;
    }

    _fontSize = prefs.getDouble('font_size') ?? 16.0;
    final versions = await BibleService.getVersions();
    final books = await BibleService.getBooks(savedVersions.first);
    final chapters = await BibleService.getChapters(
      savedVersions.first,
      savedBook,
    );

    final initialBook = books.firstWhere(
      (b) => b.slug == savedBook,
      orElse: () => books.first,
    );

    setState(() {
      allVersions = versions;
      allBooks = books;
      allChapters = chapters;
      selectedVersions = savedVersions;
      book = initialBook.slug;
      chapter = savedChapter;
    });

    await _loadVerses();
  }

  // 절 본문을 API로 불러오고 상태를 갱신
  Future<void> _loadVerses() async {
    setState(() {
      isLoading = true;
      versesByVersion.clear();
    });

    for (var v in selectedVersions) {
      final verses = await BibleService.getVerses(v, book, chapter);
      versesByVersion[v] = verses;
    }

    final verseCount = versesByVersion[selectedVersions.first]?.length ?? 0;
    _verseKeys = List.generate(verseCount, (_) => GlobalKey());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_book_$testament', book);
    await prefs.setInt('last_chapter_$testament', chapter);
    await prefs.setString('last_book_overall', book);
    await prefs.setInt('last_chapter_overall', chapter);
    await prefs.setString('last_testament_overall', testament);

    setState(() {
      isLoading = false;
    });

    // 화면 렌더링 후 스크롤 위치 복원
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollPosition();
    });
  }

  // 이전 절 위치나 오프셋으로 스크롤 복원
  void _restoreScrollPosition() {
    if (_verseToScroll != null && _verseToScroll! > 0) {
      final indexToScroll = _verseToScroll! - 1;
      if (indexToScroll < _verseKeys.length) {
        final ctx = _verseKeys[indexToScroll].currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 300),
            alignment: 0.1,
          );
          debugPrint('✅ 성공적으로 $_verseToScroll절로 스크롤');
          return;
        }
      }
    }

    if (_savedScrollOffset != null && _scrollController.hasClients) {
      _scrollController.jumpTo(_savedScrollOffset!);
      debugPrint('⚠️ 절 스크롤 실패, 저장된 오프셋으로 복원: $_savedScrollOffset');
    }
  }

  // 폰트 크기를 저장
  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', _fontSize);
  }

  // 성경 버전 선택 및 순서 조정 다이얼로그
  void _selectVersions() async {
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        List<String> temp = List<String>.from(selectedVersions);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('선택과 순서'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // 드래그로 순서 조정 및 체크박스 선택 UI
                    Expanded(
                      child: ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        itemCount: allVersions.length,
                        onReorder: (oldIndex, newIndex) {
                          if (oldIndex < newIndex) newIndex -= 1;
                          setState(() {
                            final item = allVersions.removeAt(oldIndex);
                            allVersions.insert(newIndex, item);
                            temp = allVersions
                                .where((v) => temp.contains(v.name))
                                .map((v) => v.name)
                                .toList();
                          });
                        },
                        itemBuilder: (context, index) {
                          final v = allVersions[index];
                          final checked = temp.contains(v.name);
                          return ReorderableDragStartListener(
                            key: ValueKey(v.name),
                            index: index,
                            child: ListTile(
                              title: Row(
                                children: [
                                  Checkbox(
                                    value: checked,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          if (!temp.contains(v.name)) {
                                            temp.add(v.name);
                                          }
                                        } else {
                                          temp.remove(v.name);
                                        }
                                      });
                                    },
                                  ),
                                  Text(v.name),
                                ],
                              ),
                              trailing: const Icon(Icons.drag_handle),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 확인 및 취소 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          child: const Text('취소'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, temp),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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

  // 폰트 크기 증가
  void _increaseFontSize() {
    setState(() {
      _fontSize += 2;
    });
    _saveFontSize();
  }

  // 폰트 크기 감소
  void _decreaseFontSize() {
    setState(() {
      _fontSize = (_fontSize - 2).clamp(10.0, 40.0);
    });
    _saveFontSize();
  }

  // 절 단위 비교 뷰 빌더
  Widget _buildVerseComparison() {
    final verseCount = versesByVersion.values.isNotEmpty
        ? versesByVersion.values.first.length
        : 0;

    return ListView.builder(
      controller: _scrollController,
      itemCount: verseCount,
      itemBuilder: (context, index) {
        return Card(
          key: _verseKeys[index],
          color: Colors.brown[900],
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}절',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    color: Colors.white38,
                    fontSize: _fontSize,
                  ),
                ),
                const SizedBox(height: 6),
                ...selectedVersions.map((v) {
                  final verses = versesByVersion[v] ?? [];
                  final text = (index < verses.length) ? verses[index].text : '[없음]';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(
                            text: '$v ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
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

  // 메인 UI 빌드
  @override
  Widget build(BuildContext context) {
    final filteredBooks = allBooks.where((b) => b.testament == testament).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('본문'),
        actions: [
          IconButton(
            onPressed: _decreaseFontSize,
            icon: const Icon(Icons.text_decrease),
          ),
          IconButton(
            onPressed: _increaseFontSize,
            icon: const Icon(Icons.text_increase),
          ),
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
                // 상단 드롭다운 (신약/구약, 책, 장)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: testament,
                        onChanged: (newTestament) async {
                          if (newTestament == null) return;
                          final prefs = await SharedPreferences.getInstance();
                          final savedBook = prefs.getString('last_book_$newTestament') ??
                              allBooks.firstWhere((b) => b.testament == newTestament).slug;
                          final savedChapter = prefs.getInt('last_chapter_$newTestament') ?? 1;

                          final chapters = await BibleService.getChapters(
                            selectedVersions.first,
                            savedBook,
                          );

                          setState(() {
                            testament = newTestament;
                            book = savedBook;
                            chapter = savedChapter;
                            allChapters = chapters;
                          });

                          await _loadVerses();
                        },
                        items: const [
                          DropdownMenuItem(value: 'OT', child: Text('구약')),
                          DropdownMenuItem(value: 'NT', child: Text('신약')),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: book,
                          isExpanded: true,
                          onChanged: (newBook) async {
                            if (newBook == null) return;
                            final chapters = await BibleService.getChapters(
                              selectedVersions.first,
                              newBook,
                            );
                            setState(() {
                              book = newBook;
                              chapter = 1;
                              allChapters = chapters;
                            });
                            await _loadVerses();
                          },
                          items: filteredBooks.map((b) {
                            return DropdownMenuItem<String>(
                              value: b.slug,
                              child: Text(
                                b.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                // 절 비교 리스트
                Expanded(child: _buildVerseComparison()),
              ],
            ),
    );
  }
}
