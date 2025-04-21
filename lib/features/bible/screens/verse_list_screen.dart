import 'package:flutter/material.dart';
import '../models.dart';
import '../bible_service.dart';

class VerseListScreen extends StatefulWidget {
  final String version, book;
  final int chapter;
  const VerseListScreen({
    required this.version, required this.book,
    required this.chapter, super.key
  });
  @override State<VerseListScreen> createState() => _SV();
}

class _SV extends State<VerseListScreen> {
  late Future<List<Verse>> _future;
  @override void initState() {
    super.initState();
    _future = BibleService.getVerses(
      widget.version, widget.book, widget.chapter);
  }

  @override Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text('절 ${widget.chapter}')),
      body: FutureBuilder<List<Verse>>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.all(16),
            children: snap.data!
              .map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('${v.number}. ${v.text}',
                  style: Theme.of(c).textTheme.bodyMedium),
              ))
              .toList(),
          );
        },
      ),
    );
  }
}
