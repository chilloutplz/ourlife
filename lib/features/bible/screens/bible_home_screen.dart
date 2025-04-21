import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/constants.dart';
import '../models.dart';
import '../bible_service.dart';

class BibleHomeScreen extends StatefulWidget {
  const BibleHomeScreen({super.key});
  @override State<BibleHomeScreen> createState() => _State();
}

class _State extends State<BibleHomeScreen> {
  List<Version> _versions = [];
  String? _selected;
  bool _loading = true;

  @override void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _versions = await BibleService.getVersions();
    _selected = _versions.first.slug;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext c) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('성경'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(c, '/bible/search'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          DropdownButton<String>(
            value: _selected,
            items: _versions.map((v) =>
              DropdownMenuItem(value: v.slug, child: Text(v.name))
            ).toList(),
            onChanged: (s) => setState(() => _selected = s),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                c, '/bible/books',
                arguments: _selected,
              );
            },
            child: const Text('책 보기'),
          )
        ]),
      ),
    );
  }
}
