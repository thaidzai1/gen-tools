package load

import (
	"io/ioutil"
	"strings"

	"gido.vn/gic/libs/common.git/gen"
	"gido.vn/gic/libs/common.git/l"
	"gopkg.in/yaml.v2"
)

var (
	ll = l.New()
)

// LoadSchemaDefination ...
func LoadSchemaDefination(inputPath string, planName string) *MigrateSchema {
	data, err := ioutil.ReadFile(gen.GetAbsPath(inputPath))
	NoError(err)

	var dbSchema DBSchema
	err = yaml.Unmarshal(data, &dbSchema)
	NoError(err)

	var tableDefs []TableDefination
	var triggers string

	for schemaKey, schemaPath := range dbSchema.Schemas {

		absPath := gen.GetAbsPath(schemaPath)
		files, err := ioutil.ReadDir(absPath)
		NoError(err)
		schemaTableText := "tables"
		schemaFuncText := "functions"
		if schemaKey == schemaTableText {
			for _, file := range files {
				ll.Print("file: ", file.Name())
				if !(strings.HasSuffix(file.Name(), ".yml") || strings.HasSuffix(file.Name(), ".yaml")) {
					continue
				}

				data, err := ioutil.ReadFile(gen.GetAbsPath(schemaPath + "/" + file.Name()))
				NoError(err)
				var tableDef TableDefination
				err = yaml.Unmarshal(data, &tableDef)

				lengthWithouSuffix := strings.Index(file.Name(), ".")
				tableDef.TableName = file.Name()[:lengthWithouSuffix]
				tableDefs = append(tableDefs, tableDef)
			}
		}
		if schemaKey == schemaFuncText {
			byteTriggerContent, err := ioutil.ReadFile(gen.GetAbsPath("gic/sqitch/scripts/gen/schema/functions/" + planName + ".sql"))
			if err != nil {
				ll.Error("Error read file deploy failed:", l.Error(err))
			}
			triggers = string(byteTriggerContent)
		}
	}
	migrateSchema := MigrateSchema{
		Tables:   tableDefs,
		Triggers: triggers,
	}
	return &migrateSchema
}

func NoError(err error) {
	if err != nil {
		panic(err)
	}
}
