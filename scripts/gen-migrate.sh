#!/bin/bash
echo "Start Generate Migrate Plan..."
go run $GOPATH/src/gido.vn/gic/databases/sqitch.git/scripts/migrate-gen.go
echo "DONE"