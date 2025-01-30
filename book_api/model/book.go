package model

// 책 구조체 정의
type Book struct {
	ID     int    `json:"id"`
	Title  string `json:"title"`
	Author string `json:"author"`
	Image  string `json:"image"`
}

func GetBooks() []Book {
	return []Book{
		{ID: 1, Title: "물고기는 존재하지 않는다", Author: "룰루 밀러", Image: "http://localhost:8080/img/book1.jpg"},
		{ID: 2, Title: "철학은 날씨를 바꾼다", Author: "서동욱", Image: "http://localhost:8080/img/book2.jpg"},
	}
}
