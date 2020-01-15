package tpldiff

// Diff ...
const Diff = `
+-- Alter Tables
{{- range .AlterTables}}+-- {{.Name}}
{{- range $fieldIndex, $field := .Fields }}{{$arrChanges := DetectChanges $field}}
|  +-- {{$field.Name}}
{{- range $changeIdx, $change := $arrChanges}}
|  |   +-- {{$change}}
{{- end}}
{{- end}}
{{- end}}
+--------------------------------------------------------------------+
`
