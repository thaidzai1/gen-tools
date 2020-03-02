package models

import "strings"

// CountFilterQueryParams ...
func (model *ModelDefination) CountFilterQueryParams() int {
	for _, fd := range model.Filters {
		if fd.Name == "q" {
			return len(fd.Fields)
		}
	}
	return 0
}

// Inc ...
func (model *ModelDefination) Inc(i int) int {
	return i + 1
}

// GetPackageName ...
func (model *ModelDefination) GetPackageName() string {
	arrPackageName := strings.Split(model.PackageName, ".")

	return arrPackageName[0] + "pb"
}

// GetMaxTableColLength ...
func (migrate *MigrateSchema) GetMaxTableColLength() int {
	maxTableLength := len("Tables")
	for _, table := range migrate.Tables {
		if len(table.TableName) > maxTableLength {
			maxTableLength = len(table.TableName)
		}
	}

	for _, table := range migrate.AlterTables {
		if len(table.Name) > maxTableLength {
			maxTableLength = len(table.Name)
		}
	}

	return maxTableLength
}

// GetMaxFieldColLength ...
func (migrate *MigrateSchema) GetMaxFieldColLength() int {
	maxFieldLength := len("Fields")
	for _, table := range migrate.Tables {
		for _, field := range table.Fields {
			if len(field.Name) > maxFieldLength {
				maxFieldLength = len(field.Name)
			}
		}
	}

	for _, table := range migrate.AlterTables {
		for _, field := range table.Fields {
			if len(field.Name) > maxFieldLength {
				maxFieldLength = len(field.Name)
			}
		}
	}

	return maxFieldLength
}
