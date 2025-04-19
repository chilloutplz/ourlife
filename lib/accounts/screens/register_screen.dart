import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ourlife/constants/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();

  final _usernameFocus = FocusNode();

  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usernameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final mobile = _mobileController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || mobile.isEmpty) {
      setState(() => _error = '모든 필드를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final url = Uri.parse(ApiConstants.register);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'mobile': mobile,
      }),
    );

    if (response.statusCode == 201) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ 회원가입이 완료되었습니다!")),
      );
      Navigator.pop(context);
    } else {
      String errorMessage = '회원가입에 실패했습니다.';
      try {
        final errors = jsonDecode(response.body);
        errorMessage = '';
        errors.forEach((key, value) {
          errorMessage += '$key: ${value.join(', ')}\n';
        });
      } catch (_) {}
      setState(() => _error = errorMessage.trim());
    }

    setState(() => _isLoading = false);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black26),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Text(
              'OurLife에 오신 것을 환영합니다',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '계정을 만들어 시작해보세요',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _usernameController,
              focusNode: _usernameFocus,
              decoration: _inputDecoration('아이디'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              decoration: _inputDecoration('이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _mobileController,
              decoration: _inputDecoration('휴대폰 번호'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: _inputDecoration('비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            if (_error.isNotEmpty)
              Text(
                _error,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('회원가입'),
              ),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('이미 계정이 있으신가요? 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
