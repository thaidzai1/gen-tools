package tpl

// StoreBody ...
const StoreBody = `
type {{ToCamel .Model.Name}}Store struct {
	db postgres.DB
}

func New{{ToCamel .Model.Name}}Store(db postgres.DB) *{{ToCamel .Model.Name}}Store {
	return &{{ToCamel .Model.Name}}Store{
		db: db,
	}
}

{{- if eq .Model.KeyField "id"}}
func (s *{{ToCamel .Model.Name}}Store) GetByID(ID {{.Model.KeyType}}) (*model.{{ToCamel .Model.Name}}, error) {
	var data model.{{ToCamel .Model.Name}}
	err := s.db.First(&data, "id = ?", ID).Error
	return &data, err
}

func (s *{{ToCamel .Model.Name}}Store) GetByIDs(IDs []{{.Model.KeyType}}) (data []*model.{{ToCamel .Model.Name}}, err error) {
	err = s.db.Find(&data, "id in (?)", IDs).Error
	return
}
{{- end}}

{{- if eq .Model.KeyField "code"}}
func (s *{{ToCamel .Model.Name}}Store) GetByCode(code string) (*model.{{ToCamel .Model.Name}}, error) {
	var data model.{{ToCamel .Model.Name}}
	err := s.db.First(&data, "code = ?", code).Error
	return &data, err
}
{{- end}}

func (s *{{ToCamel .Model.Name}}Store) GetAll(f common.Filter, p common.Paging{{- if .Model.UserFilterField -}}, userID int64{{- end -}}) (data []*model.{{ToCamel .Model.Name}}, pi common.PageInfo, err error) {
	strFilter := ""
	var args []interface{}
	for k := range f {
		argsKey := []string{}
		if k == "q" {
			for i := 0; i < {{countQueryParams}} - 1; i++ {
				for _, v := range f[k] {
					args = append(args, "%"+v+"%")
				}
			}
		}
		for _, v := range f[k] {
			if k == "created_at" {
				continue
			}
			argsKey = append(argsKey, "?")
			if k == "q" {
				args = append(args, "%"+v+"%")
				continue
			} else {
				args = append(args, v)
			}
		}
		switch {
		case k == "q":
			if strFilter != "" {
				strFilter = fmt.Sprintf(" %s AND (
{{- range $filter := .Filters -}}{{- if eq $filter.Name "q" -}}
{{- range $index, $field := $filter.Fields -}}
{{- if eq $index 0 -}}
 UPPER(CAST({{ToSnakeCase $field}} AS TEXT)) LIKE ANY (array[%s]) 
{{- else -}}
 OR UPPER(CAST({{ToSnakeCase $field}} AS TEXT)) LIKE ANY (array[%s]) 
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}} )", 
					strFilter,
					{{- range $filter := .Filters -}}{{- if eq $filter.Name "q" -}}
					{{ $len := len $filter.Fields}}
					{{- range $index, $field := $filter.Fields -}}
					{{- if eq (inc $index) $len -}}
					strings.Join(argsKey, ",") 
					{{- else -}}
					strings.Join(argsKey, ","),
					{{- end -}}
					{{- end -}}
					{{- end -}}
					{{- end -}})
			} else {
				strFilter = fmt.Sprintf(" (
{{- range $filter := .Filters -}}{{- if eq $filter.Name "q" -}}
{{- range $index, $field := $filter.Fields -}}
{{- if eq $index 0 -}}
 UPPER(CAST({{ToSnakeCase $field}} AS TEXT)) LIKE ANY (array[%s]) 
{{- else -}}
 OR UPPER(CAST({{ToSnakeCase $field}} AS TEXT)) LIKE ANY (array[%s])
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}} )", 
					{{- range $filter := .Filters -}}{{- if eq $filter.Name "q" -}}
					{{ $len := len $filter.Fields}}
					{{- range $index, $field := $filter.Fields -}}
					{{- if eq (inc $index) $len -}}
					strings.Join(argsKey, ",") 
					{{- else -}}
					strings.Join(argsKey, ","),
					{{- end -}}
					{{- end -}}
					{{- end -}}
					{{- end -}})
			}
		case k == "created_at":
			strTimeFilter := ""
			if f[k][0] != "" && f[k][0] != "0" {
				minTime, err := strconv.ParseInt(f[k][0], 10, 64)
				if err != nil {
					ll.Error(err.Error())
				}
				if minTime > 0 {
					strTimeFilter += " created_at >= ? "
					args = append(args, common.FromMillis(minTime))
				}
			}
			if f[k][1] != "" && f[k][1] != "0" {
				maxTime, err := strconv.ParseInt(f[k][1], 10, 64)
				if err != nil {
					ll.Error(err.Error())
				}
				if maxTime > 0 {
					if strTimeFilter != "" {
						strTimeFilter += " AND created_at <= ? "
					} else {
						strTimeFilter += " created_at <= ? "
					}
					args = append(args, common.FromMillis(maxTime))
				}
			}
			if strFilter == "" {
				strFilter += strTimeFilter
			} else {
				strFilter = strFilter + " AND " + strTimeFilter
			}
		default:
			if strFilter != "" {
				strFilter = fmt.Sprintf(" %s AND UPPER(CAST(%s AS TEXT)) IN (%s) ", strFilter, k, strings.Join(argsKey, ","))
			} else {
				strFilter = fmt.Sprintf(" UPPER(CAST(%s AS TEXT)) IN (%s) ", k, strings.Join(argsKey, ","))
			}
		}
	}
	{{ if .Model.UserFilterField }}
	if userID == 0 {
		{{- if eq .Model.KeyField "id" -}}
		err = s.db.FindWithPaging(p, &pi).Find(&data, append([]interface{}{strFilter}, args...)...).Error
		{{- else -}}
		err = s.db.FindWithPagingCustom(p, &pi, "created_at").Find(&data, append([]interface{}{strFilter}, args...)...).Error
		{{- end }}
	} else {
		if strFilter != "" {
			{{- if eq .Model.KeyField "id" -}}
			err = s.db.FindWithPaging(p, &pi).
				Find(&data, append([]interface{}{"{{ToSnakeCase .Model.UserFilterField.Name}} = ? AND " + strFilter, userID}, args...)...).Error
			{{- else -}}
			err = s.db.FindWithPagingCustom(p, &pi, "created_at").
				Find(&data, append([]interface{}{"{{ToSnakeCase .Model.UserFilterField.Name}} = ? AND " + strFilter, userID}, args...)...).Error
			{{- end -}}
		} else {
			{{- if eq .Model.KeyField "id" -}}
			err = s.db.FindWithPaging(p, &pi).
				Find(&data, "{{ToSnakeCase .Model.UserFilterField.Name}} = ? ", userID).Error
			{{- else -}}
			err = s.db.FindWithPagingCustom(p, &pi, "created_at").
				Find(&data, "{{ToSnakeCase .Model.UserFilterField.Name}} = ? ", userID).Error
			{{- end -}}
		}
	}
{{ else }}
	{{- if eq .Model.KeyField "id" -}}
	err = s.db.FindWithPaging(p, &pi).Find(&data, append([]interface{}{strFilter}, args...)...).Error
	{{- else -}}
	err = s.db.FindWithPagingCustom(p, &pi, "created_at").Find(&data, append([]interface{}{strFilter}, args...)...).Error
	{{- end }}
{{ end }}
	return
}

`

// StoreHeader ...
const StoreHeader = `// Code generated by gen-model. DO NOT EDIT.
package store

import (
	"fmt"
	"strconv"
	"strings"

	"gido.vn/gic/libs/common.git"
	"gido.vn/gic/libs/database.git/postgres"
	"{{$.GoRepo}}/internal/model"
)
`
