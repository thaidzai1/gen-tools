package main

import (
	"bytes"
	"html/template"
	"io/ioutil"
	"os"
	"strings"

	"gido.vn/gic/databases/sqitch.git/src/models"
	"gido.vn/gic/databases/sqitch.git/src/utilities"
	"gido.vn/gic/libs/common.git/l"
	"gopkg.in/yaml.v2"
)

var (
	ll = l.New()
)

type Combination struct {
	Fields  []Field
	Model   models.Model
	Filters []*models.FilterDefinition
	IsTable bool `yaml:"-"`
}

type Field struct {
	Name        string `yaml:"name"`
	Type        string `yaml:"type"`
	GoType      string `yaml:"go_type"`
	SkipInProto bool   `yaml:"skip_in_proto"`
	SkipInDB    bool   `yaml:"skip_in_db"`
	Gorm        string `yaml:"gorm"`
	Ref         string `yaml:"ref"`
	Filter      bool   `yaml:"filter"`
	OldName     string `yaml:"old_name"`
	Primary     bool   `yaml:"primary"`
	NotNull     bool   `yaml:"not_null"`
	Unique      bool   `yaml:"unique"`
	Default     string `yaml:"default"`
}

func main() {
	modelConfigPath := "/Users/thaidzai/code/go/src/gicprime.com/backend/scripts/gido_gen/schema/pship"
	tableConfigPath := "/Users/thaidzai/code/go/src/gido.vn/gic/databases/gido-v1.0/schema/tables"

	modelDefs := loadModelDef(modelConfigPath)
	tableDefs := loadTableDef(tableConfigPath)

	ll.Print("modelDefs: ", modelDefs)

	combination := combineDef(modelDefs, tableDefs)
	genCombination(combination)
}

func loadModelDef(path string) map[string]models.ModelDefination {
	ll.Print("Path: ", path)
	modelDefs := map[string]models.ModelDefination{}

	files, err := ioutil.ReadDir(path)
	if err != nil {
		ll.Panic("read model dir failed: ", l.Error(err))
	}

	for _, file := range files {
		fileName := file.Name()
		fileContent, err := ioutil.ReadFile(path + "/" + fileName)
		if err != nil {
			ll.Panic("Read model file config: ", l.Error(err))
		}

		modelDef := models.ModelDefination{}

		err = yaml.Unmarshal(fileContent, &modelDef)
		if err != nil {
			ll.Panic("decoding model config yaml failed: ", l.Error(err))
		}

		modelDefs[fileName] = modelDef
	}

	return modelDefs
}

func loadTableDef(path string) map[string]models.TableDefination {
	ll.Print("Path: ", path)
	tableDefs := map[string]models.TableDefination{}

	files, err := ioutil.ReadDir(path)
	if err != nil {
		ll.Panic("read table dir failed: ", l.Error(err))
	}

	for _, file := range files {
		fileName := file.Name()
		ll.Print("read path: ", path+"/"+fileName)
		fileContent, err := ioutil.ReadFile(path + "/" + fileName)
		if err != nil {
			ll.Panic("read file table config failed: ", l.Error(err))
		}

		tableDef := models.TableDefination{}

		err = yaml.Unmarshal(fileContent, &tableDef)
		if err != nil {
			ll.Panic("decoding table config yaml failed: ", l.Error(err))
		}

		tableDefs[fileName] = tableDef
	}

	return tableDefs
}

