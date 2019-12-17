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
	var restrictedTableDefs map[string]models.TableDefination
	var triggers string

	for schemaKey, schemaPath := range dbSchema.Schemas {

		files, err := ioutil.ReadDir(schemaPath)
		NoError(err)
		schemaTableText := "tables"
		schemaFuncText := "functions"
		schemaRestrictedText := "restricted"
		if schemaKey == schemaTableText {
			mapTableDefs = loadTableDefFromYaml(files, schemaPath)
		}
		if schemaKey == schemaFuncText {
			byteTriggerContent, err := ioutil.ReadFile(schemaPath + "/" + planName + ".sql")
			if err != nil {
				ll.Error("Error read file deploy failed:", l.Error(err))
			}
			triggers = string(byteTriggerContent)
		}
		if schemaKey == schemaRestrictedText {
			restrictedTableDefs = loadTableDefFromYaml(files, schemaPath)
		}
	}

	diffTables, newTables := compareDiffYaml(restrictedTableDefs, mapTableDefs)

	migrateSchema := models.MigrateSchema{
		Tables:      *newTables,
		AlterTables: *diffTables,
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
		newTables = mapToSlice(changedTables)
	} else {
		for changedTableKey, changedTable := range changedTables {
			// Get New Table
			if curTables[changedTableKey].TableName == "" {
				newTables = append(newTables, mappingWithHistoryFields(changedTable))
				continue
			}

			// Current table (Restricted Table)
			curFields := curTables[changedTableKey].Fields
			curIndexs := curTables[changedTableKey].Indexs
			curDropFields := curTables[changedTableKey].DropFields
			curHistories := curTables[changedTableKey].Histories

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
			var histories []models.Field
			if len(curHistories) == 0 && len(changedTable.Histories) > 0 {
				for _, changedField := range changedTable.Fields {
					var field models.Field
					for _, changedHistory := range changedTable.Histories {

						if changedHistory.Name == changedField.Name {
							field.Name = changedHistory.Name
							field.Type = changedField.Type
						}
					}

					if changedField.Name == "user_id" || changedField.Name == "action_admin_id" {
						field.Name = changedField.Name
						field.Type = changedField.Type
					}

					if (models.Field{}) != field {
						histories = append(histories, field)
					}
				}
			}

			if len(diffTable.Fields) > 0 {
				ll.Info("==> Must create new alter script")
				diffTable.Name = changedTable.TableName
				diffTables = append(diffTables, diffTable)
			}

			if len(arrIndex) > 0 || len(dropFields) > 0 || len(histories) > 0 {
				newTables = append(newTables, models.TableDefination{
					TableName:  changedTable.TableName,
					Indexs:     arrIndex,
					DropFields: dropFields,
					Histories:  histories,
				})
			}
		}
	}

	return &diffTables, &newTables
}

func mappingWithHistoryFields(changedTable models.TableDefination) models.TableDefination {
	var histories []models.Field
	if len(changedTable.Histories) > 0 {
		for _, field := range changedTable.Fields {

			if field.Name == "action_admin_id" || field.Name == "user_id" {
				histories = append(histories, models.Field{
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
			}
		}
	}

	mappedTable := models.TableDefination{
		VersionName: changedTable.VersionName,
		Version:     changedTable.Version,
		TableName:   changedTable.TableName,
		Fields:      changedTable.Fields,
		Indexs:      changedTable.Indexs,
		DropFields:  changedTable.DropFields,
		Histories:   histories,
	}

	return mappedTable
}

func NoError(err error) {
	if err != nil {
		panic(err)
	}
}
