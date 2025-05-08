// ourlife/lib/features/bible/screens/bible_home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ourlife/features/bible/services/bible_service.dart';
import 'package:ourlife/features/bible/models.dart';
import 'package:ourlife/theme/bootstrap_theme.dart';


// 성경 본문 보기 화면 위젯
class BibleHomeScreen extends StatefulWidget {
  const BibleHomeScreen({super.key});

  @override
  State<BibleHomeScreen> createState() => _BibleHomeScreenState();
}

// BibleHomeScreen의 상태를 관리하는 클래스
class _BibleHomeScreenState extends State<BibleHomeScreen> {
  // 자동 스크롤 위치를 제어하는 데 사용되는 ScrollController
  final ScrollController _scrollController = ScrollController();

  // API로부터 가져온 성경 버전, 책, 장 데이터를 저장하는 리스트
  List<Version> allVersions = [];
  List<Book> allBooks = [];
  List<int> allChapters = [];
  // 각 절의 위치를 추적하기 위한 GlobalKey 리스트
  List<GlobalKey> _verseKeys = [];

  // 사용자가 선택한 성경 버전 리스트
  List<String> selectedVersions = [];
  // 현재 선택된 성경의 구약(OT) 또는 신약(NT) 여부
  String testament = 'OT';
  // 현재 선택된 성경 책의 slug (API 식별자)
  String book = '창';
  // 현재 선택된 성경 장
  int chapter = 1;

  // 현재 폰트 크기
  double _fontSize = 16.0;

  // 각 성경 버전별로 해당 장의 절 본문 데이터를 저장하는 맵
  Map<String, List<Verse>> versesByVersion = {};

  // 데이터 로딩 상태를 나타내는 플래그
  bool isLoading = true;

  // 자동 스크롤을 위해 저장된 특정 절 번호
  int? _verseToScroll;
  // 자동 스크롤을 위해 저장된 스크롤 오프셋
  double? _savedScrollOffset;

  @override
  void initState() {
    super.initState();
    // 스크롤 이벤트 발생 시 _onScroll 함수 호출
    _scrollController.addListener(_onScroll);
    // 초기 데이터 로딩 및 저장된 스크롤 위치/절 정보 복원
    _loadInitialData().then((_) async {
      final prefs = await SharedPreferences.getInstance();
      _savedScrollOffset = prefs.getDouble('last_scroll_offset');
      _verseToScroll = prefs.getInt('last_verse');
    });
  }

