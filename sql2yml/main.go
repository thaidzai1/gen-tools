package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"text/template"

	"gido.vn/gic/libs/common.git/gen"
	"gido.vn/gic/libs/common.git/l"
)

type Table struct {
	Name   string
	Fields []Field
	Indexs []Index
}

type Field struct {
	Name    string
	Type    string
	Primary bool
	NotNull bool
	Unique  bool
}

type Index struct {
	Name   string
	Key    string
	Unique bool
	Using  string
}

var (
	ll = l.New()
)

func main() {
	file, err := os.Open(gen.GetAbsPath("gic/databases/sqitch.git/sql2yml/backup.sql"))
	if err != nil {
		fmt.Printf("Error open file: %v\n", err)
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)

	table := make(map[string]*Table)
	isFetchingFields := false
	isUpdatingField := false
	var tableKeyword string
	for scanner.Scan() {
		line := scanner.Text()
		startKeyword := "CREATE TABLE"
		endKeyword := ";"
		indexKeyword := "CREATE INDEX"
		uniqueIndexKeword := "CREATE UNIQUE INDEX"
		alterKeyword := "ALTER TABLE ONLY"

		if strings.Index(line, startKeyword) > -1 {
			startTableNamePos := len(startKeyword)
			endTableNamePos := len(line) - 2
			tableKeyword = line[startTableNamePos:endTableNamePos]
			tableKeyword = strings.ReplaceAll(tableKeyword, "public.", "")
			tableKeyword = strings.TrimSpace(tableKeyword)

			table[tableKeyword] = &Table{}
			table[tableKeyword].Name = tableKeyword

			isFetchingFields = true
			continue
		}

		if strings.Index(line, alterKeyword) > -1 {
			data := strings.Fields(line)
			lastElement := data[len(data)-1]
			if strings.Contains(lastElement, "public.") {
				tableKeyword = strings.ReplaceAll(lastElement, "public.", "")
			}

			isUpdatingField = true
			continue
		}

		if strings.Index(line, endKeyword) > -1 {
			isFetchingFields = false
		}

		if strings.Index(line, uniqueIndexKeword) > -1 {
			data := strings.Fields(line)
			indexName := data[3]
			var tableName string
			var usingKeyword string
			var key string
			for index, dt := range data {
				if strings.Index(dt, "public.") > -1 {
					tableName = strings.ReplaceAll(dt, "public.", "")
				}
				if dt == "USING" {
					usingKeyword = data[index+1]
				}
			}

			keyStartPos := strings.Index(line, "(")
			if keyStartPos > -1 {
				key = line[keyStartPos+1 : len(line)-2]
			}

			index := Index{
				Name:   indexName,
				Key:    key,
				Unique: true,
				Using:  usingKeyword,
			}

			table[tableName].Indexs = append(table[tableName].Indexs, index)
			continue
		}

		if strings.Index(line, indexKeyword) > -1 {
			data := strings.Fields(line)
			indexName := data[2]
			var tableName string
			var usingKeyword string
			var key string
			for index, dt := range data {
				if strings.Index(dt, "public.") > -1 {
					tableName = strings.ReplaceAll(dt, "public.", "")
				}
				if dt == "USING" {
					usingKeyword = data[index+1]
				}
			}

			keyStartPos := strings.Index(line, "(")
			if keyStartPos > -1 {
				key = line[keyStartPos+1 : len(line)-2]
			}

			index := Index{
				Name:  indexName,
				Key:   key,
				Using: usingKeyword,
			}

			table[tableName].Indexs = append(table[tableName].Indexs, index)
			continue
		}

		if isFetchingFields && len(line) > 0 {
			lineWithoutWhiteSpace := strings.TrimSpace(line)
			if strings.Index(lineWithoutWhiteSpace, ",") > -1 {
				lineWithoutWhiteSpace = lineWithoutWhiteSpace[:len(lineWithoutWhiteSpace)-1]
			}
			data := strings.Fields(lineWithoutWhiteSpace)

			var fields Field
			for index, d := range data {
				if index == 0 {
					fields.Name = d
				} else if index == 1 {
					if d == "double" {
						fields.Type = "double precision"
					} else {
						fields.Type = d
					}
				} else {
					switch d {
					case "PRIMARY":
						fields.Primary = true
						break
					case "NULL":
						fields.NotNull = true
						break
					case "Unique":
						fields.Unique = true
						break
					default:
						break
					}
				}
			}
			table[tableKeyword].Fields = append(table[tableKeyword].Fields, fields)
		}

		if isUpdatingField && len(line) > 0 {
			fieldNamePos := strings.Index(line, "(")
			shouldUpdate := false
			var updatedProperty string
			if strings.Contains(line, "PRIMARY") {
				updatedProperty = "PRIMARY"
				shouldUpdate = true
			} else if strings.Contains(line, "UNIQUE") {
				updatedProperty = "UNIQUE"
				shouldUpdate = true
			}
			if fieldNamePos > -1 && shouldUpdate {
				fieldName := line[fieldNamePos+1 : len(line)-2]
				for index, field := range table[tableKeyword].Fields {
					ll.Print("checkfield: ", field.Name, fieldName)
					if field.Name == fieldName {
						switch updatedProperty {
						case "PRIMARY":
							table[tableKeyword].Fields[index].Primary = true
							break
						case "UNIQUE":
							table[tableKeyword].Fields[index].Unique = true
							break
						default:
							break
						}
					}
					ll.Print("Field update: ", field)
				}
			}

			ll.Print("Table update: ", table[tableKeyword])
			isUpdatingField = false
		}
	}
	createYML(table)
	// fmt.Printf("==> Full table: %v\n", table)
}

func createYML(tables map[string]*Table) {
	for _, table := range tables {
		script := `
version: 1
version_name: 1 - Init

{{- if $.Fields}}
fields:
{{- range $index, $field := $.Fields}}
  - name: {{$field.Name}}
    old_name:
    type: {{$field.Type}}
{{- if eq $field.Primary true}}
    primary: true
{{- end}}
{{- if $field.NotNull}}
    not_null: true
{{- end}}
{{- if eq $field.Unique true}}
    unique: true
{{- end}}
{{- end}}
{{- end}}

{{- if $.Indexs}}
indexs:
{{- range $i, $index := $.Indexs}}
  - name: {{$index.Name}}
    key: {{$index.Key}}
    using: {{$index.Using}}
{{- if $index.Unique}}
    unique: true
{{- end}}
{{- end}}
{{- end}}

drop_fields:
#  -name: fieldname
#  -name: fieldname
`

		var buf bytes.Buffer
		tpl := template.Must(template.New("scripts").Parse(script))
		tpl.Execute(&buf, &table)
		dir := gen.GetAbsPath("gic/databases/sqitch.git/scripts/gen/schema/tables/")
		absPath := gen.GetAbsPath(dir + "/" + table.Name + ".yml")
		ll.Print("absPath: ", absPath)
		err := ioutil.WriteFile(absPath, buf.Bytes(), os.ModePerm)
		if err != nil {
			fmt.Printf("Error write file failed, %v\n", err)
		}
	}
}
