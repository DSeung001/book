package auth

import (
	"book_api.com/config"
	"book_api.com/model"
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func Register(c *gin.Context) {
	var user model.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "잘못된 요청 데이터", "details": err.Error()})
		return
	}

	ctx := context.Background()
	client, err := config.FirebaseApp.Firestore(ctx)
	if err != nil {
		fmt.Println("Firestore 클라이언트 생성 실패:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Firestore 연결 실패"})
		return
	}
	defer client.Close()

	// Firestore에서 문서 존재 여부 확인
	docRef := client.Collection("users").Doc(user.Username)
	doc, err := docRef.Get(ctx)

	// 수정된 부분: 문서가 없는 경우 회원가입 진행
	if err != nil {
		// 문서가 없으므로 새로 생성
		fmt.Println("Firestore: 문서가 없으므로 새로 생성")
		user.CreatedAt = time.Now().Unix()
		_, err = docRef.Set(ctx, user)
		if err != nil {
			fmt.Println("Firestore 저장 실패:", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Firestore 저장 실패"})
			return
		}
		fmt.Println("회원가입 성공:", user.Username)
		c.JSON(http.StatusCreated, gin.H{"message": "회원가입 성공"})
		return

	}

	if doc.Exists() {
		c.JSON(http.StatusConflict, gin.H{"error": "이미 존재하는 사용자"})
		return
	}
}
