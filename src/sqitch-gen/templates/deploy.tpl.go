package tplsql

// Deploy ...
const Deploy = `
BEGIN;

/*-- TRIGGER BEGIN --*/
{{$.Triggers}}
/*-- TRIGGER END --*/

{{- range $index, $table := $.AlterTables}}
{{$primaryKeyExisted := false }}
{{- range $fieldIndex, $field := $table.Fields}}
	{{- if not $field.IsNewField}}
		{{- if ne $field.OldName ""}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			RENAME COLUMN {{$field.OldName}} TO {{$field.Name}};
		{{- end}}

		{{- if $field.IsPrimaryChanged}}
		 	{{- if not $primaryKeyExisted}}
				ALTER TABLE IF EXISTS {{$table.Name}} DROP CONSTRAINT {{$table.Name}}_pkey;
				{{- if $field.Primary}}
				ALTER TABLE IF EXISTS {{$table.Name}} ADD PRIMARY KEY ({{$field.Name}});
				{{- end}}
			{{- end}}
		{{- end}}

		{{- if $field.IsTypeChanged}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ALTER COLUMN {{$field.Name}} TYPE {{$field.Type}} USING {{$field.Name}}::{{$field.Type}};
		{{- end}}

		{{- if $field.IsDefaultChanged}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			{{- if ne $field.Default ""}}
			ALTER COLUMN {{$field.Name}} SET DEFAULT '{{$field.Default}}';
		UPDATE {{$table.Name}} SET {{$field.Name}} = '{{$field.Default}}' WHERE {{$field.Name}} IS NULL;
			{{else}}
			ALTER COLUMN {{$field.Name}} DROP DEFAULT;
			{{- end}}
		{{- end}}

		{{- if $field.IsNotNullChanged}}
			{{- if not $field.Primary}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ALTER COLUMN {{$field.Name}} {{- if $field.NotNull}} SET NOT NULL{{else}} DROP NOT NULL{{- end}};	
			{{- end}}
		{{- end}}

		{{- if $field.IsUniqueChanged}} 
		ALTER TABLE IF EXISTS {{$table.Name}}
			{{- if $field.Unique}}
			ADD CONSTRAINT IF NOT EXISTS {{$table.Name}}_{{$field.Name}}_key UNIQUE ({{$field.Name}}); 
			{{else}}
			DROP CONSTRAINT IF EXISTS {{$table.Name}}_{{$field.Name}}_key CASCADE; 
			{{- end}}
		{{- end}}

	{{else}}
	
	ALTER TABLE IF EXISTS {{$table.Name}}
		ADD COLUMN IF NOT EXISTS {{$field.Name}} {{$field.Type}};
		{{- if $field.Primary}}
		{{$primaryKeyExisted = true}}
		ALTER TABLE IF EXISTS {{$table.Name}} DROP CONSTRAINT {{$table.Name}}_pkey;
		ALTER TABLE IF EXISTS {{$table.Name}} ADD PRIMARY KEY ({{$field.Name}});
		{{- end}}

		{{- if ne $field.Default ""}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ALTER COLUMN {{$field.Name}} SET DEFAULT '{{$field.Default}}';
		UPDATE {{$table.Name}} SET {{$field.Name}} = '{{$field.Default}}' WHERE {{$field.Name}} IS NULL;
		{{- end}}
		
		{{- if not $field.Primary}}
			{{- if $field.NotNull}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ALTER COLUMN {{$field.Name}} SET NOT NULL;	
			{{- end}}
		{{- end}}

		{{- if $field.Unique}}
		ALTER TABLE IF EXISTS {{$table.Name}}
			ADD CONSTRAINT IF NOT EXISTS {{$table.Name}}_{{$field.Name}}_key UNIQUE ({{$field.Name}}); 	
		{{- end}}
		
	{{- end}}
{{- end}}
{{- end}}

{{- range $index, $table := $.Tables}}
{{- if $table.Fields}}
CREATE TABLE IF NOT EXISTS {{$table.TableName}} (
{{- range $index, $field := $table.Fields}}
	{{$field.Name}} {{$field.Type}} 
{{- if eq $field.Primary true}} PRIMARY KEY {{- end}}
{{- if eq $field.NotNull true}} NOT NULL {{- end}}
{{- if ne $field.Default ""}} DEFAULT '{{$field.Default}}' {{- end}}
{{- if eq $field.Unique true}} Unique {{- end}}{{$lengthMinusOne := lengthMinusOne $table.Fields}}{{- if lt $index $lengthMinusOne}},{{- end}}
{{- end}}
);
{{- end}}

{{- if $table.Indexs}}
{{- range $i, $index := $table.Indexs}}
CREATE {{- if eq $index.Unique true}} UNIQUE{{- end}} INDEX IF NOT EXISTS {{$index.Name}} ON "{{$table.TableName}}" USING {{$index.Using}} ({{$index.Key}});
{{- end}}
{{- end}}

{{- if $table.DropFields}}
{{- range $indexDropField, $dropField := $table.DropFields}}
ALTER TABLE IF EXISTS {{$table.TableName}}
	DROP COLUMN IF EXISTS {{$dropField.Name}} CASCADE;
{{- end}}
{{- end}}

{{- if or $table.Histories $table.IsHistoryNoneField}}
CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;
COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';
CREATE TABLE IF NOT EXISTS {{$table.TableName}}_history (
	id bigserial primary key,
	revision bigint,
	changes jsonb,
	{{$table.TableName}}_id bigint,
	{{- range $indexHistory, $history := $table.Histories}}
		{{- if checkNotUserIDOrActionAdminID $history.Name}}
	prev_{{$history.Name}} {{$history.Type}},
	curr_{{$history.Name}} {{$history.Type}},	
		{{else}}
	user_id bigint,	
		{{- end}}
	{{- end}}
	updated_at timestamptz DEFAULT 'now()'
);

ALTER TABLE {{$table.TableName}} ADD COLUMN rid bigint;

CREATE FUNCTION public.{{$table.TableName}}_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'INSERT') THEN
		INSERT INTO {{$table.TableName}}_history(
			revision, 
			{{$table.TableName}}_id, 
			{{- range $historyIndex, $history := $table.Histories}}
				{{- if checkNotUserIDOrActionAdminID $history.Name}}
			curr_{{$history.Name}}, 
				{{else}}
			user_id,
				{{- end}}
			{{- end}}
			changes
		)
        VALUES (
			NEW.rid, 
			NEW.id, 
			{{- range $historyIndex, $history := $table.Histories}}
				{{- if eq $history.Name "admin_action_id"}}
			NEW.action_admin_id,
				{{else if eq $history.Name "user_id"}}
			NEW.user_id,
				{{else}}
			NEW.{{$history.Name}},
				{{- end}}
			{{- end}}
			to_json(NEW)
		);
    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
		changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,{{- range $hisIndex, $history := $table.Histories}}{{- if eq $history.Name "action_admin_id"}}	action_admin_id{{else if eq $history.Name "user_id"}}user_id{{- end}}{{- end}}}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO {{$table.TableName}}_history(
			revision,
			{{$table.TableName}}_id,
			{{- range $hisIndex, $history := $table.Histories}}
				{{- if checkNotUserIDOrActionAdminID $history.Name}}
			prev_{{$history.Name}},
			curr_{{$history.Name}},
				{{else}}
			user_id,
				{{- end}}
			{{- end}} 
			changes
		)
        VALUES (
			NEW.rid, 
			NEW.id, 
			{{- range $hisIndex, $history := $table.Histories}}
				{{- if eq $history.Name "action_admin_id"}}
			NEW.action_admin_id,
				{{else if eq $history.Name "user_id"}}
			NEW.user_id,
				{{else}}
			OLD.{{$history.Name}},
			NEW.{{$history.Name}},
				{{- end}}
			{{- end}}
			changes
		);
    END IF;
    RETURN NULL;
END
$$;

CREATE SEQUENCE IF NOT EXISTS {{$table.TableName}}_history_seq;
CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.{{$table.TableName}} FOR EACH ROW EXECUTE PROCEDURE public.update_rid('{{$table.TableName}}_history_seq');
CREATE TRIGGER {{$table.TableName}}_history AFTER INSERT OR UPDATE ON public.{{$table.TableName}} FOR EACH ROW EXECUTE PROCEDURE public.{{$table.TableName}}_history();
{{- end}}
{{- end}}

{{- if $.DropTables.Tables}}
DROP TABLE IF EXISTS {{- range $dropIndex, $dropTable := $.DropTables.Tables}} {{$dropTable}}{{$lengthMinusOne := lengthMinusOne $.DropTables.Tables}}{{- if lt $dropIndex $lengthMinusOne}},{{- end}}{{- end}} CASCADE;
{{- end}}

COMMIT;
`
