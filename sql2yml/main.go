package main

import (
	"bufio"
	"bytes"
	"fmt"
	"html/template"
	"io/ioutil"
	"os"
	"strings"

	"gicprime.com/sqitch/common/gen"
	"gicprime.com/sqitch/common/l"
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
	Name string
	Key  string
}

var (
	ll = l.New()
)

func main() {
	file, err := os.Open(gen.GetAbsPath("sql2yml/init_schema.sql"))
	if err != nil {
		fmt.Printf("Error open file: %v\n", err)
	}
	scanner := bufio.NewScanner(file)

	var table Table
	isFetchingFields := false
	for scanner.Scan() {
		line := scanner.Text()
		startKeyword := "CREATE TABLE IF NOT EXISTS"
		endKeyword := ");"
		indexKeyword := "CREATE INDEX IF NOT EXISTS"

		if strings.Index(line, indexKeyword) > -1 {
			fmt.Println("Indexs")
			data := strings.Fields(line)
			indexName := data[5]
			dataLength := len(data)
			key := data[dataLength-1][1 : len(data[dataLength-1])-2]
			index := Index{
				Name: indexName,
				Key:  key,
			}
			table.Indexs = append(table.Indexs, index)
			fmt.Printf("table Index: %v\n", table.Indexs)
			continue
		}

		if strings.Index(line, startKeyword) > -1 {
			// start generate previous table
			createYML(&table)
			table = Table{}

			// repair new table
			startTableNamePos := len(startKeyword)
			endTableNamePos := len(line) - 2
			tableName := line[startTableNamePos:endTableNamePos]
			if tableName[0] == 32 {
				tableName = strings.ReplaceAll(tableName, "\"", "")
			}
			table.Name = strings.TrimSpace(tableName)
			isFetchingFields = true
			continue
		}

		if strings.Index(line, endKeyword) > -1 {
			isFetchingFields = false
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
					fields.Type = d
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
			// fmt.Printf("Fields: %v----\v", fields)
			table.Fields = append(table.Fields, fields)
		}
	}
	// fmt.Printf("==> Full table: %v\n", table)
}

func createYML(table *Table) {
	ll.Print("table name: ", table.Name)
	ll.Print("table: ", table.Indexs)
	if table.Name != "" {
		script := `
version: 1
version_name: 1 - Init

{{- if $.Fields}}
fields:
{{- range $index, $field := $.Fields}}
  - name: {{$field.Name}}
    type: {{$field.Type}}
{{- if eq $field.Primary true}}
    primary: true
{{- end}}
{{- if eq $field.NotNull true}}
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
{{- end}}
{{- end}}
`

		var buf bytes.Buffer
		tpl := template.Must(template.New("scripts").Parse(script))
		tpl.Execute(&buf, &table)
		dir := gen.GetAbsPath("scripts/gen/schema/tables/")
		absPath := gen.GetAbsPath(dir + "/" + table.Name + ".yml")
		ll.Print("absPath: ", absPath)
		err := ioutil.WriteFile(absPath, buf.Bytes(), os.ModePerm)
		if err != nil {
			fmt.Printf("Error write file failed, %v\n", err)
		}
	}
}
