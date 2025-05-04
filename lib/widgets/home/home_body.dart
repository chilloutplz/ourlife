// lib/widgets/home/home_body.dart
import 'package:flutter/material.dart';
import 'package:ourlife/widgets/home/today_verse_card.dart';
import 'package:ourlife/widgets/home/home_icon_button.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const TodayVerseCard(),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 24,
            children: const [
              HomeIconButton(
                icon: Icons.menu_book,
                label: '성경',
                routeName: '/bible',
              ),
              HomeIconButton(
                icon: Icons.note_alt,
                label: '설교노트',
                routeName: '/notes',
              ),
              HomeIconButton(
                icon: Icons.wb_sunny,
                label: 'QT',
                routeName: '/qt',
              ),
              HomeIconButton(
                icon: Icons.person,
                label: '일대일',
                routeName: '/one2one',
              ),
              HomeIconButton(
                icon: Icons.group,
                label: '순',
                routeName: '/cellgroup',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
