import 'dart:io';
import 'package:book_app/screen/book_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

const domain = "localhost";

class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController synopsisController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // 이미지 선택 함수: 갤러리에서 이미지 파일을 선택
  Future<void> pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // 책 추가 함수: 제목, 저자, 줄거리와 선택한 이미지를 multipart request로 전송
  Future<void> addBook() async {
    final title = titleController.text;
    final author = authorController.text;
    final synopsis = synopsisController.text;

    var uri = Uri.parse('http://$domain:8080/books');
    var request = http.MultipartRequest('POST', uri);

    // 텍스트 필드 값들을 fields에 추가
    request.fields['title'] = title;
    request.fields['author'] = author;
    request.fields['synopsis'] = synopsis;

    // 이미지 파일이 선택되었다면, multipart 파일로 추가
    if (_imageFile != null) {
      var stream = http.ByteStream(_imageFile!.openRead());
      stream.cast();
      var length = await _imageFile!.length();
      var multipartFile = http.MultipartFile(
        'image', // 서버에서 처리할 이미지 필드명
        stream,
        length,
        filename: _imageFile!.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    // 요청 전송
    var response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("책이 추가되었습니다.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("책 추가 실패: ${response.statusCode}")),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    synopsisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("책 추가"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "책 제목"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: authorController,
              decoration: InputDecoration(labelText: "저자"),
            ),
            SizedBox(height: 16),
            // 책 줄거리를 입력할 수 있는 텍스트 필드 추가
            TextField(
              controller: synopsisController,
              decoration: InputDecoration(labelText: "책 줄거리"),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            // 이미지 선택 미리보기 영역
            _imageFile != null
                ? Image.file(
              _imageFile!,
              height: 150,
            )
                : Container(
              height: 150,
              color: Colors.grey[300],
              child: Center(child: Text("이미지가 선택되지 않음")),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: pickImage,
              child: Text("이미지 선택"),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: addBook,
              child: Text("책 추가하기"),
            ),
          ],
        ),
      ),
    );
  }
}
