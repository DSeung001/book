import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'add_book_screen.dart';

// const domain = "localhost";
const domain = "localhost";

// 비동기 데이터이므로 StatefulWidget을 사용
class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late Future<List<Book>> _books;

  @override
  void initState() {
    super.initState();
    _books = fetchBooks();
  }

  // Future는 비동기 함수를 의미하고, 비동기로 가져온 값을 List<Book>으로 반환
  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('http://$domain:8080/books'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => Book.fromJson(data)).toList();
    } else {
      throw Exception('책 데이터를 불러오는데 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("책 리스트")),
      body: FutureBuilder<List<Book>>(
        future: _books,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("오류 발생: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("책 데이터가 없습니다."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final book = snapshot.data![index];
              return ListTile(
                leading: book.image_url != null && book.image_url!.isNotEmpty
                    ? Image.network(
                  book.image_url!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey,
                  child: Icon(Icons.image),
                ),
                title: Text(book.title),
                subtitle: Text(book.author),
              );
            },
          );
        },
      ),
      // 글쓰기 플로팅 버튼 추가
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookScreen()),
          );
        },
        child: Icon(Icons.edit), // 글쓰기 혹은 편집 아이콘 사용
      ),
    );
  }
}
