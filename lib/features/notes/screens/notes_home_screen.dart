// lib/features/notes/screens/notes_home_screen.dart
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/database_helper.dart';
import 'note_edit_screen.dart';
import 'package:ourlife/theme/bootstrap_theme.dart';
// import 'package:ourlife/widgets/bootstrap_card.dart';

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({super.key});

  @override
  State<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notes = await DatabaseHelper.instance.getAllNotes();
      
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('노트를 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      await DatabaseHelper.instance.deleteNote(id);
      await _loadNotes(); // 목록 새로고침
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('노트를 삭제하는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '날짜 정보 없음';
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year년 $month월 $day일';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('노트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const Center(child: Text('저장된 노트가 없습니다.'))
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteEditScreen(note: note), // 노트 데이터를 전달
                          ),
                        );
                        if (result != null) {
                          _loadNotes(); // 수정 후 목록 새로고침
                        }
                      },
                      child: Card(
                        margin: darkCardTheme.margin, // darkCardTheme의 여백
                        elevation: darkCardTheme.elevation, // darkCardTheme의 그림자 효과
                        shape: darkCardTheme.shape, // darkCardTheme의 모양
                        color: darkCardTheme.color, // darkCardTheme의 배경색
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(note.preachedAt), // 설교 일자
                                    style: TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white, // 텍스트 색상
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('삭제 확인'),
                                            content: const Text('이 노트를 삭제하시겠습니까?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(false); // 취소
                                                },
                                                child: const Text('취소'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(true); // 확인
                                                },
                                                child: const Text(
                                                  '삭제',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirm == true) {
                                        await _deleteNote(note.id); // 삭제 진행
                                      }
                                    },
                                    child: const Text(
                                      '삭제', // 삭제 텍스트 표시
                                      style: TextStyle(
                                        color: BootstrapColors.warning, // 텍스트 색상
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    note.pastor ?? '설교자 없음', // 설교자 이름
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white, // 텍스트 색상
                                    ),
                                  ),
                                  const SizedBox(width: 8), // 설교자와 아이콘 사이 간격
                                  const Icon(
                                    Icons.volume_up_outlined, // 마이크 아이콘
                                    color: BootstrapColors.info, // 아이콘 색상
                                    size: 18, // 아이콘 크기
                                  ),
                                  const SizedBox(width: 8), // 아이콘과 제목 사이 간격
                                  Text(
                                    note.title, // 제목
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white, // 텍스트 색상
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                note.biblePassage ?? '북장절 정보 없음', // 북장절
                                style: TextStyle(
                                  fontSize: 14,
                                  color: BootstrapColors.info, // 흐린 텍스트 색상
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteEditScreen(),
            ),
          );
          if (result != null) {
            _loadNotes(); // 새 노트가 추가되었으면 목록 새로고침
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
