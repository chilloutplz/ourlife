import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  bool _isDark = true; // 기본 테마는 다크모드

  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners(); // 테마 변경을 위젯 트리에 알림
  }

  ThemeMode get currentTheme => _isDark ? ThemeMode.dark : ThemeMode.light;
}
