package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"

	"kiwislice/remotefilesync/core"
	grpcserver "kiwislice/remotefilesync/grpcserver"
	httpserver "kiwislice/remotefilesync/httpserver"
)

var (
	dirPath string
)

// 設定要從 command line 讀取的參數
// 這邊所設定的會在 -h 或者輸入錯誤時出現提示哦！
func init() {
	curDir, _ := filepath.Split(os.Args[0])

	flag.StringVar(&dirPath, "dir", curDir, "資料夾路徑")
	flag.Usage = usage
}

func usage() {
	doc := `
遠端檔案同步PC端

remotefilesync.exe [<args>]
	`
	fmt.Println(doc)
	flag.PrintDefaults()
}

func main() {
	flag.Parse()

	dirFs, err := core.NewDirFileSystem(dirPath)
	if err != nil {
		fmt.Println(err)
		return
	}

	fmt.Printf("開放資料夾: %v\n", dirPath)

	go grpcserver.Run(dirFs)
	httpserver.Run(dirFs)

}
