import 'package:flutter/material.dart';
import 'screens/notes_home_screen.dart';
import 'screens/note_edit_screen.dart';

class NotesRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/notes':
        return MaterialPageRoute(builder: (_) => const NotesHomeScreen());
      case '/notes/edit':
        return MaterialPageRoute(builder: (_) => const NoteEditScreen());
      default:
        return null;
    }
  }
}