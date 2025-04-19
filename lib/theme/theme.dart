import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Colors.white;
  static const Color primaryText = Colors.black;
  static const Color secondaryText = Colors.black54;
  static const Color buttonColor = Colors.black;
  static const Color cardColor = Colors.white;
  static const Color borderColor = Colors.grey;

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: primaryText,
      elevation: 1,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
      iconTheme: IconThemeData(color: primaryText),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: primaryText),
      bodyMedium: TextStyle(color: primaryText),
      titleLarge: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      labelStyle: const TextStyle(color: primaryText),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: primaryText, width: 2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: background,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardColor: cardColor,
    iconTheme: const IconThemeData(color: primaryText),
    primaryColor: buttonColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: secondaryText),
  );
}
