package handler

import (
	"book_api.com/config"
	"book_api.com/model"
	"context"
	"github.com/gin-gonic/gin"
	"net/http"
)

// AddBookHandler는 POST /books 요청을 처리하는 핸들러입니다.
func AddBookHandler(c *gin.Context) { // 텍스트 필드 값 읽기
	title := c.PostForm("title")
	author := c.PostForm("author")
	synopsis := c.PostForm("synopsis")

	// 폼 데이터에서 파일 읽기 ("image" 필드명)
	fileHeader, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "이미지 파일을 불러올 수 없습니다."})
		return
	}

	// 컨텍스트와 Firebase App 인스턴스 가져오기
	// 예: config 패키지에서 firebaseApp 변수를 제공한다고 가정합니다.
	ctx := context.Background()
	if err := model.AddBook(ctx, config.FirebaseApp, fileHeader, title, author, synopsis); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "책이 성공적으로 추가되었습니다."})
}
