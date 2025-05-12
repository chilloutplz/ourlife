import 'package:flutter/material.dart';
import 'screens/qt_screen.dart'; // QT 화면 위젯

class QtRoute {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == '/qt') {
      return MaterialPageRoute(builder: (_) => const QtScreen());
    }
    return null; // 처리되지 않은 라우트
  }
}