class Book {
  final int id;
  final String title;
  final String author;
  final String synopsis;
  final String image_url;
  final String created_at;

  Book(
      {required this.id,
      required this.title,
      required this.author,
      required this.synopsis,
      required this.image_url,
      required this.created_at});

  // Json 데이터를 받아서 Book 객체로변환
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      synopsis: json['synopsis'],
      image_url: json['image_url'],
      created_at: json['created_at'],
    );
  }
}
