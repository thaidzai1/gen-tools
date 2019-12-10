package gen

import (
	"bufio"
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"reflect"
	"strings"
	"text/template"

	"gido.vn/gic/libs/common.git/gen"
	"gido.vn/gic/libs/common.git/l"
	"gido.vn/gic/sqitch/scripts/gen/load"
)

var (
	projectPath string
	gopath      string
	planName    string
	ll          = l.New()
)

// Exec...
func Exec(inputPath string) {
	CreateNewSqitchPlan(StartNewSqitchPlan())
	genSchemaDefinations := load.LoadSchemaDefination(inputPath, planName)
	GenerateDeploySQLScript(genSchemaDefinations)
}

func StartNewSqitchPlan() string {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Enter migrate plan name: ")
	planName, _ = reader.ReadString('\n')
	planName = strings.Replace(planName, "\n", "", -1)

	return planName
}

func CreateNewSqitchPlan(planName string) {
	ll.Print("planName: ", planName)
	cmd := exec.Command("sqitch", "add", planName, "-n", "Add schema "+planName)
	ll.Info("Run sqitch add plan... Done†")
	cmd.Run()
}

func GenerateDeploySQLScript(migrate *load.MigrateSchema) {
	var script string = `
BEGIN;

{{- range $index, $table := $.Tables}}
CREATE TABLE IF NOT EXISTS {{$table.TableName}} (
{{- range $index, $field := $table.Fields}}
	{{$field.Name}} {{$field.Type}} 
{{- if eq $field.Primary true}} PRIMARY KEY {{- end}}
{{- if eq $field.NotNull true}} NOT NULL {{- end}}
{{- if eq $field.Unique true}} Unique {{- end}}{{$lengthMinusOne := lengthMinusOne $table.Fields}}{{- if lt $index $lengthMinusOne}},{{- end}}
{{- end}}
);

{{- if $table.Indexs}}
{{- range $i, $index := $table.Indexs}}
CREATE {{- if eq $index.Unique true}} UNIQUE{{- end}} INDEX IF NOT EXISTS {{$index.Name}} ON "{{$table.TableName}}" USING {{$index.Using}} ({{$index.Key}});
{{- end}}
{{- end}}
{{- end}}

/*-- TRIGGER BEGIN --*/
{{$.Triggers}}
/*-- TRIGGER END --*/

COMMIT;
`
	templateFuncMap := template.FuncMap{
		"lengthMinusOne": lengthMinusOne,
	}
	var buf bytes.Buffer
	tpl := template.Must(template.New("scripts").Funcs(templateFuncMap).Parse(script))
	tpl.Execute(&buf, &migrate)
	dir := gen.GetAbsPath("gic/sqitch/deploy/")
	absPath := gen.GetAbsPath(dir + "/" + planName + ".sql")
	err := ioutil.WriteFile(absPath, buf.Bytes(), os.ModePerm)
	if err != nil {
		ll.Error("Error write file failed, %v\n", l.Error(err))
	}

	ll.Print("==> Generate migrate deploy DONE†")
}

func lengthMinusOne(input interface{}) int {
	return reflect.ValueOf(input).Len() - 1
}
