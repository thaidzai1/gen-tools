/*-- TRIGGER: merchant --*/
CREATE OR REPLACE FUNCTION merchant_update() RETURNS trigger AS $$
BEGIN
    IF (NEW.refcode IS NOT NULL AND NEW.refcode <> '') THEN
        NEW.admin_id := (SELECT id FROM gic_staff WHERE substring(id::text from '.....$') = NEW.refcode);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS merchant_update ON "merchant";
CREATE TRIGGER merchant_update BEFORE INSERT OR UPDATE ON "merchant"
    FOR EACH ROW EXECUTE PROCEDURE merchant_update();

CREATE OR REPLACE FUNCTION merchant_create_mseq() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS mseq_%s', NEW.id);
    RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS merchant_create_mseq ON "merchant";
CREATE TRIGGER merchant_create_mseq AFTER INSERT ON "merchant"
	FOR EACH ROW EXECUTE PROCEDURE merchant_create_mseq();

CREATE OR REPLACE FUNCTION merchant_drop_mseq() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE FORMAT('drop sequence IF EXISTS mseq_%s', OLD.id);
    RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS merchant_drop_mseq ON "merchant";
CREATE TRIGGER merchant_drop_mseq AFTER DELETE ON "merchant"
    FOR EACH ROW EXECUTE PROCEDURE merchant_drop_mseq();

/*-- TRIGGER: merchant_order --*/

CREATE OR REPLACE FUNCTION merchant_order_update() RETURNS trigger AS $$
BEGIN
    IF (NEW.merchant_id IS NOT NULL AND NEW.merchant_id <> 0) THEN
        NEW.merchant := (SELECT code FROM merchant WHERE id = NEW.merchant_id);
        IF (NEW.merchant IS NULL) THEN
            RAISE EXCEPTION 'merchant does not exist or has not been activated';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS merchant_order_update ON "merchant_order";
CREATE TRIGGER merchant_order_update BEFORE INSERT OR UPDATE ON "merchant_order"
    FOR EACH ROW EXECUTE PROCEDURE merchant_order_update();

CREATE OR REPLACE FUNCTION next_mseq(mid bigint) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    rs integer;
BEGIN
    IF NOT EXISTS (
        SELECT 0 FROM pg_class WHERE relname = 'mseq_' || mid
    ) THEN
        IF NOT EXISTS (
            SELECT 0 FROM merchant WHERE id = mid
        ) THEN
            RAISE EXCEPTION 'merchant does not exist';
        END IF;

        EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS mseq_%s', mid);
    END IF;

    rs := nextval('mseq_' || mid);
    IF rs > 9999 THEN
        rs := setval('mseq_' || mid, 0);
    END IF;
    RETURN rs;
END
$$;


CREATE OR REPLACE FUNCTION merchant_order_create_code() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF (substring(NEW.code, '\.$') IS NULL) THEN
        RETURN NEW;
    END IF;

    NEW.code = NEW.code || LPAD(next_mseq(NEW.merchant_id)::text, 4, '0');
    RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS merchant_order_create_code ON "merchant_order";
CREATE TRIGGER merchant_order_create_code BEFORE INSERT ON "merchant_order"
    FOR EACH ROW EXECUTE PROCEDURE merchant_order_create_code();

CREATE OR REPLACE FUNCTION merchant_order_create_mohseq() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS mohseq_%s', NEW.id);
    RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS merchant_order_create_mohseq ON "merchant_order";
CREATE TRIGGER merchant_order_create_mohseq AFTER INSERT ON "merchant_order"
    FOR EACH ROW EXECUTE PROCEDURE merchant_order_create_mohseq();

CREATE OR REPLACE FUNCTION merchant_order_drop_mohseq() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE FORMAT('DROP SEQUENCE IF EXISTS mohseq_%s', OLD.id);
    RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS merchant_order_drop_mohseq ON "merchant_order";
CREATE TRIGGER merchant_order_drop_mohseq AFTER DELETE ON "merchant_order"
    FOR EACH ROW EXECUTE PROCEDURE merchant_order_drop_mohseq();

