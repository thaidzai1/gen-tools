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
}

var (
	ll = l.New()
)

func main() {
	file, err := os.Open(gen.GetAbsPath("gic/sqitch/sql2yml/backup.sql"))
	if err != nil {
		fmt.Printf("Error open file: %v\n", err)
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)

	table := make(map[string]*Table)
	isFetchingFields := false
	var tableKeyword string
	for scanner.Scan() {
		line := scanner.Text()
		startKeyword := "CREATE TABLE"
		endKeyword := ");"
		indexKeyword := "CREATE INDEX"
		uniqueIndexKeword := "CREATE UNIQUE INDEX"

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

		if strings.Index(line, endKeyword) > -1 {
			isFetchingFields = false
		}

		if strings.Index(line, uniqueIndexKeword) > -1 {
			data := strings.Fields(line)
			indexName := data[2]
			var tableName string
			for _, dt := range data {
				if strings.Index(dt, "public.") > -1 {
					tableName = strings.ReplaceAll(dt, "public.", "")
				}
			}

			dataLength := len(data)
			key := data[dataLength-1][1 : len(data[dataLength-1])-2]
			index := Index{
				Name:   indexName,
				Key:    key,
				Unique: true,
			}

			table[tableName].Indexs = append(table[tableName].Indexs, index)
			continue
		}

		if strings.Index(line, indexKeyword) > -1 {
			data := strings.Fields(line)
			ll.Print("data: ", data)
			indexName := data[2]
			var tableName string
			for _, dt := range data {
				if strings.Index(dt, "public.") > -1 {
					tableName = strings.ReplaceAll(dt, "public.", "")
				}
			}

			dataLength := len(data)
			key := data[dataLength-1][1 : len(data[dataLength-1])-2]
			index := Index{
				Name: indexName,
				Key:  key,
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
			table[tableKeyword].Fields = append(table[tableKeyword].Fields, fields)
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
{{- if $index.Unique}}
    unique: true
{{- end}}
{{- end}}
{{- end}}
`

		var buf bytes.Buffer
		tpl := template.Must(template.New("scripts").Parse(script))
		tpl.Execute(&buf, &table)
		dir := gen.GetAbsPath("gic/sqitch/scripts/gen/schema/tables/")
		absPath := gen.GetAbsPath(dir + "/" + table.Name + ".yml")
		ll.Print("absPath: ", absPath)
		err := ioutil.WriteFile(absPath, buf.Bytes(), os.ModePerm)
		if err != nil {
			fmt.Printf("Error write file failed, %v\n", err)
		}
	}
}
