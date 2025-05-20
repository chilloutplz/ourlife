// lib/widgets/home/today_verse_card.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ourlife/constants/constants.dart';
import 'package:ourlife/widgets/bootstrap_card.dart';
import 'package:ourlife/theme/bootstrap_theme.dart';

class TodayVerseCard extends StatefulWidget {
  const TodayVerseCard({super.key});

  @override
  State<TodayVerseCard> createState() => _TodayVerseCardState();
}

class _TodayVerseCardState extends State<TodayVerseCard> {
  Map<String, dynamic>? _verse;
  bool _isLoading = true;
  String? _error;
  String? _versionSlug;

  @override
  void initState() {
    super.initState();
    _loadSelectedVersionAndFetch();
  }

  Future<void> _loadSelectedVersionAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final versions = prefs.getStringList('selected_versions');
    final versionSlug = (versions != null && versions.isNotEmpty)
        ? versions.first
        : '우리말'; // 기본값

    setState(() {
      _versionSlug = versionSlug;
    });

    await _fetchTodayVerse(versionSlug);
  }

  Future<void> _fetchTodayVerse(String versionSlug) async {
    setState(() { 
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/bible/random/?version=$versionSlug');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        setState(() {
          _verse = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '말씀을 불러올 수 없습니다. (${resp.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '에러: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget bodyContent;
    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      bodyContent = Text(
        _error!,
        style: TextStyle(color: cs.error),
      );
    } else if (_verse != null) {
      bodyContent = Text(
        _verse!['text'] ?? '',
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      );
    } else {
      bodyContent = const Text('오늘의 말씀을 찾을 수 없습니다.');
    }

    final footerContent = _error != null
        ? TextButton(
            onPressed: () => _fetchTodayVerse(_versionSlug!),
            child: const Text('다시 시도'),
          )
        : _verse != null
            ? Text(
                "- ${_verse!['book']} ${_verse!['chapter']}:${_verse!['number']} (${_verse!['version']})",
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 14,
                ),
              )
            : const SizedBox.shrink();

    return BootstrapCard(
      type: BootstrapCardType.info,
      twoTone: true,
      outline: true,
      header: SizedBox(
        height: 20,
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
              icon: const Icon(Icons.refresh, size: 20),
              color: BootstrapColors.light,
              tooltip: '새로고침',
              // onPressed: () => _fetchTodayVerse(_versionSlug!),
              onPressed: _loadSelectedVersionAndFetch,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      headerAlignment: Alignment.center,
      body: bodyContent,
      footer: footerContent,
      footerAlignment: Alignment.centerRight,
    );
  }
}
