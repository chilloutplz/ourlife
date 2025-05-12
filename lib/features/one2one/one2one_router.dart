import 'package:flutter/material.dart';
import 'screens/one2one_screen.dart'; // 1:1 화면 위젯

class One2oneRoute {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == '/one2one') {
      return MaterialPageRoute(builder: (_) => const One2oneScreen());
    }
    return null; // 처리되지 않은 라우트
  }
}