import 'package:flutter/material.dart';
import '../service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    authService.initializePlatforms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 크림색 배경
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.black, // 배경 색상을 블랙으로 설정
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "로그인",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              _buildSocialButton(
                "Google 로그인",
                Icons.login,
                Colors.white,
                () => authService.signInWithGoogle(),
              ),
              SizedBox(height: 15),
              _buildSocialButton(
                "Kakao 로그인",
                Icons.chat,
                Colors.white,
                () => authService.signInWithKakao(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      label: Text(text, style: TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // 크림색 버튼
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
    );
  }
}
