// ourlife/lib/features/notes/screens/note_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../../bible/services/bible_service.dart';
import '../../bible/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _pastorController;
  late final TextEditingController _passageController;
  late final FocusNode _pastorFocusNode;
  late final FocusNode _titleFocusNode;
  DateTime _selectedDate = DateTime.now();
  bool _isSidePanelVisible = false;
  List<RichText> _selectedPassageText = [];
  Map<String, List<Verse>> versesByVersion = {};

  final List<Passage> _passages = [];

  // 저장 버튼 활성화 여부를 관리하는 변수
  bool _isSaveButtonActive = false;

  final String _selectedTestament = 'OT';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _pastorController = TextEditingController(text: widget.note?.pastor ?? '');
    _passageController = TextEditingController();
    _pastorFocusNode = FocusNode();
    _titleFocusNode = FocusNode();

    // 화면이 빌드된 후 설교자 입력 필드에 포커스를 줍니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pastorFocusNode.requestFocus();
    });

    // 기존 노트의 본문 정보가 있다면 파싱하여 _passages 리스트에 추가합니다.
    if (widget.note?.biblePassage != null) {
      final passages = widget.note!.biblePassage!
          .split(';') // 세미콜론으로 구분된 각 구절을 분리합니다.
          .map((s) => s.trim()) // 각 구절의 앞뒤 공백을 제거합니다.
          .where((s) => s.isNotEmpty) // 빈 문자열은 제외합니다.
          .map(Passage.fromString); // 문자열 형태의 구절을 Passage 객체로 변환합니다.
      _passages.addAll(passages);
    }

    // 텍스트 필드의 변경을 감지하여 저장 버튼 활성화 상태를 업데이트합니다.
    _contentController.addListener(_updateSaveButtonState);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _pastorController.dispose();
    _passageController.dispose();
    _pastorFocusNode.dispose();
    _titleFocusNode.dispose();
    // 텍스트 컨트롤러 리스너를 제거하여 메모리 누수를 방지합니다.
    _contentController.removeListener(_updateSaveButtonState);
    super.dispose();
  }

  // 설교일자를 선택하는 함수
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko'),
    );
    // 날짜가 선택되면 상태를 업데이트하고 저장 버튼 상태를 업데이트합니다.
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _updateSaveButtonState();
    }
  }

  // 선택된 날짜를 지정된 형식으로 변환하는 함수
  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일', 'ko').format(date);
  }

  // 성경 본문 추가 모달을 여는 함수
  void _openBiblePassageModal() {
    showDialog(
      context: context,
      builder: (dialogContext) => BiblePassageSelector(
        initialTestament: _selectedTestament,
        onPassageSelected: (passage) async {
          setState(() {
            _passages.add(passage);
          });

          Navigator.pop(dialogContext);

          // 선택된 구절의 본문을 가져옵니다
          try {
            final prefs = await SharedPreferences.getInstance();
            final selectedVersions = prefs.getStringList('selected_versions') ?? ['우리말'];
            
            // 각 버전별로 본문 가져오기
            versesByVersion.clear();
            for (var version in selectedVersions) {
              final verses = await BibleService.getVerses(version, passage.book, passage.startChap);
              versesByVersion[version] = verses;
            }

            if (!mounted) return;

            // 첫 번째 버전의 절 범위 찾기
            final firstVersion = selectedVersions.first;
            final verses = versesByVersion[firstVersion] ?? [];
            final startIndex = verses.indexWhere((v) => v.number == passage.startVer);
            final endIndex = verses.indexWhere((v) => v.number == passage.endVer);

            if (startIndex != -1 && endIndex != -1) {
              // 책 이름 가져오기 (첫 번째 버전 기준)
              final books = await BibleService.getBooks(firstVersion);
              final bookName = books.firstWhere((book) => book.slug == passage.book).name;
              
              // 책과 장을 제목으로 표시
              final titleText = RichText(
                text: TextSpan(
                  text: '$bookName ${passage.startChap}장',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );

              // 각 절마다 모든 버전의 본문을 교대로 표시
              final versesText = <RichText>[];
              for (var i = startIndex; i <= endIndex; i++) {
                final verseNumber = verses[i].number;
                var isFirstVersion = true;
                
                // 각 버전의 해당 절 본문 표시
                for (var version in selectedVersions) {
                  final versionVerses = versesByVersion[version] ?? [];
                  if (versionVerses.isNotEmpty) {
                    final verse = versionVerses[i];
                    versesText.add(RichText(
                      text: TextSpan(
                        children: [
                          if (isFirstVersion) TextSpan(
                            text: '$verseNumber ',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '[$version] ',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          TextSpan(
                            text: verse.text,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ));
                    isFirstVersion = false;
                  }
                }
              }

              setState(() {
                if (_selectedPassageText.isEmpty) {
                  _selectedPassageText = [titleText, ...versesText];
                } else {
                  _selectedPassageText = [..._selectedPassageText, titleText, ...versesText];
                }
                _isSidePanelVisible = true;
              });

              // 1초 후에 사이드 패널 닫기
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    _isSidePanelVisible = false;
                  });
                }
              });
            }
          } catch (e) {
            debugPrint('Error loading passage: $e');
          }

          if (mounted) {
            _titleFocusNode.requestFocus();
          }
        },
      ),
    );
  }

  // 노트를 저장하고 이전 화면으로 돌아가는 함수
  void _saveNote() {
    Navigator.pop(
      context,
      Note(
        id: widget.note?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        content: _contentController.text,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        preachedAt: _selectedDate,
        pastor: _pastorController.text,
        biblePassage: _passages.map((p) => p.displayText).join('; '),
      ),
    );
  }

  // 저장 버튼의 활성화 상태를 업데이트하는 함수
  void _updateSaveButtonState() {
    setState(() {
      _isSaveButtonActive = _passageController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.note != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? '노트 수정' : '노트 작성')),
      body: GestureDetector(
        onTap: () {
          if (_isSidePanelVisible) {
            setState(() {
              _isSidePanelVisible = false;
            });
          }
        },
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionLabel('설교일자'),
                                GestureDetector(
                                  onTap: _pickDate,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                    child: Text(
                                      _formatDate(_selectedDate),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildSectionLabel('설교자'),
                                TextField(
                                  controller: _pastorController,
                                  focusNode: _pastorFocusNode,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                  ),
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          '본문',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: _openBiblePassageModal,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ..._passages.map(
                                  (p) => ListTile(
                                    title: Text(p.displayText),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        final selectedVersions = prefs.getStringList('selected_versions') ?? ['우리말'];
                                        
                                        setState(() {
                                          // 해당 구절의 인덱스 찾기
                                          final index = _passages.indexOf(p);
                                          
                                          // 사이드 패널에서 해당 구절의 내용 제거
                                          if (index >= 0) {
                                            // 이전 구절들의 총 길이 계산
                                            int startIndex = 0;
                                            for (int i = 0; i < index; i++) {
                                              final prevPassage = _passages[i];
                                              // 제목(1개) + (절 개수 * 버전 개수)
                                              startIndex += 1 + ((prevPassage.endVer - prevPassage.startVer + 1) * selectedVersions.length).toInt();
                                            }
                                            
                                            // 현재 구절의 길이 계산 (제목 + (절 개수 * 버전 개수))
                                            final currentLength = 1 + ((p.endVer - p.startVer + 1) * selectedVersions.length).toInt();
                                            
                                            // 범위가 유효한지 확인하고 제거
                                            if (startIndex < _selectedPassageText.length) {
                                              final endIndex = startIndex + currentLength;
                                              _selectedPassageText.removeRange(
                                                startIndex,
                                                endIndex > _selectedPassageText.length ? _selectedPassageText.length : endIndex
                                              );
                                            }
                                          }
                                          
                                          _passages.remove(p);
                                          _isSidePanelVisible = true;
                                        });

                                        // 1초 후에 사이드 패널 닫기
                                        Future.delayed(const Duration(seconds: 1), () {
                                          if (mounted) {
                                            setState(() {
                                              _isSidePanelVisible = false;
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextField(
                                  controller: _titleController,
                                  focusNode: _titleFocusNode,
                                  decoration: const InputDecoration(
                                    hintText: '제목',
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _passageController,
                                  decoration: const InputDecoration(
                                    hintText: '노트를 시작하세요',
                                    border: InputBorder.none,
                                  ),
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                  onChanged: (value) => _updateSaveButtonState(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 36,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: _isSaveButtonActive ? _saveNote : null,
                            child: const Text('저장', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 200,
              child: Container(
                width: 24,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(-2, 0),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                    onTap: () {
                      setState(() {
                        _isSidePanelVisible = !_isSidePanelVisible;
                      });
                    },
                    child: Center(
                      child: Icon(
                        _isSidePanelVisible ? Icons.chevron_right : Icons.chevron_left,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: _isSidePanelVisible ? 0 : -300,
              top: 0,
              bottom: 0,
              width: 300,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey[800]!,
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(-2, 0),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {}, // 패널 내부 클릭은 무시
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[800]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '본문 내용',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _isSidePanelVisible = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _selectedPassageText.map((text) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: text,
                            )).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 제목 위젯을 생성하는 함수
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: Colors.white),
    );
  }
}

class BiblePassageSelector extends StatefulWidget {
  final String initialTestament;
  final Function(Passage) onPassageSelected;

  const BiblePassageSelector({
    super.key,
    required this.initialTestament,
    required this.onPassageSelected,
  });

  @override
  State<BiblePassageSelector> createState() => _BiblePassageSelectorState();
}

class _BiblePassageSelectorState extends State<BiblePassageSelector> {
  String _selectedTestament = 'OT';
  String _selectedBook = '';
  int _selectedChapter = 1;
  int _selectedEndChapter = 1;
  int _selectedVerse = 1;
  int _selectedEndVerse = 1;
  List<Book> _books = [];
  List<int> _chapters = [];
  List<int> _verses = [];
  bool _isLoadingBooks = false;
  bool _isLoadingChapters = false;
  bool _isLoadingVerses = false;

  @override
  void initState() {
    super.initState();
    _selectedTestament = widget.initialTestament;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingBooks = true;
    });

    final books = await BibleService.getBooks('우리말');
    if (!mounted) return;

    final filteredBooks = books.where((book) {
      if (_selectedTestament == 'OT') {
        return book.testament == 'OT';
      } else {
        return book.testament == 'NT';
      }
    }).toList();

    setState(() {
      _books = filteredBooks;
      if (filteredBooks.isNotEmpty) {
        _selectedBook = filteredBooks.first.slug;
        _isLoadingChapters = true;
      }
      _isLoadingBooks = false;
    });

    if (_selectedBook.isNotEmpty) {
      await _loadChapters();
    }
  }

  Future<void> _loadChapters() async {
    final chapters = await BibleService.getChapters('우리말', _selectedBook);
    if (!mounted) return;

    setState(() {
      _chapters = chapters;
      if (chapters.isNotEmpty) {
        _selectedChapter = chapters.first;
        _selectedEndChapter = chapters.first;
        _isLoadingVerses = true;
      }
      _isLoadingChapters = false;
    });

    if (_selectedChapter > 0) {
      await _loadVerses();
    }
  }

  Future<void> _loadVerses() async {
    final verses = await BibleService.getVerses('우리말', _selectedBook, _selectedChapter);
    if (!mounted) return;

    setState(() {
      _verses = verses.map((v) => v.number).toList();
      if (_verses.isNotEmpty) {
        _selectedVerse = _verses.first;
        _selectedEndVerse = _verses.first;
      }
      _isLoadingVerses = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('본문 선택'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedTestament,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'OT', child: Text('구약')),
                    DropdownMenuItem(value: 'NT', child: Text('신약')),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        _selectedTestament = value;
                        _selectedBook = '';
                        _selectedChapter = 1;
                        _selectedVerse = 1;
                        _selectedEndChapter = 1;
                        _selectedEndVerse = 1;
                        _isLoadingBooks = true;
                        _chapters = [];
                        _verses = [];
                      });
                      
                      final books = await BibleService.getBooks('우리말');
                      if (!mounted) return;
                      
                      final filteredBooks = books.where((book) {
                        if (value == 'OT') {
                          return book.testament == 'OT';
                        } else {
                          return book.testament == 'NT';
                        }
                      }).toList();
                      
                      setState(() {
                        _books = filteredBooks;
                        if (filteredBooks.isNotEmpty) {
                          _selectedBook = filteredBooks.first.slug;
                          _isLoadingChapters = true;
                        }
                        _isLoadingBooks = false;
                      });
                      
                      if (_selectedBook.isNotEmpty) {
                        await _loadChapters();
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _isLoadingBooks
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButton<String>(
                      value: _selectedBook,
                      isExpanded: true,
                      items: _books.map((book) => 
                        DropdownMenuItem(
                          value: book.slug,
                          child: Text(
                            book.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ).toList(),
                      onChanged: _selectedBook.isEmpty ? null : (value) async {
                        if (value != null) {
                          setState(() {
                            _selectedBook = value;
                            _selectedChapter = 1;
                            _selectedVerse = 1;
                            _selectedEndChapter = 1;
                            _selectedEndVerse = 1;
                            _isLoadingChapters = true;
                            _chapters = [];
                            _verses = [];
                          });
                          
                          await _loadChapters();
                        }
                      },
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _isLoadingChapters
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        const Text('시작 장', style: TextStyle(fontSize: 12)),
                        DropdownButtonFormField<int>(
                          value: _selectedChapter,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: _chapters.map((n) => DropdownMenuItem(
                            value: n,
                            child: Text('$n'),
                          )).toList(),
                          onChanged: (v) async {
                            if (v != null) {
                              setState(() {
                                _selectedChapter = v;
                                _selectedVerse = 1;
                                _selectedEndChapter = v;
                                _selectedEndVerse = 1;
                                _isLoadingVerses = true;
                                _verses = [];
                              });
                              
                              await _loadVerses();
                            }
                          },
                        ),
                      ],
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _isLoadingVerses
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        const Text('시작 절', style: TextStyle(fontSize: 12)),
                        DropdownButtonFormField<int>(
                          value: _selectedVerse,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: _verses.map((n) => DropdownMenuItem(
                            value: n,
                            child: Text('$n'),
                          )).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _selectedVerse = v;
                                if (_selectedEndChapter == _selectedChapter) {
                                  _selectedEndVerse = v;
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _isLoadingChapters
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        const Text('끝 장', style: TextStyle(fontSize: 12)),
                        DropdownButtonFormField<int>(
                          value: _selectedEndChapter,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: _chapters.map((n) => DropdownMenuItem(
                            value: n,
                            child: Text('$n'),
                          )).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _selectedEndChapter = v;
                                if (_selectedEndChapter < _selectedChapter) {
                                  _selectedEndChapter = _selectedChapter;
                                }
                                if (_selectedEndChapter == _selectedChapter) {
                                  _selectedEndVerse = _selectedVerse;
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _isLoadingVerses
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        const Text('끝 절', style: TextStyle(fontSize: 12)),
                        DropdownButtonFormField<int>(
                          value: _selectedEndVerse,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: _verses.map((n) => DropdownMenuItem(
                            value: n,
                            child: Text('$n'),
                          )).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _selectedEndVerse = v;
                                if (_selectedEndChapter == _selectedChapter && 
                                    _selectedEndVerse < _selectedVerse) {
                                  _selectedEndVerse = _selectedVerse;
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_selectedBook.isNotEmpty) {
                final passage = Passage(
                  testament: _selectedTestament == 'OT' ? '구약' : '신약',
                  book: _selectedBook,
                  startChap: _selectedChapter,
                  startVer: _selectedVerse,
                  endChap: _selectedEndChapter,
                  endVer: _selectedEndVerse,
                );
                widget.onPassageSelected(passage);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}

// 성경 구절 정보를 담는 클래스
class Passage {
  final String testament;
  final String book;
  final int startChap, startVer, endChap, endVer;

  Passage({
    required this.testament,
    required this.book,
    required this.startChap,
    required this.startVer,
    required this.endChap,
    required this.endVer,
  });

  // 화면에 표시될 구절 텍스트를 생성하는 getter
  String get displayText {
    final start = '$startChap:$startVer';
    final end = '$endChap:$endVer';
    return start == end
        ? '$book $start'
        : '$book $start ~ $end';
  }

  // 문자열 형태의 구절 정보를 파싱하여 Passage 객체를 생성하는 factory 생성자
  factory Passage.fromString(String s) {
    final parts = s.split(' ');
    final testament = parts[0];
    final book = parts[1];
    final range = parts.sublist(2).join(' ');

    if (range.contains('~')) {
      final ranges = range.split('~').map((e) => e.trim()).toList();
      final startParts = ranges[0].split(':').map(int.parse).toList();
      final endParts = ranges[1].split(':').map(int.parse).toList();
      return Passage(
        testament: testament,
        book: book,
        startChap: startParts[0],
        startVer: startParts[1],
        endChap: endParts[0],
        endVer: endParts[1],
      );
    } else {
      final singleParts = range.split(':').map(int.parse).toList();
      return Passage(
        testament: testament,
        book: book,
        startChap: singleParts[0],
        startVer: singleParts[1],
        endChap: singleParts[0],
        endVer: singleParts[1],
      );
    }
  }
}