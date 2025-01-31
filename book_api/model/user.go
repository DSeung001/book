package model

type User struct {
	Username  string `json:"username"`
	Password  string `json:"password"` // 실제 서비스에서는 해싱해야 함
	Email     string `json:"email"`
	CreatedAt int64  `json:"created_at"`
}

// 유저 저장소 (임시)
var Users = map[string]string{} // username -> password
