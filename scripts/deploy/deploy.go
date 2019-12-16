package main

import (
	"bytes"
	"flag"
	"io/ioutil"
	"os"
	"os/exec"
	"strings"

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
	ll           = l.New()
	flConfigFile = flag.String("config-file", "", "Path to config file")
	cfg          dbConfig
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

	// Load config
	if *flConfigFile == "" {
		cfg = defaultConfig()
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

	if !strings.Contains(outStr, "not ok") {
		deployNothingKeyword := "Nothing to deploy"
		cmdLog := exec.Command("echo", outStr)
		cmdLog.Stdout = os.Stdout
		cmdLog.Run()
		if !strings.Contains(outStr, deployNothingKeyword) {
			copyAllYamlSchema()
			cmdLog = exec.Command("echo", "Update Restricted area DONE†...†\n")
			cmdLog.Stdout = os.Stdout
			cmdLog.Run()
		}
	} else {
		cmdLog := exec.Command("echo", "Deploy failed...\n", "Status: "+outStr, "\n Error: ", errStr)
		cmdLog.Stdout = os.Stdout
		cmdLog.Run()
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

func copyAllYamlSchema() {
	path := "./scripts/gen/schema/"
	cmd := exec.Command("cp", "-a", path+"tables", path+".restricted")
	cmd.Run()
}
