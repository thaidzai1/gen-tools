package models

// ModelDefination ...
type ModelDefination struct {
	Model  Model        `yaml:"model"`
	Fields []ModelField `yaml:"fields"`
}

// Model ...
type Model struct {
	Name string `yaml:"name"`
}

// ModelField ...
type ModelField struct {
	Name string `yaml:"name"`
	Type string `yaml:"type"`
}
