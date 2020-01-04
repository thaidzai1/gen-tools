package gen

import (
	"bytes"
	"io/ioutil"
	"os"
	"os/exec"
	"text/template"

	tplmodel "gido.vn/gic/databases/sqitch.git/src/gen-model/templates"
	"gido.vn/gic/databases/sqitch.git/src/models"
	"gido.vn/gic/databases/sqitch.git/src/utilities"

	"gido.vn/gic/libs/common.git/l"
)

var (
	ll = l.New()
)

// Model ...
func Model(modelDef *models.ModelDefination, desPath string, modelFileName string) {
	ll.Print("modelDef: ", modelDef)
	var buf bytes.Buffer
	genHeader(&buf, modelDef)
	genBody(&buf, modelDef)

	modelPath := desPath + "/" + modelFileName + ".go"
	createFileAndWrite(modelPath, &buf)

	ll.Info("==> Generate model deploy DONE†")
}

func genHeader(buf *bytes.Buffer, modelDef *models.ModelDefination) {
	tpl := template.Must(template.New("scripts").Parse(tplmodel.Header))
	tpl.Execute(buf, modelDef)
}

func genBody(buf *bytes.Buffer, modelDef *models.ModelDefination) {
	tpl := template.Must(template.New("scripts").Funcs(templateFuncMap()).Parse(tplmodel.Model))
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
	}
}
