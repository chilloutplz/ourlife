// lib/widgets/home/home_body.dart
import 'package:flutter/material.dart';
import 'package:ourlife/theme/bootstrap_theme.dart';
import 'package:ourlife/widgets/home/today_verse_card.dart';
import 'package:ourlife/widgets/home/home_icon_button.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TodayVerseCard(),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.start,
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
                label: '설교',
                routeName: '/notes',
              ),
              HomeIconButton(
                icon: Icons.list,
                label: '기도',
                routeName: '/pray',
                color: BootstrapColors.muted
              ),
              HomeIconButton(
                icon: Icons.wb_sunny,
                label: 'QT',
                routeName: '/qt',
                color: BootstrapColors.muted
              ),
              HomeIconButton(
                icon: Icons.person,
                label: '1:1',
                routeName: '/one2one',
                color: BootstrapColors.muted,
              ),
              HomeIconButton(
                icon: Icons.group,
                label: '순',
                routeName: '/cellgroup',
                color: BootstrapColors.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
