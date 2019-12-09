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
	Fields      []struct {
		Name    string `yaml:"name"`
		Type    string `yaml:"type"`
		Primary bool   `yaml:"primary"`
		NotNull bool   `yaml:"not_null"`
		Unique  bool   `yaml:"unique"`
	} `yaml:"fields"`
	Indexs []struct {
		Name string `yaml:"name"`
		Key  string `yaml:"key"`
	} `yaml:"indexs"`
}
