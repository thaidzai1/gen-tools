package gen

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"gicprime.com/sqitch/common/l"
)

var (
	projectPath string
	gopath      string

	ll = l.New()
)

func init() {
	p := os.Getenv("GOPATH")
	ps := filepath.SplitList(p)
	if len(ps) == 0 {
		ll.Panic("Empty GOPATH")
	}

	var err error
	gopath, err = filepath.Abs(ps[0])
	if err != nil {
		ll.Panic("Invalid GOPATH", l.Error(err))
	}

	projectPath = filepath.Join(gopath, "src/gicprime.com/sqitch")
}

// ProjectPath ...
func ProjectPath() string {
	return projectPath
}

// GOPATH ...
func GOPATH() string {
	return gopath
}

// WriteFile ...
func WriteFile(outputPath string, data []byte) {
	absPath := GetAbsPath(outputPath)
	err := ioutil.WriteFile(absPath, data, os.ModePerm)
	if err != nil {
		fmt.Printf("Unable to write file `%v`.\n  Error: %v\n", absPath, err)
		os.Exit(1)
	}
	fmt.Println("Generated file:", absPath)

	FormatFile(outputPath)
}

// FormatFile ...
func FormatFile(outputPath string) {
	absPath := GetAbsPath(outputPath)
	out, err := exec.Command("goimports", "-w", absPath).Output()
	if err != nil {
		fmt.Printf("Unable to run `gofmt -w %v`.\n  Error: %v\n", absPath, err)
		os.Exit(1)
	}
	fmt.Print(string(out))
}

// GetAbsPath ...
func GetAbsPath(inputPath string) string {
	if strings.HasPrefix(inputPath, "/") {
		return inputPath
	}
	return filepath.Join(projectPath, inputPath)
}

// NoError ...
func NoError(err error, msg string, args ...interface{}) {
	if err != nil {
		fmt.Printf(msg, args...)
		fmt.Printf("\n  Error: %v\n", err)
		os.Exit(1)
	}
}
