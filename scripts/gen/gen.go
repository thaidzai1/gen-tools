package gen

import (
	"bufio"
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"reflect"
	"strconv"
	"strings"
	"text/template"

	"gido.vn/gic/databases/sqitch.git/scripts/gen/load"
	"gido.vn/gic/databases/sqitch.git/scripts/gen/middlewares"
	"gido.vn/gic/databases/sqitch.git/scripts/gen/models"
	"gido.vn/gic/libs/common.git/l"
)

var (
	projectPath, _ = os.Getwd()
	gopath         string
	planName       string
	ll             = l.New()
)

// Exec ...
func Exec(inputPath string) {
	createNewSqitchPlan(startNewSqitchPlan())
	genSchemaDefinations := load.LoadSchemaDefination(inputPath, planName)
	middlewares.GenerateSQL(genSchemaDefinations, generateDeploySQLScript, genSchemaDefinations)
}

func getPlanIndex() string {
	var planIndex string
	sqitchPlanPath := projectPath + "/sqitch.plan"
	file, err := os.Open(sqitchPlanPath)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var lastLine string

	for scanner.Scan() {
		lastLine = scanner.Text()
	}

	var index int64
	var prefixIndex string
	if len(lastLine) != 0 {
		index, _ = strconv.ParseInt(lastLine[0:3], 10, 64)
	} else {
		index = 0
	}
	switch {
	case index >= 9:
		prefixIndex = "0"
		break
	case index >= 99:
		prefixIndex = ""
		break
	default:
		prefixIndex = "00"
		break
	}
	planIndex = prefixIndex + strconv.FormatInt(index+1, 10)

	return planIndex
}

func genPlanNamePrefix(planIndex string) string {
	return planIndex + "-"
}

func startNewSqitchPlan() (string, string) {
	var note string

	reader := bufio.NewReader(os.Stdin)
	fmt.Printf("Enter migrate plan name : (For example: %v) ", genPlanNamePrefix(getPlanIndex())+"xxxxxx")
	planName, _ = reader.ReadString('\n')
	planName = strings.Replace(planName, "\n", "", -1)
	if len(planName) == 0 {
		ll.Error("Migration's name is required")
		os.Exit(0)
	}

	fmt.Printf("Enter migrate note :")
	note, _ = reader.ReadString('\n')
	note = strings.Replace(note, "\n", "", -1)
	if len(note) == 0 {
		note = "Add schema " + planName
	}

	return planName, note
}

func createNewSqitchPlan(planName string, note string) {
	ll.Print("createnewsqitch: ", planName, note)
	cmd := exec.Command("sqitch", "add", planName, "-n", note)
	ll.Info("Run sqitch add plan... Done†")
	cmd.Run()
}

