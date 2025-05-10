// lib/widgets/home/today_verse_card.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ourlife/constants/constants.dart';
import 'package:ourlife/widgets/bootstrap_card.dart';
import 'package:ourlife/theme/bootstrap_theme.dart';

class TodayVerseCard extends StatefulWidget {
  const TodayVerseCard({super.key});

  @override
  State<TodayVerseCard> createState() => _TodayVerseCardState();
}

class _TodayVerseCardState extends State<TodayVerseCard> {
  String text = '';
  String reference = '';
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchRandomVerse();
  }

  Future<void> fetchRandomVerse() async {
    setState(() { isLoading = true; isError = false; });

    try {
      final resp = await http.get(Uri.parse('${ApiConstants.baseUrl}/bible/random/'));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          text = data['text'];
          reference = '${data['book']} ${data['chapter']}:${data['number']}';
          isLoading = false;
        });
      } else {
        throw Exception('status ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        text = '말씀을 불러올 수 없습니다.';
        reference = '';
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BootstrapCard(
      type: BootstrapCardType.info,
      twoTone: true,
      outline: true,
      header: SizedBox(
        height: 20, // 고정된 높이 설정
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '오늘의 말씀',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20), // 아이콘 크기 조정
              color: BootstrapColors.light, // 아이콘 색상
              tooltip: '새로고침',
              onPressed: fetchRandomVerse, // 새로고침 기능
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32, // 버튼 크기 제한
              ),
              padding: EdgeInsets.zero, // 내부 여백 제거
            ),
          ],
        ),
      ),
      headerAlignment: Alignment.center,
      // body: 로딩 중이면 스피너, 에러면 에러 메시지, 아니면 본문
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Text(
              '"$text"',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
      // footer: 에러 시 재시도 버튼, 정상 시 reference
      footer: isError
          ? TextButton(
              onPressed: fetchRandomVerse,
              child: const Text('다시 시도'),
            )
          : Text(
              "- $reference",
              style: TextStyle(
                color: cs.onSurface.withAlpha(255),
                fontSize: 14,
              ),
            ),
      footerAlignment: Alignment.centerRight,
    );
  }
}
