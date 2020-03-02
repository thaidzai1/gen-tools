package tpldiff

// Diff ...
const Diff = `
+-- Alter Tables
{{- if .AlterTables}}
{{- range .AlterTables}}
+-- {{.Name}}
|   +-- fields:
{{- range $fieldIndex, $field := .Fields }}{{$arrChanges := DetectChanges $field}}
|   |  +-- {{$field.Name}}
{{- range $changeIdx, $change := $arrChanges}}
|   |  |   +-- {{$change}}{{- end}}
{{- end}}
{{- end}}
{{else}}
Nothing changes
{{- end}}

+-- New Tables
{{- if .Tables}}
{{- range .Tables}}
+-- {{.TableName}}
|   +-- fields:
{{- range $fieldIndex, $field := .Fields}}{{$arrChanges := DetectChanges $field}}
{{- if not $field.SkipInDB}}
|   |   +-- {{$field.Name}}
|   |   |   +-- type: {{$field.Type}}
|   |   |   +-- primary: {{$field.Primary}}
|   |   |   +-- not_null: {{$field.NotNull}}
|   |   |   +-- unique: {{$field.Unique}}
|   |   |   +-- Default: {{$field.Default}}
{{- end}}
{{- end}}
|  +-- indexs:
{{- range $i, $index := .Indexs}}
|   |   +-- {{$index.Name}}
|   |   |   +-- key: {{$index.Key}}
|   |   |   +-- using: {{$index.Using}}
{{- end}}
|   +-- histories:
{{- range $i, $history := .Histories}}
{{- if $history.IsNoneFields}}
|   |   +-- None fields
{{else}}
|   |   +-- {{$history.Name}}
{{- end}}
{{- end}}
{{- end}}
{{else}}
Nothing changes
{{- end}}

+-- Drop Tables
{{- if .DropTables.Tables}}
{{- range $index, $table := .DropTables.Tables}}
|   +-- {{$table}}
{{- end}}
{{else}}
Nothing changes
{{- end}}
+--------------------------------------------------------------------+
`
