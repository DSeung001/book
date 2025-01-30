package auth

import (
	"book_api.com/model"
	"github.com/gin-gonic/gin"
	"net/http"
)

func Register(c *gin.Context) {
	var user model.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "잘못된 요청"})
		return
	}
	if _, exists := model.Users[user.Username]; exists {
		c.JSON(http.StatusConflict, gin.H{"error": "이미 존재하는 사용자"})
		return
	}
	model.Users[user.Username] = user.Password // 비밀번호 저장 (실제 서비스에서는 암호화 필요)
	c.JSON(http.StatusCreated, gin.H{"message": "회원가입 성공"})
}
