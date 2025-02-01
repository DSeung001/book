package model

import (
	"context"
	firebase "firebase.google.com/go"
	"fmt"
	"io"
	"mime/multipart"
	"os"
	"path/filepath"
	"time"
)

// 책 구조체 정의
type Book struct {
	ID        int       `json:"id"` // Firestore 사용 시에는 자동 생성된 Document ID를 활용할 수도 있습니다.
	Title     string    `json:"title" firestore:"title"`
	Author    string    `json:"author" firestore:"author"`
	Synopsis  string    `json:"synopsis" firestore:"synopsis"`   // 책 줄거리 추가
	ImageURL  string    `json:"image_url" firestore:"image_url"` // 이미지 URL (Firebase Storage 업로드 후 생성된 URL)
	CreatedAt time.Time `json:"created_at" firestore:"created_at"`
}

func GetBooks() []Book {
	return []Book{
		{
			ID:        1,
			Title:     "물고기는 존재하지 않는다",
			Author:    "룰루 밀러",
			Synopsis:  "이 책은 물고기를 통해 인생의 다양한 의미를 탐구합니다.",
			ImageURL:  "http://localhost:8080/img/book1.jpg",
			CreatedAt: time.Now(),
		},
		{
			ID:        2,
			Title:     "철학은 날씨를 바꾼다",
			Author:    "서동욱",
			Synopsis:  "철학적 사유와 일상의 변화를 다룬 작품입니다.",
			ImageURL:  "http://localhost:8080/img/book2.jpg",
			CreatedAt: time.Now(),
		},
	}
}

// AddBook 함수: 텍스트 데이터와 이미지 파일을 Firebase Storage와 Firestore에 저장
func AddBook(ctx context.Context, app *firebase.App, fileHeader *multipart.FileHeader, title, author, synopsis string) error {
	// 업로드된 파일 열기
	file, err := fileHeader.Open()
	if err != nil {
		return fmt.Errorf("failed to open file: %v", err)
	}
	defer file.Close()

	// 로컬 저장 경로 지정: 프로젝트 폴더 아래의 img 폴더
	localDir := "./img"
	// 디렉토리가 없으면 생성
	if err := os.MkdirAll(localDir, os.ModePerm); err != nil {
		return fmt.Errorf("failed to create directory %s: %v", localDir, err)
	}

	// 저장할 파일 경로 생성 (파일명을 그대로 사용)
	destPath := filepath.Join(localDir, fileHeader.Filename)
	dst, err := os.Create(destPath)
	if err != nil {
		return fmt.Errorf("failed to create file %s: %v", destPath, err)
	}
	defer dst.Close()

	// 업로드된 파일의 내용을 로컬 파일로 복사
	if _, err := io.Copy(dst, file); err != nil {
		return fmt.Errorf("failed to save file: %v", err)
	}

	// 클라이언트에서 접근할 수 있도록 이미지 URL 생성 (예: 정적 파일 서버가 /img 경로를 제공한다고 가정)
	imageURL := fmt.Sprintf("http://localhost:8080/img/%s", fileHeader.Filename)

	// 새 책 데이터를 생성 (이후 DB나 다른 저장소에 저장하는 로직으로 연결하면 됩니다)
	newBook := Book{
		Title:     title,
		Author:    author,
		Synopsis:  synopsis,
		ImageURL:  imageURL,
		CreatedAt: time.Now(),
	}

	// Firestore 클라이언트 가져오기
	fsClient, err := app.Firestore(ctx)
	if err != nil {
		return fmt.Errorf("failed to get firestore client: %v", err)
	}
	defer fsClient.Close()

	// "books" 컬렉션에 새 문서를 추가
	_, _, err = fsClient.Collection("books").Add(ctx, newBook)
	if err != nil {
		return fmt.Errorf("failed to add book record: %v", err)
	}

	// 추가 완료 후 로그 출력
	fmt.Printf("New book added to Firestore: %+v\n", newBook)

	return nil
}
