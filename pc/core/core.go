package core

import (
	"fmt"
	"os"
	"path/filepath"
)

type DirFileSystem struct {
	DirPath string
}

// 取得所有檔案
func (x *DirFileSystem) Files() <-chan string {
	ch := make(chan string, 10)
	go func() {
		err := filepath.Walk(x.DirPath, func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if !info.IsDir() {
				relPath, err := filepath.Rel(x.DirPath, path)
				if err != nil {
					return err
				}
				relPath = filepath.ToSlash(relPath)
				ch <- relPath
			}
			return nil
		})
		if err != nil {
			fmt.Println(err)
		}
		close(ch)
	}()
	return ch
}

// 建立檔案系統
func NewDirFileSystem(path string) (fs *DirFileSystem, err error) {
	suc, err := checkPathDirExist(path)
	if suc {
		fs = &DirFileSystem{path}
	}
	return fs, err
}

// 檢查路徑存在且是資料夾
func checkPathDirExist(path string) (suc bool, err error) {
	fileInfo, err := os.Stat(path)
	if err != nil {
		err = fmt.Errorf("無法取得路徑 %s 的檔案資訊： %v\n", path, err)
		return false, err
	}

	if fileInfo.IsDir() {
		fmt.Printf("%s 是一個資料夾\n", path)
		return true, err
	} else {
		err = fmt.Errorf("%s 不是一個資料夾\n", path)
		return false, err
	}
}
