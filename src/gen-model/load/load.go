package load

import (
	"io/ioutil"

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
	genDestPath := schemaDef.Schemas["gen_models_destinations"]
	modelFiles, err := ioutil.ReadDir(modelFileDir)
	utilities.HandlePanic(err, "Read dir models failed")

	notifyGenChan := make(chan int)
	numGeneratedFile := 0
	for _, modelFile := range modelFiles {
		go loadModelDefination(modelFileDir+"/"+modelFile.Name(), genDestPath, modelFile.Name(), notifyGenChan)
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

func loadModelDefination(path string, genDesPath string, modelFileName string, notify chan int) {
	ll.Print("File name: ", path)

	var fileNameWithoutSuffix string
	if strings.Contains(modelFileName, ".yaml") {
		fileNameWithoutSuffix = strings.ReplaceAll(modelFileName, ".yaml", "")
	} else if strings.Contains(modelFileName, ".yml") {
		fileNameWithoutSuffix = strings.ReplaceAll(modelFileName, ".yml", "")
	} else {
		return
	}

	byteModelFileContent, err := ioutil.ReadFile(path)
	utilities.HandlePanic(err, "Read model config file failed")

	modelDefination := &models.ModelDefination{}
	err = yaml.Unmarshal(byteModelFileContent, modelDefination)
	utilities.HandlePanic(err, "Decoding model config file failed")

	modelDefHasFieldType := mappingTypeOfKeyField(modelDefination)

	gen.Model(modelDefHasFieldType, genDesPath, fileNameWithoutSuffix)
	notify <- 1
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
