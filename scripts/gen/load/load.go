package load

import (
	"io/ioutil"
	"os"
	"strings"

	"gido.vn/gic/databases/sqitch.git/scripts/gen/models"
	"gido.vn/gic/libs/common.git/l"
	"gopkg.in/yaml.v2"
)

var (
	ll = l.New()
)

// LoadSchemaDefination ...
func LoadSchemaDefination(inputPath string, planName string) *models.MigrateSchema {
	data, err := ioutil.ReadFile(inputPath)
	NoError(err)

	var dbSchema models.DBSchema
	err = yaml.Unmarshal(data, &dbSchema)
	NoError(err)

	var mapTableDefs map[string]models.TableDefination
	var currTablesDefs map[string]models.TableDefination
	var droppedTablesDef models.DropTables
	var currDroppedTableDef models.DropTables
	var triggers string

	for schemaKey, schemaPath := range dbSchema.Schemas {

		files, err := ioutil.ReadDir(schemaPath)
		NoError(err)
		schemaTableText := "tables"
		schemaFuncText := "functions"
		deployedFuncsText := "generated_functions"
		currTablesText := "curr_tables"
		droppedTablesText := "dropped_tables"
		droppedTableConfigText := "dropped_tables_config"

		switch schemaKey {
		case schemaTableText:
			mapTableDefs = loadTableDefFromYaml(files, schemaPath)
			break
		case schemaFuncText:
			byteTriggerContent, err := ioutil.ReadFile(schemaPath + "/" + planName + ".sql")
			if err != nil {
				if triggers == "" {
					allTriggerFiles, err := ioutil.ReadDir(schemaPath)
					if err != nil {
						ll.Panic("Error read dir triggers failed: ", l.Error(err))
					}

					generatedTriggers, err := ioutil.ReadFile(dbSchema.Schemas[deployedFuncsText] + "/" + "functions.yml")
					if err != nil {
						ll.Panic("Error read file generated functions yml failed: ", l.Error(err))
					}

					var generatedTriggersDef models.GeneratedFunctions
					err = yaml.Unmarshal(generatedTriggers, &generatedTriggersDef)
					if err != nil {
						ll.Panic("Error unmarshal triggers defination: ", l.Error(err))
					}
					ll.Print(generatedTriggersDef)
					if len(generatedTriggersDef.FileName) < len(allTriggerFiles) {
						for _, triggerFile := range allTriggerFiles {
							isGenerated := false
							for _, generatedFile := range generatedTriggersDef.FileName {
								if generatedFile == triggerFile.Name() {
									isGenerated = true
									break
								}
							}
							if !isGenerated {
								content, err := ioutil.ReadFile(schemaPath + "/" + triggerFile.Name())
								if err != nil {
									ll.Panic("Error read file triggers failed", l.Error(err))
								}
								byteTriggerContent = append(byteTriggerContent, content...)
							}
						}
					}
				}
			}
			triggers = string(byteTriggerContent)
			break
		case currTablesText:
			currTablesDefs = loadTableDefFromYaml(files, schemaPath)
			break
		case droppedTableConfigText:
			dropConfigFileName := "dropped-tables.yml"
			ll.Print("path: ", schemaPath+"/"+dropConfigFileName)
			data, err := ioutil.ReadFile(schemaPath + "/" + dropConfigFileName)
			NoError(err)
			err = yaml.Unmarshal(data, &droppedTablesDef)
			break
		case droppedTablesText:
			var droppedTables []string
			for _, file := range files {
				var fileNameWithoutSuffix string
				if strings.Contains(file.Name(), ".yaml") {
					fileNameWithoutSuffix = strings.ReplaceAll(file.Name(), ".yaml", "")
				} else if strings.Contains(file.Name(), ".yml") {
					fileNameWithoutSuffix = strings.ReplaceAll(file.Name(), ".yml", "")
				} else {
					continue
				}
				droppedTables = append(droppedTables, fileNameWithoutSuffix)
			}
			currDroppedTableDef.Tables = droppedTables
			break
		}
	}

	diffTables, newTables := compareDiffYaml(currTablesDefs, mapTableDefs)
	diffDroppedTables := compareDiffDropTables(droppedTablesDef, currDroppedTableDef)

	migrateSchema := models.MigrateSchema{
		Tables:      *newTables,
		AlterTables: *diffTables,
		DropTables:  diffDroppedTables,
		Triggers:    triggers,
	}
	return &migrateSchema
}

