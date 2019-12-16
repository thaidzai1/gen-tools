package main

import (
	"flag"

	tableGen "gido.vn/gic/databases/sqitch.git/scripts/gen"
	"gido.vn/gic/libs/common.git/l"
)

var (
	// inputPath    = "gic/databases/sqitch.git/scripts/gen/schema/schema.yml"
	flConfigFile = flag.String("schema", "", "-c")
	ll           = l.New()
)

func main() {
	flag.Parse()

	if flConfigFile == nil {
		ll.Panic("Error schema file not found")
	}

	tableGen.Exec(*flConfigFile)
}
