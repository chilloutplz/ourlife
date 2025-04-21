import 'package:flutter/material.dart';
import '../home_screen.dart';
import 'package:ourlife/features/accounts/screens/login_screen.dart';
import 'package:ourlife/features/accounts/screens/register_screen.dart';
import 'package:ourlife/features/bible/screens/bible_home_screen.dart';
import 'package:ourlife/features/bible/screens/book_list_screen.dart';
import 'package:ourlife/features/bible/screens/chapter_list_screen.dart';
import 'package:ourlife/features/bible/screens/verse_list_screen.dart';
import 'package:ourlife/features/bible/screens/verse_search_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/bible':
        return MaterialPageRoute(builder: (_) => const BibleHomeScreen());
      case '/bible/books':
        final version = args as String;
        return MaterialPageRoute(
          builder: (_) => BookListScreen(version: version),
        );
      case '/bible/chapters':
        final map = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChapterListScreen(
            version: map['version'], book: map['book']),
        );
      case '/bible/verses':
        final map = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VerseListScreen(
            version: map['version'],
            book: map['book'],
            chapter: map['chapter'],
          ),
        );
      case '/bible/search':
        return MaterialPageRoute(builder: (_) => const VerseSearchScreen());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
