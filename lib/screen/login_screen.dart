import 'package:flutter/material.dart';
import '../service/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("소셜 로그인")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => authService.signInWithGoogle(),
              child: Text("Google 로그인"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => authService.signInWithKakao(),
              child: Text("Kakao 로그인"),
            ),
          ],
        ),
      ),
    );
  }
}