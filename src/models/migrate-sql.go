package models

// TableDefination ...
type TableDefination struct {
	Version            int             `validate:"required"`
	VersionName        string          `yaml:"version_name"`
	Fields             []*Field        `yaml:"fields"`
	Indexs             []*Index        `yaml:"indexes"`
	DropFields         []*DropFields   `yaml:"drop_fields"`
	Histories          []*HistoryField `yaml:"histories"`
	IsTable            bool            `yaml:"is_table"`
	TableName          string          `yaml:"-"`
	IsHistoryNoneField bool            `yaml:"-"`
}

// GeneratedFunctions ...
type GeneratedFunctions struct {
	FileName []string `yaml:"functions"`
}

// DropTables ...
type DropTables struct {
	Tables []string `yaml:"dropped_tables"`
}

// DropFields ...
type DropFields struct {
	Name string `yaml:"name"`
}

// HistoryField ...
type HistoryField struct {
	Name         string `yaml:"name"`
	IsNoneFields bool   `yaml:"none_field"`
	Type         string
}

// Field ...
type Field struct {
	Name             string `yaml:"name"`
	OldName          string `yaml:"old_name"`
	Type             string `yaml:"type"`
	Primary          bool   `yaml:"primary"`
	NotNull          bool   `yaml:"not_null"`
	Unique           bool   `yaml:"unique"`
	Default          string `yaml:"default"`
	SkipInDB         bool   `yaml:"skip_in_db"`
	IsTypeChanged    bool
	IsNewField       bool
	IsPrimaryChanged bool
	IsNotNullChanged bool
	IsUniqueChanged  bool
	IsDefaultChanged bool
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
	Fields []*Field
}

// MigrateSchema ..
type MigrateSchema struct {
	Tables      []*TableDefination
	AlterTables []*AlterTable
	DropTables  DropTables
	Triggers    string
}
