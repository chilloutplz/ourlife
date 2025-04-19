import 'package:flutter/material.dart';
// import 'package:ourlife/theme/theme.dart';
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _TodayVerseCard(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  icon: Icons.person,
                  label: '일대일',
                  onTap: () => Navigator.pushNamed(context, '/one2one'),
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
class _TodayVerseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 둥근 테두리
      ),
      color: Colors.white, // 카드 배경
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '오늘의 말씀',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              '"내가 곧 길이요 진리요 생명이니..."',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '- 요한복음 14:6',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ],
        ),
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
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}
