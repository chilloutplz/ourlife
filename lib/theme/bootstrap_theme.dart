// lib/theme/bootstrap_theme.dart
import 'package:flutter/material.dart';

class BootstrapColors {
  static const primary = Color(0xFF0D6EFD);
  static const secondary = Color(0xFF6C757D);
  static const success = Color(0xFF198754);
  static const danger = Color(0xFFDC3545);
  static const warning = Color(0xFFFFC107);
  static const info = Color(0xFF0DCAF0);
  static const light = Color(0xFFF8F9FA);
  static const dark = Color(0xFF212529);
  static const muted = Color(0xFF6C757D); // Bootstrap의 muted 색상 추가
  static const white = Color(0xFFFFFFFF); // 흰색 추가
  static const transparent = Colors.transparent; // 투명색 추가

  // 추가적인 색상 (선택 사항)
  static const blue = Color(0xFF007BFF);
  static const indigo = Color(0xFF6610F2);
  static const purple = Color(0xFF6F42C1);
  static const pink = Color(0xFFD63384);
  static const orange = Color(0xFFFD7E14);
  static const yellow = Color(0xFFFFEB3B);
  static const green = Color(0xFF28A745);
  static const teal = Color(0xFF20C997);
  static const cyan = Color(0xFF17A2B8);
  static const gray = Color(0xFF868E96);
  static const grayDark = Color(0xFF343A40);

}

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: BootstrapColors.primary,
    secondary: BootstrapColors.secondary,
    surface: Colors.white,
    error: BootstrapColors.danger,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onError: Colors.white,
  ),
  cardTheme: const CardTheme(
    color: Colors.white,
    elevation: 3,
    margin: EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: BootstrapColors.primary,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: BootstrapColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: BootstrapColors.primary,
    secondary: BootstrapColors.secondary,
    surface: BootstrapColors.dark,
    error: BootstrapColors.danger,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
  ),
  cardTheme: const CardTheme(
    color: Color(0xFF2C3E50),
    elevation: 6,
    margin: EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: BootstrapColors.primary,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: BootstrapColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);
