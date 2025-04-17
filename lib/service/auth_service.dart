import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late String platforms; // Declare a late variable for platforms

  // Initialize the platforms variable
  void initializePlatforms() {
    platforms = "Supported platforms: Google, Kakao";
    debugPrint(platforms); // Optional: Debugging to confirm initialization
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // 로그인 취소 시 처리

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Django REST API에 Google 액세스 토큰 전달
    final response = await http.post(
      Uri.parse(
        'https://port-0-unclebob-api-m9hwt2ohea8935ae.sel4.cloudtype.app/accounts/google/login/',
      ),
      body: {'access_token': googleAuth.accessToken},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      debugPrint("Google 로그인 성공: ${data['message']}");
    } else {
      debugPrint("Google 로그인 실패: ${response.body}");
    }
  }

  Future<void> signInWithKakao() async {
    bool isInstalled = await isKakaoTalkInstalled();
    OAuthToken token;

    if (isInstalled) {
      token = await UserApi.instance.loginWithKakaoTalk();
    } else {
      token = await UserApi.instance.loginWithKakaoAccount();
    }

    // Django REST API에 Kakao 액세스 토큰 전달
    final response = await http.post(
      Uri.parse(
        'https://port-0-unclebob-api-m9hwt2ohea8935ae.sel4.cloudtype.app/accounts/kakao/login/',
      ),
      body: {'access_token': token.accessToken},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      debugPrint("Kakao 로그인 성공: ${data['message']}");
    } else {
      debugPrint("Kakao 로그인 실패: ${response.body}");
    }
  }
}
