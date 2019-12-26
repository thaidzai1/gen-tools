package gen

import (
	"bufio"
	"bytes"
	"flag"
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
	"gopkg.in/yaml.v2"
)

var (
	projectPath, _            = os.Getwd()
	gopath                    string
	planName                  string
	ll                        = l.New()
	inputMigrationName        = flag.String("name", "", "Migration's name")
	inputMigrationDescription = flag.String("d", "Add schema", "Migration's description")
)

// Exec ...
func Exec(inputPath string) {
	flag.Parse()

	if *inputMigrationName == "" {
		createNewSqitchPlan(startNewSqitchPlan())
	} else {
		planName = *inputMigrationName
		createNewSqitchPlan(planName, *inputMigrationDescription)
	}

	genSchemaDefinations := load.LoadSchemaDefination(inputPath, planName)
	middlewares.GenerateSQL(genSchemaDefinations, generateDeploySQLScript, genSchemaDefinations)
	markGeneratedTriggerFiles(inputPath)
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
	cmd := exec.Command("sqitch", "add", planName, "-n", note)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	outStr, errStr := string(stdout.Bytes()), string(stderr.Bytes())
	if err != nil {
		ll.Print("Output: ", outStr)
		ll.Print("Error: ", errStr)
		ll.Panic("Error when genenrate migration: ", l.Error(err))
	}
	ll.Info("Run sqitch add plan... Done†")
}

func generateDeploySQLScript(migrate *models.MigrateSchema) {
	var script string = `
BEGIN;

/*-- TRIGGER BEGIN --*/
{{$.Triggers}}
/*-- TRIGGER END --*/

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

		{{- if $field.IsDefaultChanged}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			{{- if ne $field.Field.Default ""}}
			ALTER COLUMN {{$field.Field.Name}} SET DEFAULT '{{$field.Field.Default}}';
		UPDATE {{$table.Name}} SET {{$field.Field.Name}} = '{{$field.Field.Default}}' WHERE {{$field.Field.Name}} IS NULL;
			{{else}}
			ALTER COLUMN {{$field.Field.Name}} DROP DEFAULT;
			{{- end}}
		{{- end}}

		{{- if $field.IsNotNullChanged}}
			{{- if not $field.Field.Primary}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ALTER COLUMN {{$field.Field.Name}} {{- if $field.Field.NotNull}} SET NOT NULL{{else}} DROP NOT NULL{{- end}};	
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

	{{else}}
	
	ALTER TABLE IF EXISTS {{$table.Name}}
		ADD COLUMN IF NOT EXISTS {{$field.Field.Name}} {{$field.Field.Type}};
		{{- if $field.Field.Primary}}
		{{$primaryKeyExisted = true}}
		ALTER TABLE IF EXISTS {{$table.Name}} DROP CONSTRAINT {{$table.Name}}_pkey;
		ALTER TABLE IF EXISTS {{$table.Name}} ADD PRIMARY KEY ({{$field.Field.Name}});
		{{- end}}

		{{- if ne $field.Field.Default ""}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ALTER COLUMN {{$field.Field.Name}} SET DEFAULT '{{$field.Field.Default}}';
		UPDATE {{$table.Name}} SET {{$field.Field.Name}} = '{{$field.Field.Default}}' WHERE {{$field.Field.Name}} IS NULL;
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
{{- if ne $field.Default ""}} DEFAULT '{{$field.Default}}' {{- end}}
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

{{- if or $table.Histories $table.IsHistoryNoneField}}
CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;
COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';
CREATE TABLE IF NOT EXISTS {{$table.TableName}}_history (
	id bigserial primary key,
	revision bigint,
	changes jsonb,
	{{$table.TableName}}_id bigint,
	{{- range $indexHistory, $history := $table.Histories}}
		{{- if checkNotUserIDOrActionAdminID $history.Name}}
	prev_{{$history.Name}} {{$history.Type}},
	curr_{{$history.Name}} {{$history.Type}},	
		{{else}}
	user_id bigint,	
		{{- end}}
	{{- end}}
	updated_at timestamptz DEFAULT 'now()'
);

ALTER TABLE {{$table.TableName}} ADD COLUMN rid bigint;

CREATE FUNCTION public.{{$table.TableName}}_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'INSERT') THEN
		INSERT INTO {{$table.TableName}}_history(
			revision, 
			{{$table.TableName}}_id, 
			{{- range $historyIndex, $history := $table.Histories}}
				{{- if checkNotUserIDOrActionAdminID $history.Name}}
			curr_{{$history.Name}}, 
				{{else}}
			user_id,
				{{- end}}
			{{- end}}
			changes
		)
        VALUES (
			NEW.rid, 
			NEW.id, 
			{{- range $historyIndex, $history := $table.Histories}}
				{{- if eq $history.Name "admin_action_id"}}
			NEW.action_admin_id,
				{{else if eq $history.Name "user_id"}}
			NEW.user_id,
				{{else}}
			NEW.{{$history.Name}},
				{{- end}}
			{{- end}}
			to_json(NEW)
		);
    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
		changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,{{- range $hisIndex, $history := $table.Histories}}{{- if eq $history.Name "action_admin_id"}}	action_admin_id{{else if eq $history.Name "user_id"}}user_id{{- end}}{{- end}}}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO {{$table.TableName}}_history(
			revision,
			{{$table.TableName}}_id,
			{{- range $hisIndex, $history := $table.Histories}}
				{{- if checkNotUserIDOrActionAdminID $history.Name}}
			prev_{{$history.Name}},
			curr_{{$history.Name}},
				{{else}}
			user_id,
				{{- end}}
			{{- end}} 
			changes
		)
        VALUES (
			NEW.rid, 
			NEW.id, 
			{{- range $hisIndex, $history := $table.Histories}}
				{{- if eq $history.Name "action_admin_id"}}
			NEW.action_admin_id,
				{{else if eq $history.Name "user_id"}}
			NEW.user_id,
				{{else}}
			OLD.{{$history.Name}},
			NEW.{{$history.Name}},
				{{- end}}
			{{- end}}
			changes
		);
    END IF;
    RETURN NULL;
END
$$;

CREATE SEQUENCE IF NOT EXISTS {{$table.TableName}}_history_seq;
CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.{{$table.TableName}} FOR EACH ROW EXECUTE PROCEDURE public.update_rid('{{$table.TableName}}_history_seq');
CREATE TRIGGER {{$table.TableName}}_history AFTER INSERT OR UPDATE ON public.{{$table.TableName}} FOR EACH ROW EXECUTE PROCEDURE public.{{$table.TableName}}_history();
{{- end}}
{{- end}}

{{- if $.DropTables.Tables}}
DROP TABLE IF EXISTS {{- range $dropIndex, $dropTable := $.DropTables.Tables}} {{$dropTable}}{{$lengthMinusOne := lengthMinusOne $.DropTables.Tables}}{{- if lt $dropIndex $lengthMinusOne}},{{- end}}{{- end}} CASCADE;
{{- end}}

COMMIT;
`
	templateFuncMap := template.FuncMap{
		"lengthMinusOne":                lengthMinusOne,
		"checkNotUserIDOrActionAdminID": checkNotUserIDOrActionAdminID,
	}
	var buf bytes.Buffer
	tpl := template.Must(template.New("scripts").Funcs(templateFuncMap).Parse(script))
	tpl.Execute(&buf, &migrate)
	sqlPath := projectPath + "/deploy/" + planName + ".sql"
	err := ioutil.WriteFile(sqlPath, buf.Bytes(), os.ModePerm)
	if err != nil {
		ll.Panic("Error write file failed, %v\n", l.Error(err))
	}
	ll.Info("==> Generate migrate deploy DONE†")
}

