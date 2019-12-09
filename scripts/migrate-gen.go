package main

import (
	tableGen "gicprime.com/sqitch/scripts/gen"
)

const (
	inputPath = "scripts/gen/schema/schema.yml"
)

func main() {
	tableGen.Exec(inputPath)
}
