package main

import (
	"book_api.com/auth"
	"book_api.com/config"
	"book_api.com/model"
	"github.com/gin-gonic/gin"
	"net/http"
)

func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*") // 모든 도메인 허용
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// Preflight 요청 처리 (OPTIONS 요청 허용)
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusOK)
			return
		}

		c.Next()
	}
}

func main() {
	config.InitFirebase()

	r := gin.New()        // gin.Default() 대신 New() 사용 (Recovery를 직접 추가)
	r.Use(gin.Recovery()) // Panic 발생 시 로그 출력
	r.Use(CORSMiddleware())

	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Next()
	})

	// 정적 파일 제공 (img 폴더 내 이미지 제공)
	r.Static("/img", "./img")

	// 회원가입 & 로그인 API
	r.POST("/register", auth.Register)
	r.POST("/login", auth.Login)

	// 책 목록 API 엔드포인트
	r.GET("/books", func(c *gin.Context) {
		books := model.GetBooks()
		c.JSON(http.StatusOK, books)
	})

	r.Run(":8080") // 8080 포트에서 실행
}