func loadTableDefFromYaml(files []os.FileInfo, schemaPath string) map[string]models.TableDefination {
	tableDefs := make(map[string]models.TableDefination)
	for _, file := range files {
		ll.Print("file: ", file.Name())
		if !(strings.HasSuffix(file.Name(), ".yml") || strings.HasSuffix(file.Name(), ".yaml")) {
			continue
		}

		data, err := ioutil.ReadFile(schemaPath + "/" + file.Name())
		NoError(err)
		var tableDef models.TableDefination
		err = yaml.Unmarshal(data, &tableDef)

		lengthWithouSuffix := strings.Index(file.Name(), ".")
		nameWithoutSuffix := file.Name()[:lengthWithouSuffix]
		tableDef.TableName = nameWithoutSuffix

		tableDefs[nameWithoutSuffix] = tableDef
	}

	return tableDefs
}

func mapToSlice(mapTables map[string]models.TableDefination) []models.TableDefination {
	var tableDefs []models.TableDefination

	for _, mapTable := range mapTables {
		tableDefs = append(tableDefs, mapTable)
	}

	return tableDefs
}

func compareDiffYaml(curTables, changedTables map[string]models.TableDefination) (*[]models.AlterTable, *[]models.TableDefination) {
	var diffTables []models.AlterTable
	var newTables []models.TableDefination

	if len(curTables) == 0 {
		tmpNewTables := mapToSlice(changedTables)
		for _, newTable := range tmpNewTables {
			newTable = mappingWithHistoryFields(newTable)
			newTables = append(newTables, newTable)
		}
	} else {
		for changedTableKey, changedTable := range changedTables {
			// Get New Table
			ll.Print("curTable: ", curTables[changedTableKey])
			if curTables[changedTableKey].TableName == "" {
				newTables = append(newTables, mappingWithHistoryFields(changedTable))
				continue
			}

			// Current table (Restricted Table)
			curFields := curTables[changedTableKey].Fields
			curIndexs := curTables[changedTableKey].Indexs
			curDropFields := curTables[changedTableKey].DropFields
			curHistories := curTables[changedTableKey].Histories

			isHistoryNoneField := false

			// Get Table Fields Changed or New
			var diffTable models.AlterTable
			for _, changedField := range changedTable.Fields {
				isAlreadyExisted := false
				for _, curField := range curFields {
					field := models.FieldChanged{}
					isFieldUpdated := false
					if changedField.Name == curField.Name || changedField.OldName == curField.Name {
						isAlreadyExisted = true
						field.Field.Name = changedField.Name
						if changedField.OldName == curField.Name {
							isFieldUpdated = true
							field.Field.Name = changedField.Name
							field.Field.OldName = changedField.OldName
						}
						if changedField.Primary != curField.Primary {
							isFieldUpdated = true
							field.Field.Primary = changedField.Primary
							field.IsPrimaryChanged = true
						}
						if changedField.NotNull != curField.NotNull {
							isFieldUpdated = true
							field.Field.NotNull = changedField.NotNull
							field.IsNotNullChanged = true
						}
						if changedField.Unique != curField.Unique {
							isFieldUpdated = true
							field.Field.Unique = changedField.Unique
							field.IsUniqueChanged = true
						}
						if changedField.Default != curField.Default {
							isFieldUpdated = true
							field.Field.Default = changedField.Default
							field.IsDefaultChanged = true
						}

						if changedField.Type != curField.Type {
							isFieldUpdated = true
							field.Field.Type = changedField.Type
							field.IsTypeChanged = true
						}

						if isFieldUpdated {
							ll.Info("==> Append table field")
							diffTable.Fields = append(diffTable.Fields, field)
						}
						break
					}
				}

				if !isAlreadyExisted {
					ll.Info("==> This is new field of table")
					newField := models.FieldChanged{
						Field: models.Field{
							Name:    changedField.Name,
							Type:    changedField.Type,
							Primary: changedField.Primary,
							NotNull: changedField.NotNull,
							Unique:  changedField.Unique,
							Default: changedField.Default,
						},
						IsNewField: true,
					}

					diffTable.Fields = append(diffTable.Fields, newField)
				}
			}

			// Get Table Indexs Changed or New
			var arrIndex []models.Index
			for _, changedIndex := range changedTable.Indexs {
				isAlreadyExisted := false
				for _, curIndex := range curIndexs {
					if changedIndex.Name == curIndex.Name {
						isAlreadyExisted = true
					}
				}

				if !isAlreadyExisted {
					ll.Info("==> This is new index of table")
					newIndex := models.Index{
						Name:   changedIndex.Name,
						Key:    changedIndex.Key,
						Using:  changedIndex.Using,
						Unique: changedIndex.Unique,
					}

					arrIndex = append(arrIndex, newIndex)
				}
			}

			// Get Table Drop fields Changed or New
			var dropFields []models.DropFields
			for _, changedDropField := range changedTable.DropFields {
				isDropped := true
				for _, curDropField := range curDropFields {
					if changedDropField.Name == curDropField.Name {
						isDropped = false
					}
				}

				if isDropped {
					dropField := models.DropFields{
						Name: changedDropField.Name,
					}

					dropFields = append(dropFields, dropField)
				}
			}

			// Get Table Histories Changed or New
			var histories []models.HistoryField
			if len(curHistories) == 0 && len(changedTable.Histories) > 0 {
				for _, changedField := range changedTable.Fields {
					var field models.HistoryField
					for _, changedHistory := range changedTable.Histories {

						if changedHistory.Name == changedField.Name {
							field.Name = changedHistory.Name
							field.Type = changedField.Type
						}

						if changedHistory.IsNoneFields {
							isHistoryNoneField = true
						}
					}

					if changedField.Name == "user_id" || changedField.Name == "action_admin_id" {
						field.Name = changedField.Name
						field.Type = changedField.Type
					}

					if (models.HistoryField{}) != field {
						histories = append(histories, field)
					}
				}
			}

			if len(diffTable.Fields) > 0 {
				ll.Info("==> Must create new alter script")
				diffTable.Name = changedTable.TableName
				diffTables = append(diffTables, diffTable)
			}

			if len(arrIndex) > 0 || len(dropFields) > 0 || len(histories) > 0 || isHistoryNoneField {
				newTables = append(newTables, models.TableDefination{
					TableName:          changedTable.TableName,
					Indexs:             arrIndex,
					DropFields:         dropFields,
					Histories:          histories,
					IsHistoryNoneField: isHistoryNoneField,
				})
			}
		}
	}

	ll.Print("New tables: ", newTables)

	return &diffTables, &newTables
}

