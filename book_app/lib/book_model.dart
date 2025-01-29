class Book {
  final int id;
  final String title;
  final String author;
  final String image;

  Book({required this.id, required this.title, required this.author, required this.image});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      image: json['image'],
    );
  }
}
