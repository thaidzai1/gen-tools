package main

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

	"gido.vn/gic/databases/sqitch.git/src/middlewares"
	"gido.vn/gic/databases/sqitch.git/src/models"
	"gido.vn/gic/databases/sqitch.git/src/sqitch-gen/load"
	tplsql "gido.vn/gic/databases/sqitch.git/src/sqitch-gen/templates"
	"gido.vn/gic/databases/sqitch.git/src/utilities"
	"gido.vn/gic/libs/common.git/l"
	"gopkg.in/yaml.v2"
)

var (
	projectPath, _            = os.Getwd()
	gopath                    string
	planName                  string
	ll                        = l.New()
	flConfigFile              = flag.String("schema", "", "Path to schema configuration")
	inputMigrationName        = flag.String("name", "", "Migration's name")
	inputMigrationDescription = flag.String("d", "Add schema", "Migration's description")
)

// Exec ...
func main() {
	flag.Parse()

	if *flConfigFile == "" {
		ll.Error("Error schema file not found")
		os.Exit(0)
	}

	migrationSchema := load.GetMigrateSchema(*flConfigFile)

	if len(migrationSchema.Tables) != 0 || len(migrationSchema.AlterTables) != 0 || migrationSchema.Triggers != "" || len(migrationSchema.DropTables.Tables) != 0 {
		if *inputMigrationName == "" {
			createNewSqitchPlan(startNewSqitchPlan())
		} else {
			planName = *inputMigrationName
			createNewSqitchPlan(planName, *inputMigrationDescription)
		}
		middlewares.GenerateSQL(migrationSchema, generateDeploySQLScript, migrationSchema)
		markGeneratedTriggerFiles(*flConfigFile)
	}
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
	templateFuncMap := template.FuncMap{
		"lengthMinusOne":                lengthMinusOne,
		"checkNotUserIDOrActionAdminID": checkNotUserIDOrActionAdminID,
	}
	var buf bytes.Buffer
	tpl := template.Must(template.New("scripts").Funcs(templateFuncMap).Parse(tplsql.Deploy))
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
	data, err := ioutil.ReadFile(schemaPath)
	utilities.HandlePanic(err, "read file config schema failed")

	var dbSchema models.SchemaConfig
	err = yaml.Unmarshal(data, &dbSchema)
	utilities.HandlePanic(err, "Decoding file config schema failed")

	pathFunctions := dbSchema.Schemas["functions"]
	pathGeneratedFunctions := dbSchema.Schemas["generated_functions"]

	functionFiles, err := ioutil.ReadDir(pathFunctions)
	utilities.HandlePanic(err, "Read function dir failed")

	generatedFuncsLog, err := ioutil.ReadFile(pathGeneratedFunctions)
	utilities.HandlePanic(err, "Read file generated functions config file failed")

	var generatedFuncsDef models.GeneratedFunctions
	err = yaml.Unmarshal(generatedFuncsLog, &generatedFuncsDef)
	utilities.HandlePanic(err, "Decoding generated function config file failed")

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
	err = ioutil.WriteFile(pathGeneratedFunctions, buf.Bytes(), os.ModePerm)
	if err != nil {
		ll.Panic("Error write file failed, %v\n", l.Error(err))
	}
	ll.Info("==> Update generated functions DONE †")
}
