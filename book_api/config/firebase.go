package config

import (
	"context"
	"fmt"
	"log"
	"os"

	firebase "firebase.google.com/go"

	"google.golang.org/api/option"
)

var FirebaseApp *firebase.App

func InitFirebase() {
	credPath := "config/service-account.json"

	// 파일 존재 여부 확인
	if _, err := os.Stat(credPath); os.IsNotExist(err) {
		log.Fatalf("Firebase 설정 오류: JSON 키 파일을 찾을 수 없습니다. (%s)", credPath)
	}

	// Firebase 앱 초기화
	opt := option.WithCredentialsFile(credPath)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("Firebase 초기화 실패: %v", err)
	}

	FirebaseApp = app
	fmt.Println("Firebase 초기화 성공!")
}
