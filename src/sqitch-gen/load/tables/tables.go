package tables

import (
	"gido.vn/gic/databases/sqitch.git/src/models"
	"gido.vn/gic/databases/sqitch.git/src/utilities"
	"gido.vn/gic/libs/common.git/l"
	"gopkg.in/yaml.v2"
	"strings"

	"io/ioutil"
)

var (
	ll = l.New()
)

// Load ...
func Load(tablesDirPath string, currTablesDirPath string, tablesChan chan []*models.TableDefination, alterTablesChan chan []*models.AlterTable) {
	tableDefs := loadTablesDef(tablesDirPath)
	currTableDefs := loadTablesDef(currTablesDirPath)

	tables, alterTables := compareDiffTables(tableDefs, currTableDefs)

	tablesChan <- tables
	alterTablesChan <- alterTables

	close(tablesChan)
	close(alterTablesChan)
}

// LoadDrop ...
func LoadDrop(dropTablesPath string, droppedTablesDirPath string, dropTablesChan chan models.DropTables) {
	dropTableConfig, err := ioutil.ReadFile(dropTablesPath)
	utilities.HandlePanic(err, "Read file config drop tables failed")

	var dropTablesDef models.DropTables
	err = yaml.Unmarshal(dropTableConfig, &dropTablesDef)
	utilities.HandlePanic(err, "Decoding file config drop tables failed")

	var currDroppedTableDef models.DropTables
	files, err := ioutil.ReadDir(droppedTablesDirPath)
	utilities.HandlePanic(err, "Read dir dropped tables failed")
	for _, file := range files {
		var fileNameWithoutSuffix string
		if strings.Contains(file.Name(), ".yaml") {
			fileNameWithoutSuffix = strings.ReplaceAll(file.Name(), ".yaml", "")
		} else if strings.Contains(file.Name(), ".yml") {
			fileNameWithoutSuffix = strings.ReplaceAll(file.Name(), ".yml", "")
		} else {
			continue
		}
		currDroppedTableDef.Tables = append(currDroppedTableDef.Tables, fileNameWithoutSuffix)
	}

	willDropTables := compareDiffDropTables(dropTablesDef, currDroppedTableDef)
	dropTablesChan <- willDropTables
}

func loadTablesDef(dirPath string) map[string]*models.TableDefination {
	tableFiles, err := ioutil.ReadDir(dirPath)
	utilities.HandlePanic(err, "Read file current table in .retricted folder failed")

	tableDefs := map[string]*models.TableDefination{}
	for _, file := range tableFiles {
		ll.Print("file name: ", file.Name())
		tableDef := &models.TableDefination{}
		if !(strings.Contains(file.Name(), ".yml") || strings.Contains(file.Name(), ".yaml")) {
			continue
		}

		byteTableFileContent, err := ioutil.ReadFile(dirPath + "/" + file.Name())
		utilities.HandlePanic(err, "Read table file config failed")

		err = yaml.Unmarshal(byteTableFileContent, tableDef)
		utilities.HandlePanic(err, "Decoding table config file content failed")

		if !tableDef.IsTable {
			continue
		}

		lengthWithouSuffix := strings.Index(file.Name(), ".")
		nameWithoutSuffix := file.Name()[:lengthWithouSuffix]
		tableDef.TableName = nameWithoutSuffix

		tableDefs[nameWithoutSuffix] = tableDef
	}

	return tableDefs
}

func compareDiffTables(tableDefs, currTableDefs map[string]*models.TableDefination) ([]*models.TableDefination, []*models.AlterTable) {
	tables := []*models.TableDefination{}
	alterTables := []*models.AlterTable{}
	for tableKey, tableDef := range tableDefs {
		ll.Print("tableKey: ", tableKey)
		currTableDef := currTableDefs[tableKey]

		// New tables
		if currTableDef == nil {
			ll.Info("New tables")
			histories, isHistoryNoneField := mappingHistoryFieldWithType(*tableDef)
			tableDef.Histories = histories
			tableDef.IsHistoryNoneField = isHistoryNoneField

			tables = append(tables, tableDef)
			continue
		}

		// Alter tables
		alterTable := &models.AlterTable{}
		diffFields := compareDiffFields(tableDef.Fields, currTableDef.Fields)
		if len(diffFields) > 0 {
			ll.Info("==> Must create alter script")
			alterTable.Name = tableDef.TableName
			alterTable.Fields = diffFields
			alterTables = append(alterTables, alterTable)
		}

		// New history tables
		var histories []*models.HistoryField
		var isHistoryNoneField bool
		if len(currTableDef.Histories) == 0 {
			histories, isHistoryNoneField = mappingHistoryFieldWithType(*tableDef)
		}

		// Drop fields
		dropFields := compareDiffDropField(tableDef.DropFields, currTableDef.DropFields)

		// Get Table Indexs Changed or New
		arrIndexs := compareDiffIndexs(tableDef.Indexs, currTableDef.Indexs)

		if len(arrIndexs) > 0 || len(dropFields) > 0 || len(histories) > 0 || isHistoryNoneField {
			tables = append(tables, &models.TableDefination{
				TableName:          tableDef.TableName,
				Indexs:             arrIndexs,
				DropFields:         dropFields,
				Histories:          histories,
				IsHistoryNoneField: isHistoryNoneField,
			})
		}
	}

	return tables, alterTables
}

