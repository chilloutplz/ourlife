import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ourlife/theme/markdown_styles.dart';

class One2oneScreen extends StatelessWidget {
  const One2oneScreen({super.key});

  final String _markdownData = '''
## Brainstorming

### 1. First step
- [ ] 일대일 양육의 시작과 끝(연결)
- [ ] 챕터별 예습 작성 - 과제점검에 반영
  - 동반자과정, 양육자과정, 양육자로써 작성 history
- [ ] 관련 성경말씀, 암송구절 제공
- [ ] 간증문 작성(template 제공)

### 2. Next step
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1:1')),
      body: Markdown(
        data: _markdownData,
        padding: const EdgeInsets.all(16.0),
        styleSheet: MarkdownStyles.defaultStyle,
      ),
    );
  }
}