package main

import (
	"flag"
	"html/template"
	"os"

	"gido.vn/gic/databases/sqitch.git/src/models"
	tpldiff "gido.vn/gic/databases/sqitch.git/src/sqitch-diff/templates"
	"gido.vn/gic/databases/sqitch.git/src/sqitch-gen/load"
	"gido.vn/gic/databases/sqitch.git/src/utilities"
	"gido.vn/gic/libs/common.git/l"
)

var (
	ll           = l.New()
	flConfigFile = flag.String("schema", "", "Path to schema configuration")
)

func main() {
	flag.Parse()

	if *flConfigFile == "" {
		ll.Error("Error schema file not found")
		os.Exit(0)
	}

	migrateSchema := load.GetMigrateSchema(*flConfigFile)

	tpl := template.Must(template.New("scripts").Funcs(templateFuncMap(migrateSchema)).Parse(tpldiff.Diff))
	tpl.Execute(os.Stdout, migrateSchema)
	ll.Info("==> Update generated functions DONE †")
}

func templateFuncMap(migrateSchema *models.MigrateSchema) template.FuncMap {
	return template.FuncMap{
		"DetectChanges": utilities.DetectChanges,
	}
}