func compareDiffFields(fields, currFields []*models.Field) []*models.Field {
	diffFields := []*models.Field{}
	for _, field := range fields {
		diffField := field
		diffField.IsNewField = true
		isFieldUpdated := false
		if !field.SkipInDB {
			for _, currField := range currFields {
				if field.Name == currField.Name || field.OldName == currField.Name {
					diffField.IsNewField = false

					if field.Name != currField.Name && field.OldName == currField.Name {
						isFieldUpdated = true
					}

					if field.Type != currField.Type {
						isFieldUpdated = true
						diffField.IsTypeChanged = true
					}

					if field.NotNull != currField.NotNull {
						isFieldUpdated = true
						diffField.IsNotNullChanged = true
					}

					if field.Unique != currField.Unique {
						isFieldUpdated = true
						diffField.IsUniqueChanged = true
					}

					if field.Primary != currField.Primary {
						isFieldUpdated = true
						diffField.IsPrimaryChanged = true
					}

					if field.Default != currField.Default {
						isFieldUpdated = true
						diffField.IsDefaultChanged = true
					}
				}
			}
			if isFieldUpdated || diffField.IsNewField {
				diffFields = append(diffFields, diffField)
			}
		}
	}
	return diffFields
}

func mappingHistoryFieldWithType(table models.TableDefination) ([]*models.HistoryField, bool) {
	var histories []*models.HistoryField
	isHistoryNoneField := false
	if len(table.Histories) > 0 {
		for _, field := range table.Fields {

			if field.Name == "action_admin_id" || field.Name == "user_id" {
				histories = append(histories, &models.HistoryField{
					Name: field.Name,
					Type: field.Type,
				})
				continue
			}

			for _, history := range table.Histories {
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

	return histories, isHistoryNoneField
}

func compareDiffDropField(dropFields, curDropField []*models.DropFields) []*models.DropFields {
	var needDropFields []*models.DropFields
	for _, changedDropField := range dropFields {
		isDropped := true
		for _, curDropField := range curDropField {
			if changedDropField.Name == curDropField.Name {
				isDropped = false
			}
		}

		if isDropped {
			needDropField := &models.DropFields{
				Name: changedDropField.Name,
			}

			needDropFields = append(needDropFields, needDropField)
		}
	}

	return needDropFields
}

func compareDiffIndexs(indexs, currIndexs []*models.Index) []*models.Index {
	var arrIndex []*models.Index
	for _, changedIndex := range indexs {
		isAlreadyExisted := false
		for _, curIndex := range currIndexs {
			if changedIndex.Name == curIndex.Name {
				isAlreadyExisted = true
			}
		}

		if !isAlreadyExisted {
			ll.Info("==> This is new index of table")
			newIndex := &models.Index{
				Name:   changedIndex.Name,
				Key:    changedIndex.Key,
				Using:  changedIndex.Using,
				Unique: changedIndex.Unique,
			}

			arrIndex = append(arrIndex, newIndex)
		}
	}
	return arrIndex
}

func compareDiffDropTables(dropTables, currDroppedTables models.DropTables) models.DropTables {
	willDropTables := models.DropTables{}

	for _, dropTable := range dropTables.Tables {
		isDropped := false
		for _, currDroppedTable := range currDroppedTables.Tables {
			if dropTable == currDroppedTable {
				isDropped = true
			}
		}

		if !isDropped {
			willDropTables.Tables = append(willDropTables.Tables, dropTable)
		}
	}

	return willDropTables
}
