package core

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"
)

func Test_NewDirFileSystem_成功測試(t *testing.T) {
	fmt.Println("Test_NewDirFileSystem_成功測試")
	projectDirPath, err := getProjectDirPath()
	if err != nil {
		t.Errorf("getProjectDirPath error=%v", err)
	}

	tests := []struct {
		name string
		path string
	}{
		{
			name: "test1",
			path: projectDirPath + "/protoc-22.3-win64/bin",
		},
		{
			name: "test2",
			path: projectDirPath + "/pc",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := NewDirFileSystem(tt.path)
			if err != nil {
				t.Errorf("NewDirFileSystem出錯了 error=%v, data=%v", err, tt.path)
			}
		})
	}
}

func Test_NewDirFileSystem_報錯測試(t *testing.T) {
	fmt.Println("Test_NewDirFileSystem_報錯測試")
	projectDirPath, err := getProjectDirPath()
	if err != nil {
		t.Errorf("getProjectDirPath error=%v", err)
	}

	tests := []struct {
		name string
		path string
	}{
		{
			name: "test1",
			path: projectDirPath + "/protoc-22.3-win64aa",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := NewDirFileSystem(tt.path)
			if err == nil {
				t.Errorf("NewDirFileSystem應該丟error卻沒丟 data=%v", tt.path)
			}
		})
	}
}

func Test_DirFileSystem_Files_成功測試(t *testing.T) {
	fmt.Println("Test_DirFileSystem_Files_成功測試")
	projectDirPath, err := getProjectDirPath()
	if err != nil {
		t.Errorf("getProjectDirPath error=%v", err)
	}

	tests := []struct {
		name string
		path string
	}{
		{
			name: "test1",
			path: projectDirPath + "/protoc-22.3-win64",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			fs, err := NewDirFileSystem(tt.path)
			if err != nil {
				t.Errorf("NewDirFileSystem出錯了 error=%v, data=%v", err, tt.path)
			}
			fileChan := fs.Files()
			for {
				val, ok := <-fileChan
				if !ok { // 如果通道已經被關閉
					fmt.Println("Channel closed!")
					break
				}
				fmt.Println(val)
			}
		})
	}
	t.Errorf("a")
}

// 取得專案資料夾相對路徑
func getProjectDirPath() (string, error) {
	// 獲取當前工作目錄的路徑
	wd, err := os.Getwd()
	if err != nil {
		return "", fmt.Errorf("failed to get working directory: %v", err)
	}

	// 組合專案資料夾的路徑
	projDir := filepath.Join(wd, "..", "..")
	return projDir, nil
}
