import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/theme_provider.dart';
import 'theme/theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null); // 한글 날짜 포맷 초기화

  runApp(
    const ProviderScope(
      child: ThemeInitializer(),
    ),
  );
}

class ThemeInitializer extends ConsumerWidget {
  const ThemeInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTheme = ref.watch(themeModeProvider); // FutureProvider

    return asyncTheme.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('테마 로딩 실패: $e'))),
      ),
      data: (themeMode) {
        final override = themeNotifierProvider.overrideWith(
          (ref) => ThemeNotifier(themeMode),
        );
        return ProviderScope(
          overrides: [override],
          child: const MyApp(),
        );
      },
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider); // override된 provider 사용

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OurLife',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeMode,
      initialRoute: '/home',
      onGenerateRoute: AppRouter.generateRoute,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'), // 한국어
        Locale('en'), // 영어
      ],
    );
  }
}
