// our
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ourlife/providers/theme_provider.dart';
import 'package:ourlife/widgets/home/home_body.dart';

/// 홈 화면 (앱의 메인 화면)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime? _lastBackPressed; // 마지막 뒤로가기 버튼 눌린 시간

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로가기 기본 동작 막기
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();
        // 뒤로가기 두 번 눌러야 종료되도록 설정 (2초 이내)
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          // 안내 스낵바 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '한번 더 누르면 앱이 종료됩니다',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.grey.shade900.withAlpha(230),
            ),
          );
          return;
        }
        // 앱 종료
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('OurLife'),
          actions: [
            // 테마 전환 버튼 (라이트/다크 모드)
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: () {
                ref.read(themeNotifierProvider.notifier).toggleTheme(); // ✅ Riverpod 사용
              },
            ),
          ],
        ),
        // 홈 바디 영역
        body: const HomeBody(),
      ),
    );
  }
}