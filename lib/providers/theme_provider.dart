import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final index = prefs.getInt('theme_mode') ?? ThemeMode.dark.index; // 기본값을 ThemeMode.dark로 설정
  return ThemeMode.values[index];
});

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(ThemeMode.dark), // 초기값을 ThemeMode.dark로 설정
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(super.initialMode);

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = (state == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    await prefs.setInt('theme_mode', state.index);
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    state = mode;
    await prefs.setInt('theme_mode', state.index);
  }
}
