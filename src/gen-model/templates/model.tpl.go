package tplmodel

// Model ...
const Model = `
type {{$.Model.Name}} struct {
{{- range $index, $field := $.Fields}}
	{{ToCamel $field.Name}} {{ConvertGoTypeToDbType $field.GoType}} {{GenFieldTag $field}}
{{- end}}
}


func ({{$.Model.Name}}) TableName() string {
	return "{{ToSnakeCase $.Model.Name}}"
}

{{- if eq .Model.KeyField "id"}}{{- if eq .Model.KeyType "int64"}}
func (m *{{ToCamel .Model.Name}}) BeforeCreate(scope *gorm.Scope) error {
	m.ID = int64(common.NewID())
	return nil
}
{{- end}}{{- end}}

{{- if eq .Model.KeyField "code"}}
func (m *{{ToCamel .Model.Name}}) BeforeCreate(scope *gorm.Scope) error {
	if m.Code == "" {
		return errors.New("Required code")
	}
	return nil
}
{{- end}}

func ToSuccessPb{{TitleMany $.Model.Name}}Response(datas []*{{$.Model.Name}}, pi common.PageInfo) *pb.{{TitleMany $.Model.Name}}Response {
	return &pb.{{TitleMany $.Model.Name}}Response{
		E: &cm.Error{
			C: 0,
			M: "Success",
		},
		D: ToPb{{TitleMany $.Model.Name}}(datas),
		P: cm.ToPageInfo(pi),
	}
}

func ToSuccessOnePb{{TitleMany $.Model.Name}}Response(data *{{$.Model.Name}}) *pb.{{TitleMany $.Model.Name}}Response {
	return &pb.{{TitleMany $.Model.Name}}Response{
		E: &cm.Error{
			C: 0,
			M: "Success",
		},
		D: ToPb{{TitleMany $.Model.Name}}([]*{{$.Model.Name}}{data}),
		P: &cm.PageInfo{
			T: 1,
		},
	}
}

func ToPb{{TitleMany $.Model.Name}}(datas []*{{$.Model.Name}}) []*pb.{{$.Model.Name}} {
	pbDatas := make([]*pb.{{$.Model.Name}}, len(datas))
	for i, data := range datas {
		pbDatas[i] = ToPb{{$.Model.Name}}(data)
	}
	return pbDatas
}

func ToPb{{$.Model.Name}}(data *{{$.Model.Name}}) *pb.{{$.Model.Name}} {
	pbData := &pb.{{$.Model.Name}}{
	{{- range .Fields}}{{- if and (ne .Name "RID") (ne .Name "ActionAdminID") (not .SkipInProto)}}
	{{- if eq .Name "Active"}}
		Active: data.IsActive(),
	{{- else }}
	{{- if eq .Ref ""}}
		{{- if eq .Type "jsonb"}}
		{{ToTitleNorm .Name}}: {{ToProtoField . "data"}}.RawMessage,
		{{else}}
		{{ToTitleNorm .Name}}: {{ToProtoField . "data"}},
		{{- end}}
	{{- end}}
	{{- end}}
	{{- end}}
	{{- end}}
	}
	return pbData
}
`

// Header ...
const Header = `
// Code generated by gen-model. DO NOT EDIT.
package model

import (
	"errors"
	
	pb "gido.vn/gic/grpc-protos/pship.git"
	cm "gido.vn/gic/grpc-protos/common.git"
	"gido.vn/gic/libs/common.git"
	"gido.vn/gic/libs/database.git/postgres"
	diaPostgres "github.com/jinzhu/gorm/dialects/postgres"
)
`
