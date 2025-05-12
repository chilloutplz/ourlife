import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'bootstrap_theme.dart';

class MarkdownStyles {
  static MarkdownStyleSheet get defaultStyle => MarkdownStyleSheet(
        h2: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
        listBullet: const TextStyle(
          fontSize: 18,
          color: Colors.green,
        ),
        p: const TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: BootstrapColors.info,
        ),
        strong: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      );
}