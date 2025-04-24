import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';

import 'package:ourlife/theme/theme.dart';
import 'package:ourlife/router/app_router.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ourlife',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.currentTheme, // 현재 테마에 따라 다크모드 또는 라이트모드 적용
      initialRoute: '/', // 로그인 화면으로 연결
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

