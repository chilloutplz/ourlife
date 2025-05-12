import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ourlife/theme/markdown_styles.dart';

class QtScreen extends StatelessWidget {
  const QtScreen({super.key});

  final String _markdownData = '''
## Brainstorming

### 1. First step
- [ ] QT 본문 등록
- [ ] QT 구절 pick
- [ ] QT 내용 작성
- [ ] QT 적용 작성

### 2. Next step
- [ ] QT 공유 - 일대일, 순
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QT')),
      body: Markdown(
        data: _markdownData,
        padding: const EdgeInsets.all(16.0),
        styleSheet: MarkdownStyles.defaultStyle,
      ),
    );
  }
}