CREATE OR REPLACE FUNCTION merchant_order_history_insert() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    NEW.revision := nextval('mohseq_' || NEW.merchant_order_id);
    NEW.prev_state := (SELECT curr_state FROM merchant_order_history WHERE merchant_order_id = NEW.merchant_order_id AND revision = NEW.revision - 1);

    -- if state_final is changed, take curr_state from prev_state
    IF (NEW.curr_state IS NULL AND NEW.state_final != 0) THEN
        NEW.curr_state = NEW.prev_state;
    END IF;

    RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS merchant_order_history_insert ON "merchant_order_history";
CREATE TRIGGER merchant_order_history_insert BEFORE INSERT ON "merchant_order_history"
    FOR EACH ROW EXECUTE PROCEDURE merchant_order_history_insert();


/*-- TRIGGER: order_item_update --*/

CREATE OR REPLACE FUNCTION order_item_update() RETURNS trigger
LANGUAGE plpgsql AS $$
    BEGIN
        IF (NEW.merchant_id IS NOT NULL AND NEW.merchant_id <> 0) THEN
            NEW.merchant := (SELECT code FROM merchant WHERE id = NEW.merchant_id);
            IF (NEW.merchant IS NULL) THEN
                RAISE EXCEPTION 'merchant does not exist or has not been activated';
            END IF;
        END IF;

        IF (NEW.pagent_id IS NOT NULL AND NEW.pagent_id <> 0) THEN
            NEW.pagent := (SELECT code FROM pagent WHERE id = NEW.pagent_id);
            IF (NEW.pagent IS NULL) THEN
                RAISE EXCEPTION 'pagent does not exist or has not been activated';
            END IF;
        END IF;

        IF (NEW.category IS NOT NULL AND NEW.category <> '') THEN
            NEW.category_name := (SELECT name FROM category WHERE code = NEW.category);
            IF (NEW.category_name IS NULL) THEN
                RAISE EXCEPTION 'category does not exist';
            END IF;
        END IF;

        IF (NEW.airline IS NOT NULL AND NEW.airline <> '') THEN
            NEW.airline_name := (SELECT name FROM airline WHERE code = NEW.airline);
            IF (NEW.airline_name IS NULL) THEN
                RAISE EXCEPTION 'airline does not exist';
            END IF;
        END IF;

        IF (NEW.supplier IS NOT NULL AND NEW.supplier <> '') THEN
            NEW.supplier_name := (SELECT name FROM supplier WHERE code = NEW.supplier);
            IF (NEW.supplier_name IS NULL) THEN
                RAISE EXCEPTION 'supplier does not exist';
            END IF;
        END IF;

        IF (NEW.t3pl IS NOT NULL AND NEW.t3pl <> '') THEN
            NEW.t3pl_name := (SELECT name FROM logistic_partner WHERE code = NEW.t3pl);
            IF (NEW.t3pl_name IS NULL) THEN
                RAISE EXCEPTION 'logistic partner does not exist';
            END IF;
        END IF;

        IF (NEW.supplier_courier IS NOT NULL AND NEW.supplier_courier <> '') THEN
            NEW.supplier_courier_name := (SELECT name FROM courier WHERE code = NEW.supplier_courier);
            IF (NEW.supplier_courier_name IS NULL) THEN
                RAISE EXCEPTION 'courier does not exist';
            END IF;
        END IF;

        IF (NEW.consol_warehouse IS NOT NULL AND NEW.consol_warehouse <> '') THEN
            NEW.consol_warehouse_name := (SELECT name FROM warehouse WHERE code = NEW.consol_warehouse);
            IF (NEW.consol_warehouse_name IS NULL) THEN
                RAISE EXCEPTION 'warehouse does not exist';
            END IF;
        END IF;

        IF (NEW.shipping_province IS NOT NULL AND NEW.shipping_province <> '') THEN
            NEW.shipping_province_name := (SELECT name FROM province WHERE code = NEW.shipping_province);
            IF (NEW.shipping_province_name IS NULL) THEN
                RAISE EXCEPTION 'province does not exist';
            END IF;
        END IF;

        IF (NEW.shipping_district IS NOT NULL AND NEW.shipping_district <> '') THEN
            NEW.shipping_district_name := (SELECT name FROM district WHERE code = NEW.shipping_district);
            IF (NEW.shipping_district_name IS NULL) THEN
                RAISE EXCEPTION 'district does not exist';
            END IF;
        END IF;

        IF (NEW.shipping_ward IS NOT NULL AND NEW.shipping_ward <> '') THEN
            NEW.shipping_ward_name := (SELECT name FROM ward WHERE code = NEW.shipping_ward);
            IF (NEW.shipping_ward_name IS NULL) THEN
                RAISE EXCEPTION 'ward does not exist';
            END IF;
        END IF;

        IF (NEW.gcode != '') THEN
            IF (TG_OP = 'UPDATE' AND OLD.gcode != '') THEN
                IF (OLD.gcode != NEW.gcode) THEN
                    RAISE EXCEPTION 'gcode can not be changed';
                END IF;
            ELSE
                NEW.gscode = substring(NEW.gcode , '([A-Z\.\d]*)');
                IF NEW.gscode = '' OR NEW.gscode IS NULL THEN
                    NEW.gscode = '-';
                END IF;
            END IF;
        END IF;

        RETURN NEW;
    END;
