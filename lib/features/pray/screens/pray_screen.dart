import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ourlife/theme/markdown_styles.dart';

class PrayScreen extends StatelessWidget {
  const PrayScreen({super.key});

  final String _markdownData = '''
## Brainstorming

### 1. First step
- [ ] 나의 기도와 중보 기도 구분
- [ ] 기도 제목 작성
- [ ] 기도 완료 체크 및 메모

### 2. Next step
- [ ] 기도 제목 공유 - 일대일, 순
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기도')),
      body: Markdown(
        data: _markdownData,
        padding: const EdgeInsets.all(16.0),
        styleSheet: MarkdownStyles.defaultStyle,
      ),
    );
  }
}