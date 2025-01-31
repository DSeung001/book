package auth

import (
	"book_api.com/config"
	"book_api.com/model"
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v4"
)

// JWT 시크릿 키
var JwtKey = []byte("my_secret_key")

// JWT 토큰 생성 함수
func GenerateToken(username string) (string, error) {
	expirationTime := time.Now().Add(24 * time.Hour) // 24시간 유효
	claims := &jwt.StandardClaims{
		Subject:   username,
		ExpiresAt: expirationTime.Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(JwtKey)
}

// 로그인 API (JWT 발급)
func Login(c *gin.Context) {
	var user model.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "잘못된 요청"})
		return
	}

	ctx := context.Background()
	client, err := config.FirebaseApp.Firestore(ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Firestore 초기화 실패"})
		return
	}
	defer client.Close()

	// Firestore에서 사용자 조회
	doc, err := client.Collection("users").Doc(user.Username).Get(ctx)
	if err != nil || !doc.Exists() {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "아이디 또는 비밀번호가 틀렸습니다."})
		return
	}

	// Firestore에서 불러온 데이터 변환
	var storedUser model.User
	doc.DataTo(&storedUser)

	if storedUser.Password != user.Password {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "아이디 또는 비밀번호가 틀렸습니다."})
		return
	}

	// JWT 토큰 발급
	token, err := GenerateToken(user.Username)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "토큰 생성 실패"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}
