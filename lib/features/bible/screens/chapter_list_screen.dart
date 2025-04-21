import 'package:flutter/material.dart';
import '../bible_service.dart';

class ChapterListScreen extends StatefulWidget {
  final String version, book;
  const ChapterListScreen({required this.version, required this.book, super.key});
  @override State<ChapterListScreen> createState() => _SC();
}

class _SC extends State<ChapterListScreen> {
  late Future<List<int>> _future;
  @override void initState() {
    super.initState();
    _future = BibleService.getChapters(widget.version, widget.book);
  }

  @override Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.book} 장')),
      body: FutureBuilder<List<int>>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: snap.data!
              .map((n) => ListTile(
                title: Text('장 $n'),
                onTap: () => Navigator.pushNamed(
                  c, '/bible/verses',
                  arguments: {
                    'version': widget.version,
                    'book': widget.book,
                    'chapter': n
                  },
                ),
              ))
              .toList(),
          );
        },
      ),
    );
  }
}
