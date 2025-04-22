// home_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:ourlife/constants/constants.dart';
import 'package:ourlife/providers/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppTheme.white,
      appBar: AppBar(
        // backgroundColor: AppTheme.black,
        title: const Text(
          'OurLife',
          // style: TextStyle(color: AppTheme.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
        // centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TodayVerseCard(),
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
                  icon: Icons.wb_sunny, // QT 아이콘
                  label: 'QT',
                  onTap: () => Navigator.pushNamed(context, '/qt'),
                ),
                _HomeIconButton(
                  icon: Icons.person,
                  label: '일대일',
                  onTap: () => Navigator.pushNamed(context, '/one2one'),
                ),
                _HomeIconButton(
                  icon: Icons.group, // 순 아이콘
                  label: '순',
                  onTap: () => Navigator.pushNamed(context, '/cellgroup'),
                ),
              ],
            ),
          ],
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

  @override
  void initState() {
    super.initState();
    fetchRandomVerse();
  }

  Future<void> fetchRandomVerse() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/bible/random/'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // debugPrint("------------------");
      // debugPrint(jsonDecode(response.body ));
      // debugPrint("------------------");
      setState(() {
        text = data['text'];
        reference = '${data['book']} ${data['chapter']}:${data['number']}';
      });
    } else {
      setState(() {
        text = '말씀을 불러올 수 없습니다.';
        reference = '';
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
        color: colorScheme.primaryContainer, // 테마에 맞는 배경색
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 말씀',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
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
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
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
    return Column(
      children: [
        Ink(
          decoration: const ShapeDecoration(
            shape: CircleBorder(),
            // color: AppTheme.black,
          ),
          child: IconButton(
            icon: Icon(icon),
            onPressed: onTap,
            iconSize: 32,
            // color: AppTheme.white,
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
