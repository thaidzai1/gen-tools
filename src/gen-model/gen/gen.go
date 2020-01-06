package gen

import (
	"bytes"
	"io/ioutil"
	"os"
	"os/exec"
	"text/template"

	tpl "gido.vn/gic/databases/sqitch.git/src/gen-model/templates"
	"gido.vn/gic/databases/sqitch.git/src/models"
	"gido.vn/gic/databases/sqitch.git/src/utilities"

	"gido.vn/gic/libs/common.git/l"
)

var (
	ll = l.New()
)

// Model ...
func Model(modelDef *models.ModelDefination, desPath string, modelFileName string) {
	var buf bytes.Buffer
	genModelHeader(&buf, modelDef)
	genModelBody(&buf, modelDef)

	modelPath := desPath + "/" + modelFileName + ".gen.go"
	createFileAndWrite(modelPath, &buf)

	ll.Info("==> Generate model DONE†")
}

// Store ...
func Store(modelDef *models.ModelDefination, desPath string, storeFileName string) {
	ll.Print("modelDef: ", modelDef)
	var buf bytes.Buffer
	genStoreHeader(&buf, modelDef)
	genStoreBody(&buf, modelDef)

	storePath := desPath + "/" + storeFileName + ".gen.go"
	createFileAndWrite(storePath, &buf)

	ll.Info("==> Generate store DONE †")
}

func genStoreHeader(buf *bytes.Buffer, modelDef *models.ModelDefination) {
	tpl := template.Must(template.New("scripts").Parse(tpl.StoreHeader))
	tpl.Execute(buf, modelDef)
}

func genStoreBody(buf *bytes.Buffer, modelDef *models.ModelDefination) {
	tpl := template.Must(template.New("scripts").Funcs(templateFuncMap()).Parse(tpl.StoreBody))
	tpl.Execute(buf, modelDef)
}

func genModelHeader(buf *bytes.Buffer, modelDef *models.ModelDefination) {
	tpl := template.Must(template.New("scripts").Parse(tpl.ModelHeader))
	tpl.Execute(buf, modelDef)
}

func genModelBody(buf *bytes.Buffer, modelDef *models.ModelDefination) {
	tpl := template.Must(template.New("scripts").Funcs(templateFuncMap()).Parse(tpl.ModelBody))
	tpl.Execute(buf, modelDef)
}

func createFileAndWrite(filePath string, buf *bytes.Buffer) {
	cmd := exec.Command("touch", filePath)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	outStr, errStr := string(stdout.Bytes()), string(stderr.Bytes())
	ll.Print("outStr: ", outStr)
	if err != nil {
		ll.Error("Error: create file model failed: " + filePath + "Error :::: " + errStr)
		ll.Panic("Error: create file model failed: ", l.Error(err))
	}

	err = ioutil.WriteFile(filePath, buf.Bytes(), os.ModePerm)
	utilities.HandlePanic(err, "Write file gen model failed")
}

func templateFuncMap() template.FuncMap {
	return template.FuncMap{
		"ToCamel":               utilities.ToCamel,
		"GenFieldTag":           utilities.GenFieldTag,
		"ToSnakeCase":           utilities.ToSnakeCase,
		"TitleMany":             utilities.TitleMany,
		"ConvertGoTypeToDbType": utilities.ConvertGoTypeToDbType,
		"ToTitleNorm":           utilities.ToTitleNorm,
		"ToProtoField":          utilities.ToProtoField,
		"countQueryParams":      models.CountFilterQueryParams,
	}
}
