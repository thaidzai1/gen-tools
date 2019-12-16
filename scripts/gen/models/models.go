package models

// DBSchema ...
type DBSchema struct {
	Version     int               `validate:"required"`
	VersionName string            `yaml:"version_name"`
	Schemas     map[string]string `validate:"required"`
}

// TableDefination ...
type TableDefination struct {
	Version     int          `validate:"required"`
	VersionName string       `yaml:"version_name"`
	Fields      []Field      `yaml:"fields"`
	Indexs      []Index      `yaml:"indexs"`
	DropFields  []DropFields `yaml:"drop_fields"`
	TableName   string
}

// DropFields ...
type DropFields struct {
	Name string `yaml:"name"`
}

// Field ...
type Field struct {
	Name    string `yaml:"name"`
	OldName string `yaml:"old_name"`
	Type    string `yaml:"type"`
	Primary bool   `yaml:"primary"`
	NotNull bool   `yaml:"not_null"`
	Unique  bool   `yaml:"unique"`
	Default string `yaml:"default"`
}

// Index ...
type Index struct {
	Name   string `yaml:"name"`
	Key    string `yaml:"key"`
	Unique bool   `yaml:"unique"`
	Using  string `yaml:"using"`
}

// AlterTable ...
type AlterTable struct {
	Name   string
	Fields []FieldChanged
}

// FieldChanged ...
type FieldChanged struct {
	Field            Field
	IsNewField       bool
	IsPrimaryChanged bool
	IsNotNullChanged bool
	IsUniqueChanged  bool
	IsDefaultChanged bool
}

// MigrateSchema ..
type MigrateSchema struct {
	Tables      []TableDefination
	AlterTables []AlterTable
	Triggers    string
}
