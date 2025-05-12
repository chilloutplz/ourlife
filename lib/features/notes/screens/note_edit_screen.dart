// ourlife/lib/features/notes/screens/note_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../../bible/services/bible_service.dart';
import '../../bible/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';
import 'package:ourlife/theme/bootstrap_theme.dart';

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
  Map<String, List<Verse>> versesByVersion = {};

  final List<Passage> _passages = [];
  double _sidePanelFontSize = 14.0; 

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { 
        _pastorFocusNode.requestFocus();
      }
    });

    if (widget.note?.biblePassage != null) {
      try {
        final passages = widget.note!.biblePassage!
            .split(';')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) {
              try {
                return Passage.fromString(s);
              } catch (e) {
                debugPrint('Error parsing individual passage: $s, error: $e');
                return null;
              }
            })
            .where((p) => p != null)
            .cast<Passage>()
            .toList();
        
        _passages.addAll(passages);
        _loadPassageContents(passages);
      } catch (e) {
        debugPrint('Error parsing biblePassage: ${widget.note!.biblePassage}, error: $e');
      }
    }

    _titleController.addListener(_updateSaveButtonState);
    _contentController.addListener(_updateSaveButtonState);
    _loadSidePanelFontSize();
  }

  Future<void> _loadSidePanelFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _sidePanelFontSize = prefs.getDouble('noteEditScreen_sidePanelFontSize') ?? 14.0;
    });
  }

  Future<void> _saveSidePanelFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('noteEditScreen_sidePanelFontSize', _sidePanelFontSize);
  }

  void _increaseSidePanelFontSize() {
    if (!mounted) return;
    setState(() {
      _sidePanelFontSize = (_sidePanelFontSize + 1.0).clamp(10.0, 24.0);
    });
    _saveSidePanelFontSize();
  }

  void _decreaseSidePanelFontSize() {
    if (!mounted) return;
    setState(() {
      _sidePanelFontSize = (_sidePanelFontSize - 1.0).clamp(10.0, 24.0);
    });
    _saveSidePanelFontSize();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _pastorController.dispose();
    _passageController.dispose();
    _pastorFocusNode.dispose();
    _titleFocusNode.dispose();
    _titleController.removeListener(_updateSaveButtonState);
    _contentController.removeListener(_updateSaveButtonState);
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko'),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
      _updateSaveButtonState();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일', 'ko').format(date);
  }

  void _openBiblePassageModal() {
    showDialog(
      context: context,
      builder: (dialogContext) => BiblePassageSelector(
        initialTestament: _selectedTestament,
        onPassageSelected: (passage) async {
          if (!mounted) return;
          setState(() {
            _passages.add(passage);
          });
          final currentPassageIndex = _passages.length - 1;

          Navigator.pop(dialogContext);

          try {
            final prefs = await SharedPreferences.getInstance();
            final selectedVersions = prefs.getStringList('selected_versions') ?? ['우리말'];
            
            Map<String, List<Verse>> fetchedVersesForRangeByVersion = {};
            for (var versionName in selectedVersions) {
              List<Verse> aggregatedVersesForThisVersion = [];
              for (int chap = passage.startChap; chap <= passage.endChap; chap++) {
                final chapterVerses = await BibleService.getVerses(versionName, passage.book, chap);
                aggregatedVersesForThisVersion.addAll(chapterVerses);
              }
              fetchedVersesForRangeByVersion[versionName] = aggregatedVersesForThisVersion;
            }

            if (!mounted) return;

            final firstSelectedVersionName = selectedVersions.first;
            final List<Verse> referenceVerseList = fetchedVersesForRangeByVersion[firstSelectedVersionName] ?? [];

            final int actualStartIndex = referenceVerseList.indexWhere(
                (v) => v.chapter == passage.startChap && v.number == passage.startVer);
            final int actualEndIndex = referenceVerseList.indexWhere(
                (v) => v.chapter == passage.endChap && v.number == passage.endVer);

            if (actualStartIndex != -1 && actualEndIndex != -1 && actualStartIndex <= actualEndIndex) {
              final books = await BibleService.getBooks(firstSelectedVersionName);
              final bookName = books.firstWhere((book) => book.slug == passage.book).name;
              
              String chapterDisplay = passage.startChap == passage.endChap 
                  ? '${passage.startChap}장' 
                  : '${passage.startChap}-${passage.endChap}장';
              
              final titleSpan = TextSpan(
                text: '$bookName $chapterDisplay',
                style: const TextStyle( 
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              );

              final verseSpans = <TextSpan>[];
              for (int i = actualStartIndex; i <= actualEndIndex; i++) {
                final Verse refVerse = referenceVerseList[i];
                final int currentChapter = refVerse.chapter;
                final int currentVerseNum = refVerse.number;
                var isFirstVersionForThisVerse = true; 
                
                for (var versionName in selectedVersions) {
                  final List<Verse> versesOfThisVersion = fetchedVersesForRangeByVersion[versionName] ?? [];
                  Verse? actualVerseToDisplay;
                  try {
                    actualVerseToDisplay = versesOfThisVersion.firstWhere(
                        (v) => v.chapter == currentChapter && v.number == currentVerseNum);
                  } catch (e) {
                    // Verse not found
                  }

                  if (actualVerseToDisplay != null) {
                    verseSpans.add(TextSpan( 
                      children: [
                        if (isFirstVersionForThisVerse) TextSpan(
                          text: '$currentVerseNum ',
                          style: const TextStyle( 
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '$versionName ',
                          style: const TextStyle( 
                            color: BootstrapColors.info,
                            fontStyle: FontStyle.italic,
                            fontSize: 10
                          ),
                        ),
                        TextSpan(
                          text: actualVerseToDisplay.text,
                           style: const TextStyle(color: Colors.white), 
                        ),
                      ],
                    ));
                    isFirstVersionForThisVerse = false;
                  }
                }
              }
              
              if (!mounted) return;
              setState(() {
                if (currentPassageIndex < _passages.length) {
                    _passages[currentPassageIndex].titleSpan = titleSpan;
                    _passages[currentPassageIndex].verseSpans = verseSpans;
                }
                _isSidePanelVisible = true;
              });

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

  Future<void> _saveNote() async {
    final note = Note(
      id: widget.note?.id ?? DateTime.now().toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      preachedAt: _selectedDate,
      pastor: _pastorController.text.trim(),
      biblePassage: _passages.map((p) => p.displayText).join('; '),
    );

    try {
      if (widget.note == null) {
        await DatabaseHelper.instance.insertNote(note);
      } else {
        await DatabaseHelper.instance.updateNote(note);
      }
      
      if (mounted) {
        Navigator.pop(context, note);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('노트 저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateSaveButtonState() {
    if (!mounted) return;
    setState(() {
      _isSaveButtonActive = _titleController.text.trim().isNotEmpty || 
                          _contentController.text.trim().isNotEmpty;
    });
  }

  Future<void> _loadPassageContents(List<Passage> passagesToLoad) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedVersions = prefs.getStringList('selected_versions') ?? ['우리말'];

      for (int passageIdx = 0; passageIdx < passagesToLoad.length; passageIdx++) {
        final passage = passagesToLoad[passageIdx];
        Map<String, List<Verse>> fetchedVersesForRangeByVersion = {};
        for (var versionName in selectedVersions) {
          List<Verse> aggregatedVersesForThisVersion = [];
          for (int chap = passage.startChap; chap <= passage.endChap; chap++) {
            final chapterVerses = await BibleService.getVerses(versionName, passage.book, chap);
            aggregatedVersesForThisVersion.addAll(chapterVerses);
          }
          fetchedVersesForRangeByVersion[versionName] = aggregatedVersesForThisVersion;
        }

        if (!mounted) return;

        final firstSelectedVersionName = selectedVersions.first;
        final List<Verse> referenceVerseList = fetchedVersesForRangeByVersion[firstSelectedVersionName] ?? [];

        final int actualStartIndex = referenceVerseList.indexWhere(
            (v) => v.chapter == passage.startChap && v.number == passage.startVer);
        final int actualEndIndex = referenceVerseList.indexWhere(
            (v) => v.chapter == passage.endChap && v.number == passage.endVer);
        
        if (actualStartIndex != -1 && actualEndIndex != -1 && actualStartIndex <= actualEndIndex) {
          final books = await BibleService.getBooks(firstSelectedVersionName);
          final bookName = books.firstWhere((book) => book.slug == passage.book).name;
          
          String chapterDisplay = passage.startChap == passage.endChap 
              ? '${passage.startChap}장' 
              : '${passage.startChap}-${passage.endChap}장';
          
          final titleSpan = TextSpan(
            text: '$bookName $chapterDisplay',
            style: const TextStyle( 
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          );

          final verseSpans = <TextSpan>[];
          for (int i = actualStartIndex; i <= actualEndIndex; i++) {
            final Verse refVerse = referenceVerseList[i];
            final int currentChapter = refVerse.chapter;
            final int currentVerseNum = refVerse.number;
            var isFirstVersionForThisVerse = true;
            
            for (var versionName in selectedVersions) {
              final List<Verse> versesOfThisVersion = fetchedVersesForRangeByVersion[versionName] ?? [];
              Verse? actualVerseToDisplay;
              try {
                actualVerseToDisplay = versesOfThisVersion.firstWhere(
                    (v) => v.chapter == currentChapter && v.number == currentVerseNum);
              } catch (e) {
                // Verse not found
              }

              if (actualVerseToDisplay != null) {
                verseSpans.add(TextSpan( 
                  children: [
                    if (isFirstVersionForThisVerse) TextSpan(
                      text: '$currentVerseNum ',
                      style: const TextStyle( 
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '$versionName ',
                      style: const TextStyle( 
                        color: BootstrapColors.info,
                        fontStyle: FontStyle.italic,
                        fontSize: 10
                      ),
                    ),
                    TextSpan(
                      text: actualVerseToDisplay.text,
                      style: const TextStyle(color: Colors.white), 
                    ),
                  ],
                ));
                isFirstVersionForThisVerse = false;
              }
            }
          }
          
          if (!mounted) return;
          setState(() {
            final indexInState = _passages.indexWhere((p) => 
                p.book == passage.book && 
                p.startChap == passage.startChap && p.startVer == passage.startVer &&
                p.endChap == passage.endChap && p.endVer == passage.endVer
            );
            if (indexInState != -1) {
                 _passages[indexInState].titleSpan = titleSpan;
                 _passages[indexInState].verseSpans = verseSpans;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading passage contents: $e');
    }
  }

  TextSpan _applyFontSizeToTextSpan(TextSpan? originalSpan, double baseFontSize, {bool isTitle = false}) {
    if (originalSpan == null) return const TextSpan();

    TextStyle newStyle = originalSpan.style ?? const TextStyle();

    if (isTitle) {
        newStyle = newStyle.copyWith(
            fontSize: baseFontSize + 2.0, 
            color: Colors.blue,
            fontWeight: FontWeight.bold
        );
    } else {
      if (originalSpan.text != null) {
        if (originalSpan.text!.trim().endsWith(' ') && int.tryParse(originalSpan.text!.trim()) != null) { 
          newStyle = newStyle.copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: baseFontSize
          );
        } else if (originalSpan.text!.startsWith('[') && originalSpan.text!.endsWith('] ')) { 
          newStyle = newStyle.copyWith(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
            fontSize: (baseFontSize - 2.0).clamp(8.0, 22.0) 
          );
        } else { 
          newStyle = newStyle.copyWith(fontSize: baseFontSize, color: Colors.white);
        }
      } else { 
         newStyle = newStyle.copyWith(fontSize: baseFontSize, color: Colors.white);
      }
    }
    
    return TextSpan(
      text: originalSpan.text,
      children: originalSpan.children?.map((child) {
        if (child is TextSpan) {
          return _applyFontSizeToTextSpan(child, baseFontSize, isTitle: false);
        }
        return child; 
      }).toList(),
      style: newStyle,
      recognizer: originalSpan.recognizer,
      semanticsLabel: originalSpan.semanticsLabel,
      mouseCursor: originalSpan.mouseCursor,
      onEnter: originalSpan.onEnter,
      onExit: originalSpan.onExit,
    );
  }


  @override
  Widget build(BuildContext context) {
    final isEdit = widget.note != null;

    // 테마에 따라 텍스트 색상 설정
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black // Light 테마에서는 검정색 텍스트
        : Colors.white; // Dark 테마에서는 흰색 텍스트

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? '노트 수정' : '노트 작성')),
      body: GestureDetector(
        onTap: () {
          if (_isSidePanelVisible) {
            if (!mounted) return;
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
                                _buildSectionLabel('설교일자', textColor),
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
                                _buildSectionLabel('설교자', textColor),
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
                                        if (!mounted) return;
                                        setState(() {
                                          _passages.remove(p);
                                          _isSidePanelVisible = _passages.isNotEmpty; 
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
                                  controller: _contentController,
                                  decoration: const InputDecoration(
                                    hintText: '노트를 시작하세요',
                                    border: InputBorder.none,
                                  ),
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  style: TextStyle(fontSize: 16, color: textColor),
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
                      if (!mounted) return;
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
                  onTap: () {}, 
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[800]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.text_decrease),
                                  iconSize: 20,
                                  padding: const EdgeInsets.all(2),
                                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30), // Slightly smaller touch area
                                  onPressed: _decreaseSidePanelFontSize,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.text_increase),
                                  iconSize: 20,
                                  padding: const EdgeInsets.all(2),
                                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30), // Slightly smaller touch area
                                  onPressed: _increaseSidePanelFontSize,
                                ),
                              ],
                            ),
                            const Expanded(
                              child: Text(
                                '본문 내용',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 28, // Smaller width for the circle
                              height: 28, // Smaller height for the circle
                              margin: const EdgeInsets.only(left: 4), // Ensure some space from title
                              decoration: BoxDecoration(
                                color: BootstrapColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.chevron_right),
                                iconSize: 16, // Smaller icon
                                color: Colors.white,
                                padding: EdgeInsets.zero,
                                alignment: Alignment.center,
                                onPressed: () {
                                  if (!mounted) return;
                                  setState(() {
                                    _isSidePanelVisible = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_passages.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      '본문을 추가해주세요',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ..._passages.map((passage) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withAlpha(26),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: RichText(text: _applyFontSizeToTextSpan(passage.titleSpan, _sidePanelFontSize, isTitle: true)),
                                    ),
                                    const SizedBox(height: 8),
                                    if (passage.verseSpans != null) ...[
                                      ...passage.verseSpans!.map((span) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: RichText(text: _applyFontSizeToTextSpan(span, _sidePanelFontSize)),
                                      )),
                                      const SizedBox(height: 16),
                                    ],
                                  ],
                                )),
                            ],
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

  Widget _buildSectionLabel(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: textColor),
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
    if (!mounted) return;
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
    if (!mounted) return;
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
                      if (!mounted) return;
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
                      if (!mounted) return;
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
                           if (!mounted) return;
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
                              if (!mounted) return;
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
                              if (!mounted) return;
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
                          onChanged: (v) async {
                            if (v != null) {
                              if (!mounted) return;
                              setState(() {
                                _selectedEndChapter = v;
                                if (_selectedEndChapter < _selectedChapter) { 
                                  _selectedEndChapter = _selectedChapter;
                                }
                                if (_selectedEndChapter != _selectedChapter) {
                                   _selectedEndVerse = _verses.isNotEmpty ? _verses.first : 1;
                                } else { 
                                   if(_selectedEndVerse < _selectedVerse) _selectedEndVerse = _selectedVerse;
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
                          items: (_selectedEndChapter == _selectedChapter ? _verses : _chapters.isNotEmpty ? List.generate(_chapters.last, (i) => i + 1) : [1]) 
                              .map((n) => DropdownMenuItem(
                            value: n,
                            child: Text('$n'),
                          )).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              if (!mounted) return;
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
  String? content;
  TextSpan? titleSpan; 
  List<TextSpan>? verseSpans; 

  Passage({
    required this.testament,
    required this.book,
    required this.startChap,
    required this.startVer,
    required this.endChap,
    required this.endVer,
    this.content,
    this.titleSpan, 
    this.verseSpans, 
  });

  String get displayText {
    final start = '$startChap:$startVer';
    final end = '$endChap:$endVer';
    return start == end
        ? '$book $start'
        : '$book $start ~ $end';
  }

  factory Passage.fromString(String s) {
    debugPrint('Parsing passage string: $s');
    try {
      final parts = s.split(' ');
      if (parts.length < 2) {
        debugPrint('Invalid passage format: $s (not enough parts, needs at least 2)');
        throw FormatException('Invalid passage format');
      }

      final book = parts[0]; // 책 이름
      final rangeString = parts.sublist(1).join(' '); // 장절 정보

      if (rangeString.contains('~')) {
        // 범위가 있는 경우 처리
        final ranges = rangeString.split('~').map((e) => e.trim()).toList();
        if (ranges.length != 2) {
          debugPrint('Invalid range format: $rangeString');
          throw FormatException('Invalid range format');
        }

        final startParts = ranges[0].split(':').map(int.parse).toList(); // 시작 장절
        final endParts = ranges[1].split(':').map(int.parse).toList();   // 끝 장절

        if (startParts.length != 2 || endParts.length != 2) {
          debugPrint('Invalid verse format in range: $rangeString');
          throw FormatException('Invalid verse format');
        }

        return Passage(
          testament: book.startsWith('구약') ? '구약' : '신약', // 구약/신약 판단
          book: book,
          startChap: startParts[0],
          startVer: startParts[1],
          endChap: endParts[0],
          endVer: endParts[1],
        );
      } else {
        // 범위가 없는 경우 처리 (예: 1:1)
        final singleParts = rangeString.split(':').map(int.parse).toList();
        if (singleParts.length != 2) {
          debugPrint('Invalid verse format: $rangeString');
          throw FormatException('Invalid verse format');
        }

        return Passage(
          testament: book.startsWith('구약') ? '구약' : '신약',
          book: book,
          startChap: singleParts[0],
          startVer: singleParts[1],
          endChap: singleParts[0], // 시작 장과 끝 장 동일
          endVer: singleParts[1], // 시작 절과 끝 절 동일
        );
      }
    } catch (e) {
      debugPrint('Error parsing passage: $s, error: $e');
      rethrow;
    }
  }
}
