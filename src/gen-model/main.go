package main

import (
	"flag"

	"gido.vn/gic/databases/sqitch.git/src/gen-model/load"
	"gido.vn/gic/libs/common.git/l"
)

var (
	ll               = l.New()
	flConfigFilePath = flag.String("schema", "", "Path to schema configuration")
)

func main() {
	flag.Parse()

	if *flConfigFilePath == "" {
		ll.Panic("schema file path is required, use '-schema' to import schema file")
	}
	load.Defination(*flConfigFilePath)
}
