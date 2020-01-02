package main

import (
	"flag"
	"fmt"

	"gido.vn/gic/databases/sqitch.git/src/gen-model/load"
	"gido.vn/gic/databases/sqitch.git/src/models"
	"gido.vn/gic/libs/common.git/l"
)

var (
	ll               = l.New()
	flConfigFilePath = flag.String("schema", "", "Path to schema configuration")
)

func main() {
	flag.Parse()

	if *flConfigFilePath == "" {
		ll.Panic("schema file path is required, use '-schema' to import schema file")
	}
	modelDefChan := make(chan *models.ModelDefination)
	quitLoadModel := make(chan bool)
	go load.Defination(*flConfigFilePath, modelDefChan, quitLoadModel)
	quitLoadModel <- true
	for {
		select {
		// case modelDef := <-modelDefChan:
		// 	genModel(modelDef)
		case t := <-quitLoadModel:
			if t {
				fmt.Println("abc")
			} else {
				fmt.Println("false")
			}
			return
		}
	}

}

func genModel(modelDef *models.ModelDefination) {
	ll.Print("model", modelDef)
}
