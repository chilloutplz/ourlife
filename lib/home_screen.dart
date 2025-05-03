// ourlife/lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:ourlife/constants/constants.dart';
import 'package:ourlife/providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // 팝 동작이 발생했을 경우 (canPop: true 였을 때) 처리

        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '한번 더 누르면 앱이 종료됩니다',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white), // 밝은 텍스트 색상
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.grey.shade900.withAlpha(230) // 0.9 * 255 ≈ 230, // 더 진한 배경색
            ),
          );

          return;
        }
        // 2초 이내 재터치 → 앱 종료
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('OurLife'),
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: () {
                Provider.of<ThemeNotifier>(
                  context,
                  listen: false,
                ).toggleTheme();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const TodayVerseCard(),
              const SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 24,
                children: [
                  _HomeIconButton(
                    icon: Icons.menu_book,
                    label: '성경',
                    onTap: () => Navigator.pushNamed(context, '/bible'),
                  ),
                  _HomeIconButton(
                    icon: Icons.note_alt,
                    label: '설교노트',
                    onTap: () => Navigator.pushNamed(context, '/notes'),
                  ),
                  _HomeIconButton(
                    icon: Icons.wb_sunny,
                    label: 'QT',
                    onTap: () => Navigator.pushNamed(context, '/qt'),
                  ),
                  _HomeIconButton(
                    icon: Icons.person,
                    label: '일대일',
                    onTap: () => Navigator.pushNamed(context, '/one2one'),
                  ),
                  _HomeIconButton(
                    icon: Icons.group,
                    label: '순',
                    onTap: () => Navigator.pushNamed(context, '/cellgroup'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 오늘의 말씀 카드
class TodayVerseCard extends StatefulWidget {
  const TodayVerseCard({super.key});

  @override
  State<TodayVerseCard> createState() => _TodayVerseCardState();
}

class _TodayVerseCardState extends State<TodayVerseCard> {
  String text = '';
  String reference = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRandomVerse();
  }

  Future<void> fetchRandomVerse() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/bible/random/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          text = data['text'];
          reference = '${data['book']} ${data['chapter']}:${data['number']}';
          isLoading = false;
        });
      } else {
        setState(() {
          text = '말씀을 불러올 수 없습니다.';
          reference = '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        text = '오류 발생: $e';
        reference = '';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 말씀',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer.withAlpha(204),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (text.startsWith('오류 발생') ||
                      text == '말씀을 불러올 수 없습니다.') ...[
                    Text(
                      text,
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: fetchRandomVerse,
                      child: const Text('다시 시도'),
                    ),
                  ] else ...[
                    Text(
                      '"$text"',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '- $reference',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer.withAlpha(179),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
    );
  }
}

// 홈 아이콘 버튼
class _HomeIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Ink(
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            // color: colorScheme.primaryContainer,
          ),
          child: IconButton(
            icon: Icon(icon),
            onPressed: onTap,
            iconSize: 32,
            // color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}
