package load

import (
	"fmt"
	"io/ioutil"
	"strings"

	"gicprime.com/sqitch/common/gen"
	"gicprime.com/sqitch/common/l"
	"gopkg.in/yaml.v2"
)

var (
	ll = l.New()
)

// LoadSchemaDefination ...
func LoadSchemaDefination(inputPath string) *[]TableDefination {
	data, err := ioutil.ReadFile(gen.GetAbsPath(inputPath))
	fmt.Printf("data: %v\n", data)
	NoError(err)

	var dbSchema DBSchema
	err = yaml.Unmarshal(data, &dbSchema)
	NoError(err)
	fmt.Printf("dbSchema: %v\n", dbSchema)

	var tableDefs []TableDefination

	for pName, schemaPath := range dbSchema.Schemas {
		fmt.Printf("pName: %v, schema: %v \n", pName, schemaPath)
		absPath := gen.GetAbsPath(schemaPath)
		files, err := ioutil.ReadDir(absPath)
		NoError(err)

		fmt.Printf("file in schema: %v\n", files)
		for _, file := range files {
			ll.Print("file: ", file.Name())
			if !(strings.HasSuffix(file.Name(), ".yml") || strings.HasSuffix(file.Name(), ".yaml")) {
				continue
			}

			data, err := ioutil.ReadFile(gen.GetAbsPath(schemaPath + "/" + file.Name()))
			NoError(err)
			ll.Print("data: ", data)
			var tableDef TableDefination
			err = yaml.Unmarshal(data, &tableDef)

			lengthWithouSuffix := strings.Index(file.Name(), ".")
			tableDef.TableName = file.Name()[:lengthWithouSuffix]

			fmt.Printf("data yml: %v\n", tableDef.Fields)
			tableDefs = append(tableDefs, tableDef)
		}
	}
	return &tableDefs
}

func NoError(err error) {
	if err != nil {
		panic(err)
	}
}
