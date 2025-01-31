import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController =
      TextEditingController(); // 이메일 추가

  Future<void> register() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameController.text,
        "password": passwordController.text,
        "email": emailController.text, // 이메일도 함께 전송
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입 성공! 로그인하세요.")),
      );

      // 회원가입 성공 후 로그인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      // 서버 응답에서 `error` 메시지 가져오기
      String errorMessage = "회원가입 실패!";
      try {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey("error")) {
          errorMessage = jsonResponse["error"]; // 서버에서 받은 `error` 메시지 표시
        }
      } catch (e) {
        print("JSON 파싱 오류: $e"); // JSON 파싱 오류 로그 출력
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)), // 받은 에러 메시지 표시
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("회원가입")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // 좌우 여백 추가
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // 가운데 정렬
            children: [
              Text(
                "회원가입",
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold), // 제목 스타일
              ),
              SizedBox(height: 20),

              // 아이디 입력 필드
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "아이디",
                  border: OutlineInputBorder(), // 테두리 추가
                  prefixIcon: Icon(Icons.person), // 아이콘 추가
                ),
              ),
              SizedBox(height: 12),

              // 이메일 입력 필드
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "이메일",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),

              // 비밀번호 입력 필드
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "비밀번호",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),

              // 회원가입 버튼
              SizedBox(
                width: double.infinity, // 버튼 크기 조정 (가로 꽉 차게)
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14), // 버튼 높이 조정
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 버튼 둥글게
                    ),
                  ),
                  child: Text("회원가입"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
