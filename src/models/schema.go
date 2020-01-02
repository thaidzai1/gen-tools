package models

// SchemaConfig ...
type SchemaConfig struct {
	Version     int               `validate:"required"`
	VersionName string            `yaml:"version_name"`
	Schemas     map[string]string `yaml:"schemas" validate:"required"`
}
