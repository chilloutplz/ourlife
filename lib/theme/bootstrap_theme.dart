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
  static const navyBlue = Color(0xFF000080);

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
    color: Color(0xFF2C2F33),
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
