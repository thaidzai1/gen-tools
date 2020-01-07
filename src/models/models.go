package models

// ModelDefination ...
type ModelDefination struct {
	Model   Model               `yaml:"model"`
	Fields  []*ModelField       `yaml:"fields"`
	Filters []*FilterDefinition `yaml:"filters"`
}

// Model ...
type Model struct {
	Name            string      `yaml:"name"`
	KeyField        string      `yaml:"key_field"`
	KeyType         string      `yaml:"-"`
	UserFilterField *ModelField `yaml:"-"`
}

// ModelField ...
type ModelField struct {
	Name        string `yaml:"name"`
	Type        string `yaml:"type"`
	GoType      string `yaml:"go_type"`
	SkipInProto bool   `yaml:"skip_in_proto"`
	Ref         string `yaml:"ref"`
	Filter      bool   `yaml:"filter"`
}

// FilterDefinition ...
type FilterDefinition struct {
	Name   string
	Fields []string `yaml:"fields"`
}
