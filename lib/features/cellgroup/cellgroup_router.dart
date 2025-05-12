import 'package:flutter/material.dart';
import 'screens/cellgroup_screen.dart'; // 순 화면 위젯

class CellgroupRoute {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == '/cellgroup') {
      return MaterialPageRoute(builder: (_) => const CellgroupScreen());
    }
    return null; // 처리되지 않은 라우트
  }
}