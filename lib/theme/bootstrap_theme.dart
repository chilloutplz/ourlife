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

// 기본 카드 테마
final CardTheme defaultCardTheme = CardTheme(
  color: BootstrapColors.white,
  elevation: 3,
  margin: const EdgeInsets.all(8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: BootstrapColors.gray, width: 1),
  ),
);

// 테두리만 있는 카드 테마
final CardTheme outlinedCardTheme = CardTheme(
  color: BootstrapColors.transparent,
  elevation: 0,
  margin: const EdgeInsets.all(8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: BootstrapColors.primary, width: 1.5),
  ),
);

// 성공 카드 테마
final CardTheme successCardTheme = CardTheme(
  color: BootstrapColors.success.withAlpha(25), // 변경된 부분
  elevation: 2,
  margin: const EdgeInsets.all(8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: BootstrapColors.success, width: 1.5),
  ),
);

// 경고 카드 테마
final CardTheme warningCardTheme = CardTheme(
  color: BootstrapColors.warning.withAlpha(25), // 변경된 부분
  elevation: 2,
  margin: const EdgeInsets.all(8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: BootstrapColors.warning, width: 1.5),
  ),
);

// 위험 카드 테마
final CardTheme dangerCardTheme = CardTheme(
  color: BootstrapColors.danger.withAlpha(25), // 변경된 부분
  elevation: 2,
  margin: const EdgeInsets.all(8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: BootstrapColors.danger, width: 1.5),
  ),
);

// 정보 카드 테마
final CardTheme infoCardTheme = CardTheme(
  color: BootstrapColors.info.withAlpha(25), // 변경된 부분
  elevation: 2,
  margin: const EdgeInsets.all(8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: BootstrapColors.info, width: 1.5),
  ),
);

// 어두운 카드 테마
final CardTheme darkCardTheme = CardTheme(
  color: BootstrapColors.dark,
  elevation: 3,
  margin: const EdgeInsets.all(8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: BootstrapColors.grayDark, width: 1.5),
  ),
);

// 밝은 카드 테마
final CardTheme lightCardTheme = CardTheme(
  color: BootstrapColors.light,
  elevation: 3,
  margin: const EdgeInsets.all(8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: BootstrapColors.gray, width: 1.5),
  ),
);