package main

import (
	"bytes"
	"flag"
	"io/ioutil"
	"os"
	"os/exec"
	"strings"

	"gido.vn/gic/databases/sqitch.git/src/models"
	"gido.vn/gic/libs/common.git/l"
	"gopkg.in/yaml.v2"
)

type dbConfig struct {
	Type     string `yaml:"type"`
	Username string `yaml:"username"`
	Password string `yaml:"password"`
	Host     string `yaml:"host"`
	Port     string `yaml:"port"`
	DBName   string `yaml:"db_name"`
}

var (
	ll             = l.New()
	flConfigPath   = flag.String("schema", "", "Path to schema config file")
	flConfigFile   = flag.String("config-file", "", "Path to database config file")
	cfg            dbConfig
	projectPath, _ = os.Getwd()
)

func defaultConfig() dbConfig {
	return dbConfig{
		Type:     "postgres",
		Username: "gido_stag",
		Password: "mhh42mw0IYFQx7w3aENAh",
		Host:     "35.220.166.103",
		Port:     "5432",
		DBName:   "gido_stag",
	}
}

func defaultTestConfig() dbConfig {
	return dbConfig{
		Type:     "postgres",
		Username: "gido_stag",
		Password: "mhh42mw0IYFQx7w3aENAh",
		Host:     "35.220.166.103",
		Port:     "5432",
		DBName:   "gido_test_sqitch_dev",
	}
}

func main() {
	flag.Parse()

	if *flConfigPath == "" {
		ll.Error("Error schema folder not found")
		os.Exit(0)
	}

	// Load config
	if *flConfigFile == "" {
		cfg = defaultTestConfig()
	} else {
		err := load(*flConfigFile, &cfg)
		if err != nil {
			ll.Fatal("Unable to load config", l.Error(err))
		}
	}

	cmd := exec.Command("sqitch", "deploy", "db:"+cfg.Type+"://"+cfg.Username+":"+cfg.Password+"@"+cfg.Host+":"+cfg.Port+"/"+cfg.DBName)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	cmd.Run()
	outStr, errStr := string(stdout.Bytes()), string(stderr.Bytes())

	if len(outStr) > 0 && !strings.Contains(outStr, "not ok") {
		deployNothingKeyword := "Nothing to deploy"
		cmdLog := exec.Command("echo", outStr)
		cmdLog.Stdout = os.Stdout
		cmdLog.Run()
		if !strings.Contains(outStr, deployNothingKeyword) {
			moveDroppedYamlSchema(*flConfigPath)
			copyAllYamlSchema(*flConfigPath)
			cmdLog = exec.Command("echo", "Update Restricted area DONE†...†\n")
			cmdLog.Stdout = os.Stdout
			cmdLog.Run()
		}
	} else {
		cmdLog := exec.Command("echo", "Deploy failed...\n", "Status: "+outStr, "\n Error: ", errStr)
		cmdLog.Stdout = os.Stdout
		cmdLog.Run()
		os.Exit(0)
	}
}

func load(configPath string, v interface{}) (err error) {
	data, err := ioutil.ReadFile(configPath)
	if err != nil {
		ll.Error("Error loading config", l.String("file", configPath), l.Error(err))
		return err
	}

	err = yaml.Unmarshal(data, v)
	if err != nil {
		ll.Error("Error parsing config", l.String("file", configPath), l.Error(err))
		return err
	}
	ll.Info("Service started with config", l.Object("\nconfig", v))
	return
}

func copyAllYamlSchema(schemaPath string) {
	data, err := ioutil.ReadFile(schemaPath)
	if err != nil {
		ll.Panic("Error load schema yml failed")
	}

	var dbSchema models.SchemaConfig
	err = yaml.Unmarshal(data, &dbSchema)

	pathTables := dbSchema.Schemas["tables"]
	pathRestricted := dbSchema.Schemas["curr_tables"]

	cmd := exec.Command("cp", "-r", projectPath+"/"+pathTables+"/.", projectPath+"/"+pathRestricted)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err = cmd.Run()
	outStr, errStr := string(stdout.Bytes()), string(stderr.Bytes())

	if err != nil {
		ll.Print("Output: ", outStr)
		ll.Print("Error: ", errStr)
		ll.Panic("Error when copy tables to .restricted: ", l.Error(err))
	}
}

func moveDroppedYamlSchema(schemaPath string) {
	data, err := ioutil.ReadFile(schemaPath)
	if err != nil {
		ll.Panic("Error load schema yml failed")
	}

	var dbSchema models.SchemaConfig
	err = yaml.Unmarshal(data, &dbSchema)

	pathTables := dbSchema.Schemas["tables"]
	pathRestricted := dbSchema.Schemas["dropped_tables"]
	pathDropTableConfigFile := dbSchema.Schemas["dropped_tables_config"]

	var droppedTablesDef models.DropTables
	dropConfigFileName := "dropped-tables.yml"
	dropTableData, err := ioutil.ReadFile(pathDropTableConfigFile + "/" + dropConfigFileName)
	if err != nil {
		ll.Panic("Error when read file config drop tables")
	}
	err = yaml.Unmarshal(dropTableData, &droppedTablesDef)

	tableFiles, err := ioutil.ReadDir(pathTables)
	if err != nil {
		ll.Panic("Error when read dir tables")
	}

	for _, table := range droppedTablesDef.Tables {
		for _, file := range tableFiles {
			var fileNameWithoutSuffix string
			if strings.Contains(file.Name(), ".yaml") {
				fileNameWithoutSuffix = strings.ReplaceAll(file.Name(), ".yaml", "")
			} else if strings.Contains(file.Name(), ".yml") {
				fileNameWithoutSuffix = strings.ReplaceAll(file.Name(), ".yml", "")
			} else {
				continue
			}

			if fileNameWithoutSuffix == table {
				cmd := exec.Command("mv", pathTables+"/"+file.Name(), pathRestricted+"/"+file.Name())
				cmd.Run()
			}
		}
	}
}
