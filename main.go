package main

import (
	"flag"
	"os"

	tableGen "gido.vn/gic/databases/sqitch.git/scripts/gen"
	"gido.vn/gic/libs/common.git/l"
)

var (
	flConfigFile = flag.String("schema", "", "Path to schema configuration")
	ll           = l.New()
)

func main() {
	flag.Parse()

	if *flConfigFile == "" {
		ll.Error("Error schema file not found")
		os.Exit(0)
	}

	tableGen.Exec(*flConfigFile)
}