  @override
  void dispose() {
    // ScrollController 리스너 제거 및 자원 해제
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 스크롤 이벤트가 발생할 때 현재 스크롤 오프셋과 보이는 첫 번째 절을 저장
  void _onScroll() async {
    if (_scrollController.hasClients) {
      final prefs = await SharedPreferences.getInstance();
      // 현재 스크롤 오프셋 저장
      await prefs.setDouble('last_scroll_offset', _scrollController.offset);

      // 현재 화면에 보이는 첫 번째 절의 인덱스 가져오기
      final firstVisibleItem = _getFirstVisibleVerse();
      if (firstVisibleItem != null) {
        // 보이는 첫 번째 절의 번호 (인덱스 + 1) 저장
        await prefs.setInt('last_verse', firstVisibleItem + 1);
      }
    }
  }

  // 현재 화면의 보이는 영역에서 가장 첫 번째 절의 인덱스를 찾음
  int? _getFirstVisibleVerse() {
    // ScrollController가 활성화되지 않았거나 절 키 리스트가 비어있으면 null 반환
    if (!_scrollController.hasClients || _verseKeys.isEmpty) return null;

    // 현재 스크롤 위치
    final scrollPosition = _scrollController.position;
    // 현재 화면의 보이는 높이
    final viewportHeight = scrollPosition.viewportDimension;
    // 보이는 영역의 시작 위치 (약간 아래에서 시작하도록 조정)
    final scrollOffset = scrollPosition.pixels + viewportHeight * 0.1;

    // 각 절의 GlobalKey를 순회하며 화면 상단에 있는지 확인
    for (int i = 0; i < _verseKeys.length; i++) {
      final keyContext = _verseKeys[i].currentContext;
      if (keyContext != null) {
        // 현재 절의 렌더링 박스 정보 가져오기
        final box = keyContext.findRenderObject() as RenderBox;
        // 현재 절의 화면 좌표로 변환
        final position = box.localToGlobal(Offset.zero);
        // 절의 상단 위치가 현재 스크롤 오프셋보다 작거나 같으면 해당 절이 화면에 보이는 첫 번째 절임
        if (position.dy <= scrollOffset) {
          return i; // 인덱스 반환
        }
      }
    }
    return null; // 보이는 절이 없으면 null 반환
  }

  // 앱 시작 시 또는 필요한 경우 초기 데이터를 로드
  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    // 저장된 선택된 성경 버전 목록을 불러오거나 기본값으로 '우리말' 설정
    final savedVersions = prefs.getStringList('selected_versions') ?? ['우리말'];
    // 저장된 마지막 성경 전체 Testament (구약/신약) 정보 불러오기
    final savedTestament = prefs.getString('last_testament_overall');
    // 저장된 마지막 성경 전체 Book 정보 또는 Testament별 Book 정보 불러오기, 없으면 '창'으로 설정
    final savedBook = prefs.getString('last_book_overall') ??
        prefs.getString('last_book_$testament') ?? '창';
    // 저장된 마지막 성경 전체 Chapter 정보 또는 Testament별 Chapter 정보 불러오기, 없으면 1로 설정
    final savedChapter = prefs.getInt('last_chapter_overall') ??
        prefs.getInt('last_chapter_$testament') ?? 1;

    // 저장된 Testament 정보가 있으면 현재 Testament에 적용
    if (savedTestament != null) {
      testament = savedTestament;
    }

    // 저장된 폰트 크기 불러오거나 기본값 16.0 설정
    _fontSize = prefs.getDouble('font_size') ?? 16.0;
    // 사용 가능한 모든 성경 버전 목록 가져오기
    final versions = await BibleService.getVersions();
    // 첫 번째 선택된 버전에 대한 성경 책 목록 가져오기
    final books = await BibleService.getBooks(savedVersions.first);
    // 첫 번째 선택된 버전과 저장된 책에 대한 장 목록 가져오기
    final chapters = await BibleService.getChapters(
      savedVersions.first,
      savedBook,
    );

    // 불러온 책 목록에서 저장된 책 slug와 일치하는 책을 찾거나, 없으면 첫 번째 책으로 설정
    final initialBook = books.firstWhere(
      (b) => b.slug == savedBook,
      orElse: () => books.first,
    );

    // UI 상태 업데이트
    setState(() {
      allVersions = versions;
      allBooks = books;
      allChapters = chapters;
      selectedVersions = savedVersions;
      book = initialBook.slug;
      chapter = savedChapter;
    });

    // 선택된 버전, 책, 장에 해당하는 성경 절 본문 데이터 로드
    await _loadVerses();
  }