func combineDef(modelDefs map[string]models.ModelDefination, tableDefs map[string]models.TableDefination) map[string]Combination {
	combination := map[string]Combination{}

	for modelKey, modelDef := range modelDefs {
		isInTable := false
		for tableKey, tableDef := range tableDefs {
			if modelKey == tableKey {
				isInTable = true
				fields := []Field{}
				for _, modelField := range modelDef.Fields {
					isInTable := false
					for _, tableField := range tableDef.Fields {
						if tableField.Name == utilities.ToSnakeCase(utilities.ToTitleNorm(modelField.Name)) {
							isInTable = true
							field := Field{
								Name:        tableField.Name,
								OldName:     tableField.OldName,
								Type:        tableField.Type,
								GoType:      modelField.Type,
								SkipInProto: modelField.SkipInProto,
								SkipInDB:    modelField.SkipInDB,
								Primary:     tableField.Primary,
								NotNull:     tableField.NotNull,
								Unique:      tableField.Unique,
								Default:     tableField.Default,
								Filter:      modelField.Filter,
								Ref:         modelField.Ref,
								Gorm:        modelField.Gorm,
							}
							fields = append(fields, field)
							break
						}
					}

					if !isInTable {
						field := Field{
							Name:        utilities.ToSnakeCase(utilities.ToTitleNorm(modelField.Name)),
							GoType:      modelField.Type,
							SkipInDB:    true,
							SkipInProto: modelField.SkipInProto,
							Filter:      modelField.Filter,
							Ref:         modelField.Ref,
							Gorm:        modelField.Gorm,
						}

						fields = append(fields, field)
					}
				}
				combination[modelKey] = Combination{
					Model:   modelDef.Model,
					Filters: modelDef.Filters,
					Fields:  fields,
					IsTable: true,
				}
			}
		}

		if !isInTable {
			fields := []Field{}
			for _, modelField := range modelDef.Fields {
				field := Field{
					Name:        modelField.Name,
					GoType:      modelField.Type,
					Gorm:        modelField.Gorm,
					Ref:         modelField.Ref,
					SkipInProto: modelField.SkipInProto,
					SkipInDB:    modelField.SkipInDB,
					Filter:      modelField.Filter,
				}

				fields = append(fields, field)
			}
			combination[modelKey] = Combination{
				Model:   modelDef.Model,
				Filters: modelDef.Filters,
				Fields:  fields,
				IsTable: false,
			}
		}
	}

	return combination
}

func genCombination(combination map[string]Combination) {
	for key, combine := range combination {
		ll.Print("combine: ", combine)
		var scripts string = `
version: 1
version_name: Init - 1

is_table: {{.IsTable}}

model:
  name: {{.Model.Name}}
  key_field: {{.Model.KeyField}}

fields:
{{- range .Fields}}
  - name: {{.Name}}
{{- if not .SkipInDB}}
    old_name: {{.OldName}}
{{- end}}
{{- if ne .Type ""}}
    type: {{.Type}} 
{{- end}}
    go_type: {{.GoType}}
{{- if .SkipInProto}}
    skip_in_proto: {{.SkipInProto}}
{{- end}}
{{- if .SkipInDB }}
    skip_in_db: {{.SkipInDB}} 
{{- end}}
{{- if .Primary}}
    primary: {{.Primary}}  
{{- end}}
{{- if .NotNull}}
    not_null: {{.NotNull}} 
{{- end}}    
{{- if .Unique}}
    unique: {{.Unique}}
{{- end}}
{{- if ne .Default ""}}
    default: {{.Default}}
{{- end}}
{{- if .Filter}}
    filter: {{.Filter}}
{{- end}}
{{- if ne .Ref ""}}
    Ref: {{.Ref}}
{{- end}}
{{- if ne .Gorm ""}}
    gorm: "{{.Gorm}};"
{{- end}}
{{- end}}


{{- if .Filters}}
filters:
{{- range .Filters}}
- name: {{.Name}}
  fields:
{{- range .Fields}}
  - {{.}}
{{- end}}  
{{- end}}
{{- end}}
`

		var buf bytes.Buffer
		tpl := template.Must(template.New("scripts").Parse(scripts))
		tpl.Execute(&buf, combine)
		startSuffixIndex := strings.Index(key, ".")
		nameWithoutSuffix := key[:startSuffixIndex]
		src := "/Users/thaidzai/code/go/src/gido.vn/gic/demo/test_sqitch/gido-v1.0/schema/tables/" + key
		dst := "/Users/thaidzai/code/go/src/gido.vn/gic/demo/test_sqitch/gido-v1.0/schema/tables/" + nameWithoutSuffix + ".model.yml"
		if _, err := os.Stat(src); !os.IsNotExist(err) {
			err := os.Rename(src, dst)
			utilities.HandlePanic(err, "Change filename failed")

		}

		err := ioutil.WriteFile(dst, buf.Bytes(), os.ModePerm)
		utilities.HandlePanic(err, "Write file failed")
	}
}
