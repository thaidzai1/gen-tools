package main

import (
	tableGen "gido.vn/gic/databases/sqitch.git/scripts/gen"
)

const (
	inputPath = "gic/sqitch/scripts/gen/schema/schema.yml"
)

func main() {
	tableGen.Exec(inputPath)
}
