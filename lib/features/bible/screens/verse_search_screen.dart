import 'package:flutter/material.dart';
import '../models.dart';
import '../services/bible_service.dart';

class VerseSearchScreen extends StatefulWidget {
  const VerseSearchScreen({super.key});
  @override State<VerseSearchScreen> createState() => _SS();
}

class _SS extends State<VerseSearchScreen> {
  final _ctrl = TextEditingController();
  List<Verse> _results = [];
  bool _loading = false;

  Future<void> _search() async {
    setState(() => _loading = true);
    _results = await BibleService.search(_ctrl.text);
    setState(() => _loading = false);
  }

  @override Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('말씀 검색')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: '검색어를 입력하세요',
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          if (_loading) const CircularProgressIndicator(),
          if (!_loading)
            Expanded(
              child: ListView(
                children: _results.map((v) => ListTile(
                  title: Text('${v.book} ${v.chapter}:${v.number}'),
                  subtitle: Text(v.text),
                )).toList(),
              ),
            ),
        ]),
      ),
    );
  }
}
