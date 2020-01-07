package load

import (
	"bytes"
	"io/ioutil"
	"os"
	"os/exec"

	"gido.vn/gic/databases/sqitch.git/src/gen-model/gen"
	"gido.vn/gic/databases/sqitch.git/src/utilities"
	"gido.vn/gic/libs/common.git/l"

	"gido.vn/gic/databases/sqitch.git/src/models"

	"gopkg.in/yaml.v2"

	"strings"
)

var (
	ll = l.New()
)

// Defination ...
func Defination(path string) {
	schemaDef := loadSchemaConfig(path)

	modelFileDir := schemaDef.Schemas["models"]
	genModelDestPath := schemaDef.Schemas["gen_models_destinations"]
	storeFileDir := schemaDef.Schemas["stores"]
	genStoreDesPath := schemaDef.Schemas["gen_stores_destinations"]
	modelFiles, err := ioutil.ReadDir(modelFileDir)
	utilities.HandlePanic(err, "Read dir models failed")

	if _, err := os.Stat(genModelDestPath); os.IsNotExist(err) {
		makeDirectory(genModelDestPath)
	}

	if _, err := os.Stat(genStoreDesPath); os.IsNotExist(err) {
		makeDirectory(genStoreDesPath)
	}

	notifyGenChan := make(chan int)
	numGeneratedFile := 0
	for _, modelFile := range modelFiles {
		fileName := modelFile.Name()
		go loadAndGen(modelFileDir+"/"+fileName, genModelDestPath, fileName, storeFileDir+"/"+fileName, genStoreDesPath, fileName, notifyGenChan)
	}

	for {
		select {
		case <-notifyGenChan:
			numGeneratedFile++
			if numGeneratedFile == len(modelFiles) {
				return
			}
		}
	}
}

func loadSchemaConfig(path string) *models.SchemaConfig {
	byteSchemaFile, err := ioutil.ReadFile(path)
	utilities.HandlePanic(err, "Read file schema config failed")

	schemaDefination := &models.SchemaConfig{}
	err = yaml.Unmarshal(byteSchemaFile, schemaDefination)

	return schemaDefination
}

func loadAndGen(modelPath string, genModelDesPath string, modelFileName string, storePath string, genStoreDesPath string, storeFileName string, notify chan int) {
	var modelFileNameWithoutSuffix string
	if strings.Contains(modelFileName, ".yaml") {
		modelFileNameWithoutSuffix = strings.ReplaceAll(modelFileName, ".yaml", "")
	} else if strings.Contains(modelFileName, ".yml") {
		modelFileNameWithoutSuffix = strings.ReplaceAll(modelFileName, ".yml", "")
	} else {
		return
	}

	modelDef := loadModelDefination(modelPath, genModelDesPath, modelFileName)
	gen.Model(modelDef, genModelDesPath, modelFileNameWithoutSuffix)

	var storeFileNameWithoutSuffix string
	if strings.Contains(modelFileName, ".yaml") {
		storeFileNameWithoutSuffix = strings.ReplaceAll(modelFileName, ".yaml", "")
	} else if strings.Contains(modelFileName, ".yml") {
		storeFileNameWithoutSuffix = strings.ReplaceAll(modelFileName, ".yml", "")
	} else {
		return
	}

	storeDef := loadModelDefination(modelPath, genStoreDesPath, storeFileName)
	gen.Store(storeDef, genStoreDesPath, storeFileNameWithoutSuffix)

	notify <- 1
}

func loadModelDefination(path string, genDesPath string, modelFileName string) *models.ModelDefination {
	ll.Print("File name: ", path)

	byteModelFileContent, err := ioutil.ReadFile(path)
	utilities.HandlePanic(err, "Read model config file failed")

	modelDefination := &models.ModelDefination{}
	err = yaml.Unmarshal(byteModelFileContent, modelDefination)
	utilities.HandlePanic(err, "Decoding model config file failed")

	modelDefHasKeyFieldType := mappingTypeOfKeyField(mappingIsUserFilterField(modelDefination))

	return modelDefHasKeyFieldType
}

func mappingTypeOfKeyField(modelDef *models.ModelDefination) *models.ModelDefination {
	newModelDefination := *modelDef
	for _, field := range modelDef.Fields {
		if field.Name == modelDef.Model.KeyField {
			newModelDefination.Model.KeyType = field.GoType
			break
		}
	}

	return &newModelDefination
}

func mappingIsUserFilterField(modelDef *models.ModelDefination) *models.ModelDefination {
	newModelDef := *modelDef
	for _, field := range modelDef.Fields {
		if field.Filter {
			newModelDef.Model.UserFilterField = field
			break
		}
	}

	return &newModelDef
}

func makeDirectory(path string) {
	cmd := exec.Command("mkdir", path)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	err := cmd.Run()
	errStr := string(stderr.Bytes())

	if err != nil {
		ll.Error("Error: make directory failed: " + path + " Error :::: " + errStr)
		ll.Panic("make directory failed", l.Error(err))
	}
}
