import 'package:flutter/material.dart';
import 'package:ourlife/theme/theme.dart';
import 'package:ourlife/router/app_router.dart';


void main() async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ourlife',
      theme: AppTheme.lightTheme,
      initialRoute: '/', // 로그인 화면으로 연결
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

