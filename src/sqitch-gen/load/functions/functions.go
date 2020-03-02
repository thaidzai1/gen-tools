package funcs

import (
	"io/ioutil"

	"gido.vn/gic/databases/sqitch.git/src/models"
	"gido.vn/gic/databases/sqitch.git/src/utilities"
	"gopkg.in/yaml.v2"
)

// Load ...
func Load(funcPath string, restrictedPath string, functionGenContent chan string) {
	generatedFuncDef := loadGeneratedFuncFiles(restrictedPath)

	allFunctionFiles, err := ioutil.ReadDir(funcPath)
	utilities.HandlePanic(err, "Read all function files failed")

	var byteContentFuncs []byte

	for _, file := range allFunctionFiles {
		isGenerated := false
		for _, generatedFunc := range generatedFuncDef.FileName {
			if file.Name() == generatedFunc {
				isGenerated = true
			}
		}
		if !isGenerated {
			byteContentFuncs = append(byteContentFuncs, loadNeedToBeGeneratedFuncFile(funcPath+"/"+file.Name())...)
		}
	}

	functionGenContent <- string(byteContentFuncs)
}

func loadGeneratedFuncFiles(path string) *models.GeneratedFunctions {
	byteContent, err := ioutil.ReadFile(path)
	utilities.HandlePanic(err, "Load file generated functions failed")

	generatedFuncFile := &models.GeneratedFunctions{}
	err = yaml.Unmarshal(byteContent, generatedFuncFile)
	utilities.HandlePanic(err, "Decoding generated funcs failed")

	return generatedFuncFile
}

func loadNeedToBeGeneratedFuncFile(path string) []byte {
	byteContent, err := ioutil.ReadFile(path)
	utilities.HandlePanic(err, "Load function file need to be generated failed")

	return byteContent
}