func compareDiffDropTables(changedTables, curTables models.DropTables) models.DropTables {
	var unDroppedTables models.DropTables

	for _, changeTable := range changedTables.Tables {
		isDropped := false
		for _, curTable := range curTables.Tables {
			if changeTable == curTable {
				isDropped = true
			}
		}

		if !isDropped {
			unDroppedTables.Tables = append(unDroppedTables.Tables, changeTable)
		}
	}

	return unDroppedTables
}

func mappingWithHistoryFields(changedTable models.TableDefination) models.TableDefination {
	var histories []models.HistoryField
	isHistoryNoneField := false
	if len(changedTable.Histories) > 0 {
		for _, field := range changedTable.Fields {

			if field.Name == "action_admin_id" || field.Name == "user_id" {
				histories = append(histories, models.HistoryField{
					Name: field.Name,
					Type: field.Type,
				})
				continue
			}

			for _, history := range changedTable.Histories {
				if history.Name == field.Name {
					history.Type = field.Type
					histories = append(histories, history)
					break
				}

				if history.IsNoneFields {
					isHistoryNoneField = true
				}
			}
		}
	}

	ll.Print("history: ", histories)

	mappedTable := models.TableDefination{
		VersionName:        changedTable.VersionName,
		Version:            changedTable.Version,
		TableName:          changedTable.TableName,
		Fields:             changedTable.Fields,
		Indexs:             changedTable.Indexs,
		DropFields:         changedTable.DropFields,
		Histories:          histories,
		IsHistoryNoneField: isHistoryNoneField,
	}

	return mappedTable
}

func NoError(err error) {
	if err != nil {
		panic(err)
	}
}