  // 현재 선택된 버전, 책, 장에 대한 성경 절 본문을 API로부터 불러옴
  Future<void> _loadVerses() async {
    // 로딩 상태를 true로 설정하고 기존 절 데이터 초기화
    setState(() {
      isLoading = true;
      versesByVersion.clear();
    });

    // 선택된 각 버전에 대해 성경 절 본문 데이터를 가져옴
    for (var v in selectedVersions) {
      final verses = await BibleService.getVerses(v, book, chapter);
      versesByVersion[v] = verses;
    }

    // 첫 번째 선택된 버전의 절 개수를 기준으로 각 절의 위치를 추적할 GlobalKey 생성
    final verseCount = versesByVersion[selectedVersions.first]?.length ?? 0;
    _verseKeys = List.generate(verseCount, (_) => GlobalKey());

    final prefs = await SharedPreferences.getInstance();
    // 현재 선택된 책과 장 정보를 Testament별, 전체적으로 저장
    await prefs.setString('last_book_$testament', book);
    await prefs.setInt('last_chapter_$testament', chapter);
    await prefs.setString('last_book_overall', book);
    await prefs.setInt('last_chapter_overall', chapter);
    await prefs.setString('last_testament_overall', testament);

    // 로딩 상태를 false로 설정하여 UI 업데이트
    setState(() {
      isLoading = false;
    });

    // 현재 프레임이 렌더링된 후 스크롤 위치를 복원
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollPosition();
    });
  }

  // 이전에 저장된 절 위치나 스크롤 오프셋을 기반으로 스크롤 위치를 복원
  void _restoreScrollPosition() {
    // 특정 절 번호가 저장되어 있고 유효한 범위 내에 있다면 해당 절이 보이도록 스크롤
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

    // 저장된 스크롤 오프셋이 있고 ScrollController가 활성화되어 있다면 해당 오프셋으로 점프
    if (_savedScrollOffset != null && _scrollController.hasClients) {
      _scrollController.jumpTo(_savedScrollOffset!);
      debugPrint('⚠️ 절 스크롤 실패, 저장된 오프셋으로 복원: $_savedScrollOffset');
    }
  }

  // 현재 폰트 크기를 SharedPreferences에 저장
  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', _fontSize);
  }

  // 성경 버전 선택 및 순서 조정을 위한 다이얼로그 표시
  void _selectVersions() async {
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        // 현재 선택된 버전 목록을 임시로 복사하여 다이얼로그 내에서 변경 가능하도록 함
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
                    // ReorderableListView를 사용하여 성경 버전 목록을 표시하고 순서 변경 및 선택 기능 제공
                    Expanded(
                      child: ReorderableListView.builder(
                        // 기본 드래그 핸들 숨김
                        buildDefaultDragHandles: false,
                        itemCount: allVersions.length,
                        // 아이템 순서가 변경될 때 호출되는 콜백
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            // ReorderableListView의 인덱스 조정 로직
                            if (oldIndex < newIndex) newIndex -= 1;
                            // allVersions 리스트에서 아이템을 이동
                            final item = allVersions.removeAt(oldIndex);
                            allVersions.insert(newIndex, item);
                            // 임시 선택 목록(temp)을 현재 allVersions 순서에 맞춰 업데이트
                            temp = allVersions
                                .where((v) => temp.contains(v.name))
                                .map((v) => v.name)
                                .toList();
                          });
                        },
                        // 각 아이템을 빌드하는 함수
                        itemBuilder: (context, index) {
                          final v = allVersions[index];
                          final checked = temp.contains(v.name);
                          // ReorderableDragStartListener로 드래그 시작 감지
                          return ReorderableDragStartListener(
                            key: ValueKey(v.name), // 각 아이템에 고유한 키 제공
                            index: index,
                            child: ListTile(
                              title: Row(
                                children: [
                                  // 성경 버전 선택을 위한 체크박스
                                  Checkbox(
                                    value: checked,
                                    onChanged: (val) {
                                      setState(() {
                                        // 체크되면 temp 리스트에 추가
                                        if (val == true) {
                                          if (!temp.contains(v.name)) {
                                            temp.add(v.name);
                                          }
                                        } else {
                                          // 체크 해제되면 temp 리스트에서 제거
                                          temp.remove(v.name);
                                        }
                                      });
                                    },
                                  ),
                                  Text(v.name), // 성경 버전 이름 표시
                                ],
                              ),
                              trailing: const Icon(Icons.drag_handle), // 드래그 핸들 아이콘
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 다이얼로그 하단의 확인 및 취소 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, null), // 취소 시 null 반환
                          child: const Text('취소'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, temp), // 확인 시 임시 선택 목록 반환
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

    // 다이얼로그에서 선택이 완료되고 null이 아니며 선택된 버전이 하나 이상일 경우
    if (selected != null && selected.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      // 선택된 버전 목록을 SharedPreferences에 저장
      await prefs.setStringList('selected_versions', selected);
      // 첫 번째 선택된 버전에 대한 장 목록을 다시 가져옴 (버전이 변경되었을 수 있으므로)
      final chapters = await BibleService.getChapters(selected.first, book);

      // UI 상태 업데이트
      setState(() {
        selectedVersions = selected;
        allChapters = chapters;
      });

      // 새로운 선택된 버전을 기준으로 성경 절 본문 다시 로드
      await _loadVerses();
    }
  }

  // 폰트 크기를 증가시키는 함수
  void _increaseFontSize() {
    setState(() {
      _fontSize += 2;
    });
    _saveFontSize(); // 변경된 폰트 크기 저장
  }

  // 폰트 크기를 감소시키는 함수 (최소 10.0, 최대 40.0으로 제한)
  void _decreaseFontSize() {
    setState(() {
      _fontSize = (_fontSize - 2).clamp(10.0, 40.0);
    });
    _saveFontSize(); // 변경된 폰트 크기 저장
  }

  // 각 절별로 선택된 모든 버전의 본문을 비교하여 보여주는 위젯 빌더
  Widget _buildVerseComparison() {
    // 현재 로드된 절의 개수 (최소 0)
    final verseCount = versesByVersion.values.isNotEmpty
        ? versesByVersion.values.first.length
        : 0;

    // ListView.builder를 사용하여 절 목록을 표시
    return ListView.builder(
      controller: _scrollController, // 스크롤 제어
      itemCount: verseCount, // 표시할 절의 개수
      itemBuilder: (context, index) {
        // 각 절을 감싸는 Card 위젯
        return Card(
          key: _verseKeys[index], // 각 절의 위치를 추적하기 위한 키
          color: BootstrapColors.secondary, // 카드 배경색
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 카드 외부 여백
          elevation: Theme.of(context).cardTheme.elevation ?? 1, // 그림자 효과
          shape: Theme.of(context).cardTheme.shape, // 카드 모양
          child: Padding(
            padding: const EdgeInsets.all(12), // 카드 내부 여백
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
              children: [
                // 절 번호 표시
                Text(
                  '${index + 1}절',
                  style: TextStyle(
                    // decoration: TextDecoration.underline, // 밑줄
                    fontWeight: FontWeight.bold, // 굵게
                    color: BootstrapColors.light, // 텍스트 색상
                    fontSize: _fontSize, // 현재 폰트 크기 적용
                  ),
                ),
                const SizedBox(height: 6), // 절 번호와 본문 사이 간격
                // 선택된 각 버전에 대한 절 본문 표시
                ...selectedVersions.map((v) {
                  final verses = versesByVersion[v] ?? []; // 해당 버전의 절 리스트 가져오기, 없으면 빈 리스트
                  final text = (index < verses.length) ? verses[index].text : '[없음]'; // 해당 인덱스의 절 본문 가져오기, 없으면 '[없음]' 표시
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4), // 각 버전별 본문 위아래 여백
                    child: RichText( // 여러 스타일을 가진 텍스트 표시
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: _fontSize, // 현재 폰트 크기 적용
                          color: BootstrapColors.light, // 기본 텍스트 색상
                        ),
                        children: [
                          TextSpan(
                            text: '$v ', // 버전 이름 표시
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, // 굵게
                              color: BootstrapColors.teal, // 버전 이름 색상
                            ),
                          ),
                          TextSpan(text: text), // 절 본문 표시
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

  // 메인 UI를 빌드하는 함수
  @override
  Widget build(BuildContext context) {
    // 현재 선택된 구약/신약에 따라 필터링된 책 목록
    final filteredBooks = allBooks.where((b) => b.testament == testament).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('본문'), // 앱바 제목
        actions: [
          // 폰트 크기 감소 버튼
          IconButton(
            onPressed: _decreaseFontSize,
            icon: const Icon(Icons.text_decrease),
          ),
          // 폰트 크기 증가 버튼
          IconButton(
            onPressed: _increaseFontSize,
            icon: const Icon(Icons.text_increase),
          ),
          // 성경 버전 선택 및 순서 설정 버튼
          IconButton(
            onPressed: _selectVersions,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      // 로딩 중이면 CircularProgressIndicator 표시, 아니면 실제 내용 표시
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 구약/신약 선택, 책 선택, 장 선택 드롭다운 메뉴
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // 구약/신약 선택 드롭다운
                      DropdownButton<String>(
                        value: testament, // 현재 선택된 구약/신약 값
                        onChanged: (newTestament) async {
                          if (newTestament == null) return;
                          final prefs = await SharedPreferences.getInstance();
                          // 선택된 새 Testament에 해당하는 마지막으로 읽었던 책을 불러오거나 첫 번째 책으로 설정
                          final savedBook = prefs.getString('last_book_$newTestament') ??
                              allBooks.firstWhere((b) => b.testament == newTestament).slug;
                          // 선택된 새 Testament에 해당하는 마지막으로 읽었던 장을 불러오거나 1로 설정
                          final savedChapter = prefs.getInt('last_chapter_$newTestament') ?? 1;

                          // 새 책에 대한 장 목록 가져오기
                          final chapters = await BibleService.getChapters(
                            selectedVersions.first,
                            savedBook,
                          );

                          // UI 상태 업데이트
                          setState(() {
                            testament = newTestament;
                            book = savedBook;
                            chapter = savedChapter;
                            allChapters = chapters;
                          });

                          // 새 Testament, 책, 장에 해당하는 성경 절 본문 로드
                          await _loadVerses();
                        },
                        items: const [
                          DropdownMenuItem(value: 'OT', child: Text('구약')),
                          DropdownMenuItem(value: 'NT', child: Text('신약')),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // 책 선택 드롭다운
                      Expanded(
                        child: DropdownButton<String>(
                          value: book, // 현재 선택된 책 slug
                          isExpanded: true, // 공간에 맞춰 확장
                          onChanged: (newBook) async {
                            if (newBook == null) return;
                            // 새 책에 대한 장 목록 가져오기
                            final chapters = await BibleService.getChapters(
                              selectedVersions.first,
                              newBook,
                            );
                            // UI 상태 업데이트
                            setState(() {
                              book = newBook;
                              chapter = 1; // 책이 바뀌면 장을 1로 초기화
                              allChapters = chapters;
                            });
                            // 새 책에 해당하는 성경 절 본문 로드
                            await _loadVerses();
                          },
                          items: filteredBooks.map((b) {
                            return DropdownMenuItem<String>(
                              value: b.slug, // 드롭다운 아이템 값으로 책 slug 사용
                              child: Text(
                                b.name, // 드롭다운 아이템에 책 이름 표시
                                overflow: TextOverflow.ellipsis, // 텍스트가 길면 말줄임표 표시
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 장 선택 드롭다운
                      DropdownButton<int>(
                        value: chapter, // 현재 선택된 장
                        onChanged: (newChapter) {
                          if (newChapter != null) {
                            // UI 상태 업데이트
                            setState(() {
                              chapter = newChapter;
                            });
                            // 새 장에 해당하는 성경 절 본문 로드
                            _loadVerses();
                          }
                        },
                        items: allChapters.map((c) {
                          return DropdownMenuItem<int>(
                            value: c, // 드롭다운 아이템 값으로 장 번호 사용
                            child: Text('$c장'), // 드롭다운 아이템에 장 번호 표시
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                // 성경 절 비교 리스트 표시
                Expanded(child: _buildVerseComparison()),
              ],
            ),
    );
  }
}

