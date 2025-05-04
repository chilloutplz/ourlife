// lib/widgets/home/today_verse_card.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ourlife/constants/constants.dart';

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
    setState(() => isLoading = true);

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
      child: isLoading
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
