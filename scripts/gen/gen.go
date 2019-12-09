package gen

import (
	"bufio"
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"strings"
	"text/template"

	"gicprime.com/sqitch/common/gen"
	"gicprime.com/sqitch/common/l"
	"gicprime.com/sqitch/scripts/gen/load"
)

var (
	projectPath string
	gopath      string
	planName    string
	ll          = l.New()
)

// Exec...
func Exec(inputPath string) {
	genSchemaDefinations := load.LoadSchemaDefination(inputPath)
	fmt.Printf("dbSchema: %v\n", genSchemaDefinations)
	fmt.Printf("inputPath: %v\n", inputPath)

	CreateNewSqitchPlan(StartNewSqitchPlan())
	GenerateSQLScript(genSchemaDefinations)
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
	cmd := exec.Command("sqitch", "add", planName, "-n", `Add schema ${planName}`)
	ll.Info("Run sqitch add plan... Done†")
	cmd.Run()
}

func GenerateSQLScript(table *[]load.TableDefination) {
	var script string = `
BEGIN;

{{- range $index, $table := .}}
CREATE TABLE IF NOT EXISTS {{$table.TableName}} (
{{- range $index, $field := $table.Fields}}
	{{$field.Name}} {{$field.Type}} 
{{- if eq $field.Primary true}} PRIMARY {{- end}}
{{- if eq $field.NotNull true}} NOT NULL {{- end}}
{{- if eq $field.Unique true}} Unique {{- end}}
{{- end}}
);

{{- if $table.Indexs}}
{{- range $i, $index := $table.Indexs}}
CREATE INDEX IF NOT EXISTS {{$index.Name}} ON "{{$table.TableName}}" ({{$index.Key}});
{{- end}}
{{- end}}
{{- end}}
COMMIT;
`

	var buf bytes.Buffer
	tpl := template.Must(template.New("scripts").Parse(script))
	tpl.Execute(&buf, &table)
	dir := gen.GetAbsPath("deploy/")
	absPath := gen.GetAbsPath(dir + "/" + planName + ".sql")
	ll.Print("absPath: ", absPath)
	err := ioutil.WriteFile(absPath, buf.Bytes(), os.ModePerm)
	if err != nil {
		fmt.Printf("Error write file failed, %v\n", err)
	}
}
