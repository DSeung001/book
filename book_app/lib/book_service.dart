import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_model.dart';

class BookService {
  static Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('http://localhost:8080/books'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => Book.fromJson(data)).toList();
    } else {
      throw Exception('책 데이터를 불러오는데 실패했습니다.');
    }
  }
}
