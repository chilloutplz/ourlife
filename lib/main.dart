import 'package:flutter/material.dart';
import 'screen/login_screen.dart'; // 로그인 화면 파일을 임포트

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // 로그인 화면으로 연결
    );
  }
}