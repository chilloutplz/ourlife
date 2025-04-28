// ourlife/lib/features/notes/screens/note_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

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
  late final FocusNode _pastorFocusNode;
  late final FocusNode _titleFocusNode;
  DateTime _selectedDate = DateTime.now();

  final List<_Passage> _passages = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _pastorController = TextEditingController(text: widget.note?.pastor ?? '');
    _pastorFocusNode = FocusNode();
    _titleFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pastorFocusNode.requestFocus();
    });

    if (widget.note?.biblePassage != null) {
      final passages = widget.note!.biblePassage!
          .split(';')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map(_Passage.fromString);
      _passages.addAll(passages);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _pastorController.dispose();
    _pastorFocusNode.dispose();
    _titleFocusNode.dispose();
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일', 'ko').format(date);
  }

  void _openBiblePassageModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        String testament = '신약';
        String? book;
        int startChap = 1, startVer = 1, endChap = 1, endVer = 1;

        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: testament,
                          items:
                              ['신약', '구약']
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v,
                                      child: Text(v),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => modalSetState(() => testament = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: book,
                          hint: const Text('책 선택'),
                          items:
                              ['창세기', '출애굽기', '요한복음']
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(b),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => modalSetState(() => book = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: startChap,
                          items:
                              List.generate(150, (i) => i + 1)
                                  .map(
                                    (n) => DropdownMenuItem(
                                      value: n,
                                      child: Text('$n 장'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              modalSetState(() {
                                startChap = v;
                                if (endChap < v) endChap = v;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: startVer,
                          items:
                              List.generate(176, (i) => i + 1)
                                  .map(
                                    (n) => DropdownMenuItem(
                                      value: n,
                                      child: Text('$n 절'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              modalSetState(() {
                                startVer = v;
                                if (endVer < v) endVer = v;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('~'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: endChap,
                          items:
                              List.generate(150, (i) => i + 1)
                                  .map(
                                    (n) => DropdownMenuItem(
                                      value: n,
                                      child: Text('$n 장'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) {
                            if (v != null) modalSetState(() => endChap = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: endVer,
                          items:
                              List.generate(176, (i) => i + 1)
                                  .map(
                                    (n) => DropdownMenuItem(
                                      value: n,
                                      child: Text('$n 절'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) {
                            if (v != null) modalSetState(() => endVer = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (book != null) {
                        setState(() {
                          _passages.add(
                            _Passage(
                              testament: testament,
                              book: book!,
                              startChap: startChap,
                              startVer: startVer,
                              endChap: endChap,
                              endVer: endVer,
                            ),
                          );
                        });
                        Navigator.pop(context);

                        // 본문 추가 후 제목에 포커스
                        Future.delayed(const Duration(milliseconds: 300), () {
                          _titleFocusNode.requestFocus();
                        });
                      }
                    },
                    child: const Text('추가'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.note != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? '노트 수정' : '노트 작성')),
      body: Padding(
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
                        const Text(
                          '본문',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _openBiblePassageModal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._passages.map(
                      (p) => ExpansionTile(
                        title: Text(p.displayText),
                        childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        children: [
                          Text(
                            '상세 보기: ${p.displayText}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      decoration: const InputDecoration(
                        hintText: '제목을 입력하세요',
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
                        hintText: '내용을 입력하세요',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
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
                  // textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: _saveNote,
                child: const Text('저장', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: Colors.white),
    );
  }
}

class _Passage {
  final String testament;
  final String book;
  final int startChap, startVer, endChap, endVer;

  _Passage({
    required this.testament,
    required this.book,
    required this.startChap,
    required this.startVer,
    required this.endChap,
    required this.endVer,
  });

  String get displayText {
    final start = '$startChap:$startVer';
    final end = '$endChap:$endVer';
    return start == end
        ? '$testament $book $start'
        : '$testament $book $start ~ $end';
  }

  factory _Passage.fromString(String s) {
    final parts = s.split(' ');
    final testament = parts[0];
    final book = parts[1];
    final range = parts.sublist(2).join(' ');

    if (range.contains('~')) {
      final ranges = range.split('~').map((e) => e.trim()).toList();
      final startParts = ranges[0].split(':').map(int.parse).toList();
      final endParts = ranges[1].split(':').map(int.parse).toList();
      return _Passage(
        testament: testament,
        book: book,
        startChap: startParts[0],
        startVer: startParts[1],
        endChap: endParts[0],
        endVer: endParts[1],
      );
    } else {
      final singleParts = range.split(':').map(int.parse).toList();
      return _Passage(
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
