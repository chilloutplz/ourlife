import 'package:flutter/material.dart';
import 'screens/bible_home_screen.dart';

class BibleRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/bible':
        return MaterialPageRoute(builder: (_) => const BibleHomeScreen());
      // 추가적인 Bible 관련 라우트 정의 가능
      default:
        return null;
    }
  }
}