package load

// DBSchema ...
type DBSchema struct {
	Version     int               `validate:"required"`
	VersionName string            `yaml:"version_name"`
	Schemas     map[string]string `validate:"required"`
}

// TableDefination ...
type TableDefination struct {
	Version     int    `validate:"required"`
	VersionName string `yaml:"version_name"`
	TableName   string
	Fields      []Field `yaml:"fields"`
	Indexs      []struct {
		Name   string `yaml:"name"`
		Key    string `yaml:"key"`
		Unique bool   `yaml:"unique"`
		Using  string `yaml:"using"`
	} `yaml:"indexs"`
}

type Field struct {
	Name    string `yaml:"name"`
	Type    string `yaml:"type"`
	Primary bool   `yaml:"primary"`
	NotNull bool   `yaml:"not_null"`
	Unique  bool   `yaml:"unique"`
}

type MigrateSchema struct {
	Tables   []TableDefination
	Triggers string
}