func generateDeploySQLScript(migrate *models.MigrateSchema) {
	var script string = `
BEGIN;

{{- range $index, $table := $.AlterTables}}
{{$primaryKeyExisted := false }}
{{- range $fieldIndex, $field := $table.Fields}}
	{{- if not $field.IsNewField}}
		{{- if ne $field.Field.OldName ""}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			RENAME COLUMN {{$field.Field.OldName}} TO {{$field.Field.Name}};
		{{- end}}

		{{- if $field.IsPrimaryChanged}}
		 	{{- if not $primaryKeyExisted}}
				ALTER TABLE IF EXISTS {{$table.Name}} DROP CONSTRAINT {{$table.Name}}_pkey;
				{{- if $field.Field.Primary}}
				ALTER TABLE IF EXISTS {{$table.Name}} ADD PRIMARY KEY ({{$field.Field.Name}});
				{{- end}}
			{{- end}}
		{{- end}}

		{{- if $field.IsTypeChanged}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ALTER COLUMN {{$field.Field.Name}} TYPE {{$field.Field.Type}} USING {{$field.Field.Name}}::{{$field.Field.Type}};
		{{- end}}

		{{- if $field.IsNotNullChanged}}
			{{- if not $field.Field.Primary}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ALTER COLUMN {{$field.Field.Name}} {{- if $field.Field.NotNull}} SET{{else}} DROP{{- end}} NOT NULL;	
			{{- end}}
		{{- end}}

		{{- if $field.IsUniqueChanged}} 
		ALTER TABLE IF EXISTS {{$table.Name}}
			{{- if $field.Field.Unique}}
			ADD CONSTRAINT IF NOT EXISTS {{$table.Name}}_{{$field.Field.Name}}_key UNIQUE ({{$field.Field.Name}}); 
			{{else}}
			DROP CONSTRAINT IF EXISTS {{$table.Name}}_{{$field.Field.Name}}_key CASCADE; 
			{{- end}}
		{{- end}}

		{{- if $field.IsDefaultChanged}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			{{- if ne $field.Field.Default ""}}
			ALTER COLUMN {{$field.Field.Name}} SET DEFAULT '{{$field.Field.Default}}';
			{{else}}
			ALTER COLUMN {{$field.Field.Name}} DROP DEFAULT;
			{{- end}}
		{{- end}}

	{{else}}
	
	ALTER TABLE IF EXISTS {{$table.Name}}
		ADD COLUMN IF NOT EXISTS {{$field.Field.Name}} {{$field.Field.Type}};
		{{- if $field.Field.Primary}}
		{{$primaryKeyExisted = true}}
		ALTER TABLE IF EXISTS {{$table.Name}} DROP CONSTRAINT {{$table.Name}}_pkey;
		ALTER TABLE IF EXISTS {{$table.Name}} ADD PRIMARY KEY ({{$field.Field.Name}});
		{{- end}}
		
		{{- if not $field.Field.Primary}}
			{{- if $field.Field.NotNull}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ALTER COLUMN {{$field.Field.Name}} SET NOT NULL;	
			{{- end}}
		{{- end}}

		{{- if $field.Field.Unique}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ADD CONSTRAINT IF NOT EXISTS {{$table.Name}}_{{$field.Field.Name}}_key UNIQUE ({{$field.Field.Name}}); 	
		{{- end}}

		{{- if ne $field.Field.Default ""}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ALTER COLUMN {{$field.Field.Name}} SET DEFAULT '{{$field.Field.Default}}';
		{{- end}}
		
	{{- end}}
{{- end}}
{{- end}}

{{- range $index, $table := $.Tables}}
{{- if $table.Fields}}
CREATE TABLE IF NOT EXISTS {{$table.TableName}} (
{{- range $index, $field := $table.Fields}}
	{{$field.Name}} {{$field.Type}} 
{{- if eq $field.Primary true}} PRIMARY KEY {{- end}}
{{- if eq $field.NotNull true}} NOT NULL {{- end}}
{{- if eq $field.Unique true}} Unique {{- end}}{{$lengthMinusOne := lengthMinusOne $table.Fields}}{{- if lt $index $lengthMinusOne}},{{- end}}
{{- end}}
);
{{- end}}

{{- if $table.Indexs}}
{{- range $i, $index := $table.Indexs}}
CREATE {{- if eq $index.Unique true}} UNIQUE{{- end}} INDEX IF NOT EXISTS {{$index.Name}} ON "{{$table.TableName}}" USING {{$index.Using}} ({{$index.Key}});
{{- end}}
{{- end}}

{{- if $table.DropFields}}
{{- range $indexDropField, $dropField := $table.DropFields}}
ALTER TABLE IF EXISTS {{$table.TableName}}
	DROP COLUMN IF EXISTS {{$dropField.Name}} CASCADE;
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
	sqlPath := projectPath + "/deploy/" + planName + ".sql"
	err := ioutil.WriteFile(sqlPath, buf.Bytes(), os.ModePerm)
	if err != nil {
		ll.Error("Error write file failed, %v\n", l.Error(err))
	}
	ll.Info("==> Generate migrate deploy DONE†")
}

func lengthMinusOne(input interface{}) int {
	return reflect.ValueOf(input).Len() - 1
}
