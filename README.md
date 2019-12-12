# Go ENV
Run in command: 
`'export GOPATH=$HOME/code/go'`
`'export GOPRIVATE=gido.vn,g.ghn.vn'`
`'export GOROOT=/usr/local/go'`

# Download source

Run in command `'go get gido.vn/gic/sqitch'`

# Install

Run in command `'./scripts/install-tool.sh'`

# Generate Migrate plan

## Create triggers or functions file
While having new triggers or functions, create sql file exactly with plan name in ./scripts/gen/schema/functions
- For example:
Plan name is: 001-test => Create file in ./scripts/gen/schema/functions/001-test.sql

## Run generate command
Run in command `'./scripts/gen-migrate.sh'`

or 

Run in command `'go run ./scripts/migrate-gen.go'`

## Run deploy command
Run in command `'./scripts/deploy.sh'`

or 

Run in command `'go run ./scripts/deploy/deploy.go'`

# Test Deployment

## Check status
sqitch status db:postgres://gido_stag:mhh42mw0IYFQx7w3aENAh@35.220.166.103:5432/gido_test_squitch

## Log
sqitch log db:postgres://gido_stag:mhh42mw0IYFQx7w3aENAh@35.220.166.103:5432/gido_test_squitch