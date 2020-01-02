package load

import (
	"io/ioutil"

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
func Defination(path string, modelDefChan chan *models.ModelDefination, quit chan bool) {
	schemaDef := loadSchemaConfig(path)

	modelFileDir := schemaDef.Schemas["models"]
	modelFiles, err := ioutil.ReadDir(modelFileDir)
	utilities.HandlePanic(err, "Read dir models failed")

	for _, modelFile := range modelFiles {
		go loadModelDefination(modelFileDir+"/"+modelFile.Name(), modelDefChan)
	}
	ll.Info("After loop")
	// quit <- 0
	// quit <- 0
	countDown := len(modelFiles)
	for {
		select {
		case data := <-modelDefChan:
			countDown--
			ll.Print("data: ", countDown)
			if countDown == 0 {
				ll.Info("hello ---")
				quit <- true
				// ll.Print("datax: ", <-quit)
				ll.Info("hello")
				return
			}
			quit <- true
			modelDefChan <- data
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

func loadModelDefination(path string, modelDefChan chan *models.ModelDefination) {
	ll.Print("File name: ", path)

	if !(strings.Contains(path, ".yml") || strings.Contains(path, ".yaml")) {
		return
	}

	byteModelFileContent, err := ioutil.ReadFile(path)
	utilities.HandlePanic(err, "Read model config file failed")

	modelDefination := &models.ModelDefination{}
	err = yaml.Unmarshal(byteModelFileContent, modelDefination)
	utilities.HandlePanic(err, "Decoding model config file failed")

	modelDefChan <- modelDefination
}
