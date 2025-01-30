import 'package:flutter/material.dart';
import 'book_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
                leading: Image.network(
                    book.image, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(book.title),
                subtitle: Text(book.author),
              );
            },
          );
        },
      ),
    );
  }
}