import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_HomeFeature> features = [
      _HomeFeature(
        title: '성경',
        icon: Icons.menu_book_rounded,
        onTap: () {
          // TODO: 성경 페이지로 이동
        },
      ),
      _HomeFeature(
        title: '설교노트',
        icon: Icons.edit_note_rounded,
        onTap: () {
          // TODO: 설교노트 페이지로 이동
        },
      ),
      _HomeFeature(
        title: '일대일',
        icon: Icons.people_alt_rounded,
        onTap: () {
          // TODO: 일대일 페이지로 이동
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC), // 크림톤
      appBar: AppBar(
        title: const Text('OurLife'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _TodayVerseCard(), // ⬅ 오늘의 말씀 카드
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                children: features.map((f) => _FeatureCard(feature: f)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayVerseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '오늘의 말씀',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '"내게 능력 주시는 자 안에서 내가 모든 것을 할 수 있느니라"',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '- 빌립보서 4:13',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeFeature {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _HomeFeature({required this.title, required this.icon, required this.onTap});
}

class _FeatureCard extends StatelessWidget {
  final _HomeFeature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: feature.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(feature.icon, size: 48, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              feature.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
