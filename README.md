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
go get -u -v gido.vn/gic/databases/sqitch.git
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
|   +-- 001-triggers.sql
|   ...
+-- tables
|   +-- table_name_1.yml
|   ...
+-- dropped-tables
|   +-- dropped-tables.yml
+-- .restricted
|   +-- tables
|   +-- dropped-tables
|   |   +-- dropped-tables.yml
|   +-- functions
|   |   +--  functions.yml
+-- schema.yml
```

### Schema configuration
```
version: 1
version_name: 1 - Init project

schemas:
  tables: 'path-to-table-dir'
  functions: 'path-to-funcions-dir'
  generated_functions: 'path-to-file-functions.yml-in-restricted-dir'
  curr_tables: 'path-to-tables-in-restricted-dir'
  dropped_tables: 'path-to-file-dropped-tables.yaml-in-restricted-dir'
  dropped_tables_config: 'path-to-dropped-tables-dir'
  models 'path-to-models-dir'
  gen_models_destinations: 'path-to-gen-models-dir'
  stores: 'path-to-stores-dir'
  gen_stores_destinations: 'path-to-gen-stores-dir'
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
  tables: schema/tables
  functions: schema/functions
  generated_functions: schema/.restricted/functions/functions.yml
  curr_tables: schema/.restricted/tables
  dropped_tables: schema/.restricted/dropped-tables
  dropped_tables_config: schema/dropped-tables/dropped-tables.yml
  models: schema/tables
  gen_models_destinations: schema/models
  stores: schema/tables
  gen_stores_destinations: schema/stores
```

### Schema table configuration

```
version: 'version'
version_name: 'name of version'
fields:
  # migration properties
  - name: 'field name'
    old_name:
    type: 'sql type'
    primary: 'bool'
    not_null: 'bool'
    unique: 'bool'
    # model properties
    go_type: 'go type'
    skip_in_db: 'bool'
    skip_in_proto: 'bool'
    gorm: '"-;" or none'
    ref: 'reference to other table'
indexs:
  - name: 'indexs name'
    key: 'field that apply index'
    using: 'using type of index'
histories:
  - name: 'name of field required in history table' (or none_field)
  - none_field: true

drop_fields:
  - name: 'name of field need to be dropped'
```

<mark>NOTICE</mark>
1. When field has primary is true, field will auto be not null. 
2. When you change name of field, you need rewrite old field's name in old_name section.
3. System only drops field when it's declared in 'drop_fields' section.
4. 'histories' section will auto create history table follow the main table name with all fields are declared in this section or you can use "none_field" for not creating any field. For ex: mainTableName_history.

# Test configuration

Change defaultConfig() -> defaultTestConfig() in ./src/sqitch-deploy/deploy.go to use test DB

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
$GOPATH/bin/sqitch.git -schema 'path to schema configuration yaml file'
```

Example: 
```
$GOPATH/bin/sqitch.git -schema /Users/schema/schema.yml
```

## Run deploy command
Run in command 
```
$GOPATH/bin/deploy-sqitch -schema 'path to schema configuration yaml file' -config-file 'db config path'
```

Note: If you don't use -config-file, system loads default configuration

# Gen models and stores
Run command
```
$GOPATH/bin/gen-model -schema 'path to schema configuration yaml file'
```

# Test Deployment

## Check status
sqitch status db:postgres://gido_stag:mhh42mw0IYFQx7w3aENAh@35.220.166.103:5432/gido_stag

## Log
sqitch log db:postgres://gido_stag:mhh42mw0IYFQx7w3aENAh@35.220.166.103:5432/gido_stag