$$;

DROP TRIGGER IF EXISTS order_item_update ON "order_item";
CREATE TRIGGER order_item_update BEFORE INSERT OR UPDATE ON "order_item"
    FOR EACH ROW EXECUTE PROCEDURE order_item_update();

CREATE OR REPLACE FUNCTION merchant_order_item_update() RETURNS trigger
LANGUAGE plpgsql AS $$
    DECLARE total_closed    INT2;
    DECLARE total_cancelled  INT2;
    BEGIN
        SELECT COUNT(*) INTO total_closed
        FROM "order_item"
        WHERE merchant_order_id = NEW.merchant_order_id AND state_final <> 0;
        SELECT COUNT(*) INTO total_cancelled
        FROM "order_item"
        WHERE merchant_order_id = NEW.merchant_order_id AND state_final < 0;
        UPDATE "merchant_order" SET closed_items = @total_closed,cancelled_items = @total_cancelled WHERE id = NEW.merchant_order_id;
        RETURN NEW;
    END;
$$;

DROP TRIGGER IF EXISTS merchant_order_item_update ON "order_item";
CREATE TRIGGER merchant_order_item_update AFTER INSERT OR UPDATE ON "order_item"
    FOR EACH ROW EXECUTE PROCEDURE merchant_order_item_update();


/*-- TRIGGER: order_item_create_oihseq ON order_item --*/

CREATE OR REPLACE FUNCTION order_item_create_oihseq() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS oihseq_%s', NEW.id);
    RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS order_item_create_oihseq ON "order_item";
CREATE TRIGGER order_item_create_oihseq AFTER INSERT ON "order_item"
    FOR EACH ROW EXECUTE PROCEDURE order_item_create_oihseq();

/*-- TRIGGER: order_item_drop_oihseq ON order_item --*/

CREATE OR REPLACE FUNCTION order_item_drop_oihseq() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE FORMAT('drop sequence IF EXISTS oihseq_%s', OLD.id);
    RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS order_item_drop_oihseq ON "order_item";
CREATE TRIGGER order_item_drop_oihseq AFTER DELETE ON "order_item"
    FOR EACH ROW EXECUTE PROCEDURE order_item_drop_oihseq();

/*-- TRIGGER: order_item_history_insert ON order_item_history --*/

CREATE OR REPLACE FUNCTION order_item_history_insert() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    NEW.revision := nextval('oihseq_' || NEW.order_item_id);
    NEW.prev_state := (SELECT curr_state FROM order_item_history WHERE order_item_id = NEW.order_item_id AND revision = NEW.revision - 1);

    -- if state_final is changed, take curr_state from prev_state
    IF (NEW.curr_state IS NULL AND NEW.state_final != 0) THEN
        NEW.curr_state = NEW.prev_state;
    END IF;

    RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS order_item_history_insert ON "order_item_history";
CREATE TRIGGER order_item_history_insert BEFORE INSERT ON "order_item_history"
    FOR EACH ROW EXECUTE PROCEDURE order_item_history_insert();
