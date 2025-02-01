import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'book_list_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    // 위젯의 초기 상태 설정, 생성자와 다름
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BookListScreen()),
            (route) => false,
      );
    }
  }

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameController.text,
        "password": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      String token = jsonResponse["token"];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 성공!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BookListScreen()),
            (route) => false, // 모든 이전 라우트를 제거합니다.
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 실패! 아이디 또는 비밀번호를 확인하세요.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("로그인")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // 좌우 여백 추가
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // 가운데 정렬
            children: [
              Text(
                "로그인",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // 제목 스타일
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

              // 로그인 버튼
              SizedBox(
                width: double.infinity, // 버튼 크기 조정 (가로 꽉 차게)
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14), // 버튼 높이 조정
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 버튼 둥글게
                    ),
                  ),
                  child: Text("로그인"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
