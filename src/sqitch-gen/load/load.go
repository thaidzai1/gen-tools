package load

import (
	"io/ioutil"

	"gido.vn/gic/databases/sqitch.git/src/models"
	funcs "gido.vn/gic/databases/sqitch.git/src/sqitch-gen/load/functions"
	"gido.vn/gic/databases/sqitch.git/src/sqitch-gen/load/tables"
	"gido.vn/gic/databases/sqitch.git/src/utilities"
	"gopkg.in/yaml.v2"
)

// GetMigrateSchema ...
func GetMigrateSchema(schemaPath string) *models.MigrateSchema {
	schemaConfigDef := loadSchemaConfig(schemaPath)

	newFunctionChan := make(chan string)
	newTablesChan := make(chan []*models.TableDefination)
	alterTablesChan := make(chan []*models.AlterTable)
	dropTablesChan := make(chan models.DropTables)

	for schemaKey, schemaPath := range schemaConfigDef.Schemas {
		switch schemaKey {
		case "functions":
			generatedFunctionsPath := schemaConfigDef.Schemas["generated_functions"]
			go funcs.Load(schemaPath, generatedFunctionsPath, newFunctionChan)
			break
		case "tables":
			currTablesPath := schemaConfigDef.Schemas["curr_tables"]
			go tables.Load(schemaPath, currTablesPath, newTablesChan, alterTablesChan)
			break
		case "dropped_tables_config":
			droppedTablesDirPath := schemaConfigDef.Schemas["dropped_tables"]
			go tables.LoadDrop(schemaPath, droppedTablesDirPath, dropTablesChan)
			break
		default:
			break
		}
	}

	migrateSchema := &models.MigrateSchema{
		Triggers:    <-newFunctionChan,
		Tables:      <-newTablesChan,
		AlterTables: <-alterTablesChan,
		DropTables:  <-dropTablesChan,
	}

	return migrateSchema
}

func loadSchemaConfig(path string) *models.SchemaConfig {
	schemaConfig := &models.SchemaConfig{}

	byteSchemaFile, err := ioutil.ReadFile(path)
	utilities.HandlePanic(err, "Read file schema config failed")

	err = yaml.Unmarshal(byteSchemaFile, schemaConfig)
	utilities.HandlePanic(err, "Decoding file schema config from yaml failed")

	return schemaConfig
}
