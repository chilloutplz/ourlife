// lib/router/app_router.dart
import 'package:flutter/material.dart';
import '../features/accounts/accounts_router.dart';
import '../features/bible/bible_router.dart';
import '../features/notes/notes_router.dart';
import '../home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Accounts 라우터 처리
    final accountsRoute = AccountsRouter.generateRoute(settings);
    if (accountsRoute != null) return accountsRoute;

    // Bible 라우터 처리
    final bibleRoute = BibleRouter.generateRoute(settings);
    if (bibleRoute != null) return bibleRoute;

    // Notes 라우터 처리
    final notesRoute = NotesRouter.generateRoute(settings);
    if (notesRoute != null) return notesRoute;

    // /home 라우트 처리 추가
    if (settings.name == '/home') {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    }

    // 처리되지 않은 라우트
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
