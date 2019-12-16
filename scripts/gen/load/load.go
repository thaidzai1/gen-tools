package load

import (
	"io/ioutil"
	"os"
	"strings"

	"gido.vn/gic/databases/sqitch.git/scripts/gen/models"
	"gido.vn/gic/libs/common.git/gen"
	"gido.vn/gic/libs/common.git/l"
	"gopkg.in/yaml.v2"
)

var (
	ll = l.New()
)

// LoadSchemaDefination ...
func LoadSchemaDefination(inputPath string, planName string) *models.MigrateSchema {
	data, err := ioutil.ReadFile(gen.GetAbsPath(inputPath))
	NoError(err)

	var dbSchema models.DBSchema
	err = yaml.Unmarshal(data, &dbSchema)
	NoError(err)

	var mapTableDefs map[string]models.TableDefination
	var restrictedTableDefs map[string]models.TableDefination
	var triggers string

	for schemaKey, schemaPath := range dbSchema.Schemas {

		absPath := gen.GetAbsPath(schemaPath)
		files, err := ioutil.ReadDir(absPath)
		NoError(err)
		schemaTableText := "tables"
		schemaFuncText := "functions"
		schemaRestrictedText := "restricted"
		if schemaKey == schemaTableText {
			mapTableDefs = loadTableDefFromYaml(files, schemaPath)
		}
		if schemaKey == schemaFuncText {
			byteTriggerContent, err := ioutil.ReadFile(gen.GetAbsPath("gic/database/sqitch.git/scripts/gen/schema/functions/" + planName + ".sql"))
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

		data, err := ioutil.ReadFile(gen.GetAbsPath(schemaPath + "/" + file.Name()))
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
				newTables = append(newTables, changedTable)
				continue
			}

			// Get Table Fields Changed or New
			curFields := curTables[changedTableKey].Fields
			curIndexs := curTables[changedTableKey].Indexs
			curDropFields := curTables[changedTableKey].DropFields
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
						if isFieldUpdated {
							ll.Info("==> Append table field")
							diffTable.Fields = append(diffTable.Fields, field)
						}
						// Not support change type yet.
						// if changedField.Type != curField.Type {
						// 	isFieldUpdated = true
						// 	field.Type = changedField.Type
						// }
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

			if len(diffTable.Fields) > 0 {
				ll.Info("==> Must create new alter script")
				diffTable.Name = changedTable.TableName
				diffTables = append(diffTables, diffTable)
			}

			if len(arrIndex) > 0 || len(dropFields) > 0 {
				newTables = append(newTables, models.TableDefination{
					TableName:  changedTable.TableName,
					Indexs:     arrIndex,
					DropFields: dropFields,
				})
			}
		}
	}

	return &diffTables, &newTables
}

func NoError(err error) {
	if err != nil {
		panic(err)
	}
}
