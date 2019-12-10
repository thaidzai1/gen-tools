#!/bin/bash
echo "Start Generate Migrate Plan..."
go run $GOPATH/src/gido.vn/gic/sqitch/scripts/migrate-gen.go
echo "DONE"