
// class AppTheme {
//   static const Color darkBackground = Color(0xFF121212); // 어두운 배경색
//   static const Color lightBackground = Color(0xFFF5F3EB); // 부드러운 배경색
//   static const Color black = Colors.black;
//   static const Color white = Colors.white;
//   static const Color lightText = Colors.white;  // 밝은 텍스트 색상
//   static const Color darkText = Colors.black;   // 어두운 텍스트 색상

//   static final lightTheme = ThemeData(
//     brightness: Brightness.light,
//     fontFamily: 'NanumGothic',
//     primarySwatch: Colors.blue,
//     scaffoldBackgroundColor: Colors.white,
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black,
//     ),
//     textTheme: const TextTheme(
//       bodyMedium: TextStyle(color: Colors.black87),
//     ),
//   );

//   static final darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     fontFamily: 'NanumGothic',
//     primarySwatch: Colors.blue,
//     scaffoldBackgroundColor: const Color(0xFF121212),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Color(0xFF1F1F1F),
//       foregroundColor: Colors.white,
//     ),
//     textTheme: const TextTheme(
//       bodyMedium: TextStyle(color: Colors.white),
//       titleLarge: TextStyle(color: Colors.white),
//       bodyLarge: TextStyle(color: Colors.white70),
//     ),
//     inputDecorationTheme: const InputDecorationTheme(
//       labelStyle: TextStyle(color: Colors.white70),
//     ),
//     // **버튼 테마 추가**
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white.withAlpha(230),     // 버튼 배경을 밝게
//         foregroundColor: Colors.black,     // 텍스트는 검정으로
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     ),
//   );
// }


// theme/theme.dart
import 'package:flutter/material.dart';
import 'bootstrap_theme.dart';

class AppThemes {
  static final ThemeData light = lightTheme;
  static final ThemeData dark = darkTheme;
}
