# Go ENV
Run in command: 
`'export GOPATH=$HOME/code/go'`
`'export GOPRIVATE=gido.vn,g.ghn.vn'`
`'export GOROOT=/usr/local/go'`

# Download source

Run in command `'go get -u gido.vn/gic/sqitch'`

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
sqitch status db:postgres://gido_stag:mhh42mw0IYFQx7w3aENAh@35.220.166.103:5432/gido_stag

## Log
sqitch log db:postgres://gido_stag:mhh42mw0IYFQx7w3aENAh@35.220.166.103:5432/gido_stag

## FLow of Migration

```mermaid
graph TD
A[Edit YAML file] 
B{Have new Funcs or Triggers ?}
C1[Create & write .sql file in './scripts/gen/schema/fuctions']
C2{Generate right?}
D1{Ready to deploy migrate?}
D2[Run ./scripts/gen-migrate.sh]
E1[git push commit & run `./scripts/deploy.sh`]
E2{Script SQL won't work by mistake?}
F1[Generate again with old migrate plan again, same old plan index]
F2[Add new migrate plan]
A --> B
B -- Yes --> C1
B -- No --> D2
C1 --> D2
C2 -- Yes --> D1
D2 --> C2
C2 -- No --> E2
D1 -- Yes --> E1
E2 -- Yes --> F1
E2 -- No, script works, wrong config --> F2
F2 --> A
F1 --> A
```