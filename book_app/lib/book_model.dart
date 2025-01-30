class Book {
  final int id;
  final String title;
  final String author;
  final String image;

  Book(
      {required this.id,
      required this.title,
      required this.author,
      required this.image});

  // Json 데이터를 받아서 Book 객체로변환
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      image: json['image'],
    );
  }
}