func lengthMinusOne(input interface{}) int {
	return reflect.ValueOf(input).Len() - 1
}

func checkNotUserIDOrActionAdminID(field string) bool {
	if field == "user_id" || field == "action_admin_id" {
		return false
	}

	return true
}

func markGeneratedTriggerFiles(schemaPath string) {
	ll.Print("schemaPath: ", schemaPath)
	data, err := ioutil.ReadFile(schemaPath)
	if err != nil {
		ll.Panic("Error load schema.yml failed", l.Error(err))
	}

	var dbSchema models.DBSchema
	err = yaml.Unmarshal(data, &dbSchema)
	if err != nil {
		ll.Panic("Error unmarshal schema.yml to Defination", l.Error(err))
	}

	pathFunctions := dbSchema.Schemas["functions"]
	pathGeneratedFunctions := dbSchema.Schemas["generated_functions"]

	functionFiles, err := ioutil.ReadDir(pathFunctions)
	if err != nil {
		ll.Panic("Error read dir functions", l.Error(err))
	}

	generatedFuncsLog, err := ioutil.ReadFile(pathGeneratedFunctions + "/" + "functions.yml")
	if err != nil {
		ll.Panic("Error read generated functions log: ", l.Error(err))
	}

	var generatedFuncsDef models.GeneratedFunctions
	err = yaml.Unmarshal(generatedFuncsLog, &generatedFuncsDef)
	if err != nil {
		ll.Panic("Error umarshal from yaml to generatedFuncDef failed: ", l.Error(err))
	}

	newGeneratedFilenames := generatedFuncsDef.FileName

	if len(functionFiles) > len(generatedFuncsDef.FileName) {
		for _, functionFile := range functionFiles {
			isGenerated := false
			for _, genereatedFunc := range generatedFuncsDef.FileName {
				if functionFile.Name() == genereatedFunc {
					isGenerated = true
				}
			}

			if !isGenerated {
				newGeneratedFilenames = append(newGeneratedFilenames, functionFile.Name())
			}
		}
	}

	var scripts string = `
functions:
{{- range $index, $fileName := $}}	
  - {{$fileName}}
{{- end}}
`

	var buf bytes.Buffer
	tpl := template.Must(template.New("scripts").Parse(scripts))
	tpl.Execute(&buf, &newGeneratedFilenames)
	err = ioutil.WriteFile(pathGeneratedFunctions+"/"+"functions.yml", buf.Bytes(), os.ModePerm)
	if err != nil {
		ll.Panic("Error write file failed, %v\n", l.Error(err))
	}
	ll.Info("==> Update generated functions DONE †")
}
