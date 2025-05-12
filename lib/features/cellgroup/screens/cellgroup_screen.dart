import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ourlife/theme/markdown_styles.dart';

class CellgroupScreen extends StatelessWidget {
  const CellgroupScreen({super.key});

  final String _markdownData = '''
## Brainstorming

### 1. 기본 기능
- [ ] 순 생성
- [ ] 순 세부 정보 페이지
- [ ] 순 멤버 목록

### 2. 순원 관리
- [ ] 순원 초대 및 제거
- [ ] 역할 (순장, 권찰, 부순장, 순원) 관리

### 3. 모임 기능
- [ ] 모임 추가/편집/삭제
- [ ] 본문 추가, 관련자료(배경, 질문)
- [ ] 모임 정보 공유 - 장소, 연락처, 차량번호, QT, 기도제목 등
- [ ] 참석 의사 표시
- [ ] 지난 모임 기록 보기
- [ ] 실제 출석 체크 기능
- [ ] 순헌금

### 4. 기타
- [ ] 모임 추가 알림 설정

''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('순')),
      body: Markdown(
        data: _markdownData,
        padding: const EdgeInsets.all(16.0),
        styleSheet: MarkdownStyles.defaultStyle,
      ),
    );
  }
}
