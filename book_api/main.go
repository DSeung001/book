package main

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

// 책 구조체 정의
type Book struct {
	ID     int    `json:"id"`
	Title  string `json:"title"`
	Author string `json:"author"`
	Image  string `json:"image"`
}

// 샘플 데이터
var books = []Book{
	{ID: 1, Title: "Go 프로그래밍", Author: "김고랭", Image: "https://example.com/book1.jpg"},
	{ID: 2, Title: "Flutter 시작하기", Author: "박플러터", Image: "https://example.com/book2.jpg"},
}

func main() {
	r := gin.Default()

	// 책 목록 API 엔드포인트
	r.GET("/books", func(c *gin.Context) {
		c.JSON(http.StatusOK, books)
	})

	r.Run(":8080") // 8080 포트에서 실행
}
