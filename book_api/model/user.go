package model

// 사용자 구조체
type User struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// 유저 저장소 (임시)
var Users = map[string]string{} // username -> password
