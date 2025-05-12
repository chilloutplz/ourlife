import 'package:flutter/material.dart';
import 'screens/pray_screen.dart'; // Pray 화면 위젯

class PrayRoute {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == '/pray') {
      return MaterialPageRoute(builder: (_) => const PrayScreen());
    }
    return null; // 처리되지 않은 라우트
  }
}