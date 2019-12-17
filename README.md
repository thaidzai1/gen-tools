# Requirement

1. Sqitch: https://sqitch.org/download/
2. Go

# Go ENV
Run in command: 
```
export GOPATH=$HOME/code/go
export GOPRIVATE=gido.vn,g.ghn.vn
export GOROOT=/usr/local/go
```

# Download source

Run in command 
```
go get -u gido.vn/gic/databases/sqitch.git
```

# Contribute 

Run in command 
```
git clone git@g.ghn.vn:gic/databases/sqitch.git
```

# Generate Migrate plan

## Create triggers or functions file
While having new triggers or functions, create sql file exactly with plan name in ./schema/functions
- For example:
Plan name is: 001-test => Create file in ./schema/functions/001-test.sql

# USAGE

## Prepare schema folder

### Structure 
```
schema
+-- functions
|   +-- 001-triggers.yml
|   ...
+-- tables
|   +-- table_name_1.yml
|   ...
+-- .restricted
|   +-- tables
+-- schema.yml
```

### Schema configuration
```
version: 1
version_name: 1 - Init project

schemas:
  tables: 'path-to-table-dir'
  functions: 'path-to-funcions-dir'
  restricted: 'path-to-restricted-dir'
```

<mark>Notice</mark>
1. Folder 'tables' contains all table configuration by yaml file. Table's name is file's name. For ex: ahoy.yml => table name is ahoy.
2. Folder 'functions' contains all funtions or triggers written in .sql file. File .sql must be same name as schema when you create.
3. Folder .restricted contains folder 'tables' which is copied of folder 'tables' in note number 1. Folder .restricted is used to watching changes of tables & fields. (Must not edit).

For ex: 
```
version: 1
version_name: 1 - Init project

schemas:
  tables: /Users/thaidzai/schema/tables
  functions: /Users/thaidzai/schema/functions
  restricted: /Users/thaidzai/schema/.restricted/tables
```

### Schema table configuration

```
version: 'version'
version_name: 'name of version'
fields:
  - name: 'field name'
    old_name:
    type: 'sql type'
    primary: 'bool'
    not_null: 'bool'
    unique: 'bool'
indexs:
  - name: 'indexs name'
    key: 'field that apply index'
    using: 'using type of index'
histories:
  - name: 'name of field required in history table'

drop_fields:
  -name: 'name of field need to be dropped'
```

<mark>NOTICE</mark>
1. When field has primary is true, field will auto be not null. 
2. When you change name of field, you need rewrite old field's name in old_name section.
3. System only drops field when it's declared in 'drop_fields' section.
4. 'histories' section will auto create history table follow the main table name with all fields are declared in this section. For ex: mainTableName_history.

# Test configuration

Change defaultConfig() -> defaultTestConfig() in ./scripts/deploy-sqitch/main.go to use test DB

or You can apply your own configuration yaml file follow these configuration:
```
type: 'db-type;
username: 'db-username'
passowrd: 'db-password'
host: 'db-host'
port: 'db-port'
db_name: 'db_name'
```

## Build
Run in command
```
go install ./...
```

## Init Sqitch for project

if project doesn't have sqitch.plan or sqitch.conf you need to init sqitch project

```
sqitch init 'project-name' --uri 'project-uri' --engine 'database engine'
```

For ex: 
```
sqitch init test-project --uri https://github.com/sqitchers/sqitch-intro/  --engine pg
```

## Run generate command
Run in command 
```
$GOPATH/bin/sqitch.git -schema 'schema configuration yaml file path'
```

or 

Run in command 
```
go run ./scripts/migrate-gen.go -schema 'schema configuration yaml file path'
```

Example: 
```
$GOPATH/bin/sqitch.git -schema /Users/schema/schema.yml
```

## Run deploy command
Run in command 
```
$GOPATH/bin/deploy-sqitch -schema 'schema configuration yaml file path' -config-file 'db config path'
```

or 

Run in command 
```
go run ./scripts/deploys-sqitch/main.go -schema 'schema configuration yaml file path' -config-file 'db config path'
```
Note: If you don't use -config-file, system loads default configuration

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