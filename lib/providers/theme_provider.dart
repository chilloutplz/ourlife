import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true); // 기본 테마: 다크 모드

  bool get isDark => state;

  void toggleTheme() {
    state = !state;
  }

  ThemeMode get currentTheme => state ? ThemeMode.dark : ThemeMode.light;
}

// 전역 Provider
// ✅ StateNotifierProvider로 수정
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, bool>((ref) => ThemeNotifier());
