CREATE TABLE IF NOT EXISTS user_internal (
    user_id     INT8 PRIMARY KEY,
    user_type   TEXT,
    hash_pwd    TEXT
);

CREATE TABLE IF NOT EXISTS merchant (
    id          INT8 PRIMARY KEY,
    code        TEXT UNIQUE,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    disabled_at TIMESTAMPTZ,

    name        TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    phone       TEXT NOT NULL UNIQUE,
    address     TEXT,
    avatar      TEXT,
    refcode     TEXT,
    admin_id    INT8
);

CREATE TABLE IF NOT EXISTS pagent (
    id          INT8 PRIMARY KEY,
    code        TEXT UNIQUE,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    disabled_at TIMESTAMPTZ,

    name        TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    phone       TEXT NOT NULL UNIQUE,
    address     TEXT,
    avatar      TEXT
);

CREATE TABLE IF NOT EXISTS gic_staff (
    id          INT8 PRIMARY KEY,
    code        TEXT UNIQUE,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    disabled_at TIMESTAMPTZ,

    roles       TEXT[],

    name        TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    phone       TEXT NOT NULL UNIQUE,
    avatar      TEXT
);

CREATE TABLE IF NOT EXISTS role (
    id          INT8 PRIMARY KEY,
    name        TEXT NOT NULL,

    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS category (
    code        TEXT PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS courier (
    code        TEXT PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS warehouse (
    code        TEXT PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT,
    address     TEXT,
    ward        TEXT,
    district    TEXT,
    province    TEXT,
    country     TEXT,   -- default: US
    phone       TEXT,
    consignee   TEXT
);

CREATE TABLE IF NOT EXISTS airline (
    code        TEXT PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS supplier (
    code        TEXT PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS logistic_partner (
    code        TEXT PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS country (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS country_code_idx ON "country" (code);

CREATE TABLE IF NOT EXISTS province (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    country_code TEXT NOT NULL  -- default: VN
);

CREATE INDEX IF NOT EXISTS province_code_idx ON "province" (code);
CREATE INDEX IF NOT EXISTS province_country_code_idx ON "province" (country_code);

CREATE TABLE IF NOT EXISTS district (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    province_code INT4 NOT NULL
);

CREATE INDEX IF NOT EXISTS district_code_idx ON "district" (code);
CREATE INDEX IF NOT EXISTS district_province_code_idx ON "district" (province_code);

CREATE TABLE IF NOT EXISTS ward (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    district_code INT4 NOT NULL
);

CREATE INDEX IF NOT EXISTS ward_code_idx ON "ward" (code);
CREATE INDEX IF NOT EXISTS ward_district_code_idx ON "ward" (district_code);

CREATE TABLE IF NOT EXISTS "merchant_order" (
    id              INT8 PRIMARY KEY,
    code            TEXT UNIQUE,

    flow            TEXT,
    flow_version    INT2,
    state           TEXT NOT NULL,
    state_final     INT2 NOT NULL,

    created_at          TIMESTAMPTZ,
    updated_at          TIMESTAMPTZ,
    cancelled_at        TIMESTAMPTZ,
    closed_at           TIMESTAMPTZ,
    price_updated_at    TIMESTAMPTZ,
    mark_paid_at        TIMESTAMPTZ,

    admin_id            INT8,
    created_by_admin_id INT8,
    merchant_id         INT8 NOT NULL,
    merchant            TEXT,

    note_admin          TEXT,
    note_cancel         TEXT,
    note_order          TEXT,
    note_shipping       TEXT,
    note_admin_merchant TEXT,

    payment_status      INT4,
    payment_type        INT4,
    prepaid_amount_vnd  INT4,

    basket_value_vnd    INT4,
    basket_value_x      INT4,
    remain_amount_vnd   INT4,
    cod_amount_vnd      INT4,
    discount_vnd        INT4,
    discount_x          INT4,
    us_tax_x            INT4,
    us_shipping_fee_x   INT4,
    purchase_fee_x      INT4,
    purchase_fee_vnd    INT4,
    surcharge_x         INT4,
    gido_fee_x          INT4,
    gido_fee_vnd        INT4,
    total_fee_vnd       INT4,
    total_amount_vnd    INT4,

    order_items_json    JSONB,
    coupon_code         TEXT,

    total_items         INT2,
    closed_items        INT2,
    cancelled_items     INT2,

    plan_id     INT8,
    plan_name   TEXT,

    is_test INT2
);

CREATE INDEX IF NOT EXISTS merchant_order_admin_id_idx ON "merchant_order" (admin_id);
CREATE INDEX IF NOT EXISTS merchant_order_merchant_id_idx ON "merchant_order" (merchant_id);
CREATE INDEX IF NOT EXISTS merchant_order_merchant_idx ON "merchant_order" (merchant);
CREATE INDEX IF NOT EXISTS merchant_order_state_idx ON "merchant_order" (state);
CREATE INDEX IF NOT EXISTS merchant_order_state_final_idx ON "merchant_order" (state_final);
CREATE INDEX IF NOT EXISTS merchant_order_created_at_idx ON "merchant_order" (created_at);
CREATE INDEX IF NOT EXISTS merchant_order_updated_at_idx ON "merchant_order" (updated_at);
CREATE INDEX IF NOT EXISTS merchant_order_price_updated_at_idx ON "merchant_order" (price_updated_at);
CREATE INDEX IF NOT EXISTS merchant_order_mark_paid_at_idx ON "merchant_order" (mark_paid_at);
CREATE INDEX IF NOT EXISTS merchant_order_cancelled_at_idx ON "merchant_order" (cancelled_at);
CREATE INDEX IF NOT EXISTS merchant_order_closed_at_idx ON "merchant_order" (closed_at);

CREATE TABLE IF NOT EXISTS "merchant_order_history" (
    merchant_order_id   INT8 NOT NULL,
    revision            INT2 NOT NULL,
    user_id             INT8 NOT NULL,
    updated_at          TIMESTAMPTZ NOT NULL,
    prev_state          TEXT,
    curr_state          TEXT NOT NULL,
    state_final         INT2 NOT NULL,
    changes             JSONB
);
CREATE INDEX IF NOT EXISTS merchant_order_history_merchant_order_id_idx ON merchant_order_history (merchant_order_id);

CREATE TABLE IF NOT EXISTS "order_item" (
    id INT8         PRIMARY KEY,
    gcode           TEXT UNIQUE,
    gscode          TEXT,

    flow            TEXT,
    flow_version    INT2,
    state           TEXT,
    state_final     INT2,

    created_at      TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ,
    closed_at       TIMESTAMPTZ,
    cancelled_at    TIMESTAMPTZ,

    admin_id            INT8,
    box_id              INT8,
    created_by_admin_id INT8,
    merchant_id         INT8,
    merchant_order_id   INT8,
    pagent_id           INT8,

    airline                        TEXT,
    airline_name                   TEXT,
    basket_value_vnd               INT4,
    basket_value_x                 INT4,
    category                       TEXT,
    category_name                  TEXT,
    chargeable_weight              INT4,
    cod_amount_vnd                 INT4,
    consol_warehouse               TEXT,
    consol_warehouse_name          TEXT,
    currency                       TEXT,
    custom_clearance_at            TIMESTAMPTZ,
    delivered_to_customer_at       TIMESTAMPTZ,
    delivered_xx_at                TIMESTAMPTZ,
    discount_vnd                   INT4,
    est_delivery_to_customer_at    TIMESTAMPTZ,
    est_delivery_xx_at             TIMESTAMPTZ,
    exchange_rate                  INT4,
    height                         INT4,
    last_mile_fee_vnd              INT4,
    length                         INT4,
    mark_paid_at                   TIMESTAMPTZ,
    merchant                       TEXT,
    merchant_cashback_vnd          INT4,
    note_admin                     TEXT,
    note_cancel                    TEXT,
    note_product                   TEXT,
    note_shipping                  TEXT,
    pagent                         TEXT,
    pagent_assigned_at             TIMESTAMPTZ,
    pagent_commission_percent      INT2,
    pagent_commission_x            INT4,
    pagent_est_purchasing_amount_x INT4,
    pagent_expired_at              TIMESTAMPTZ,
    pagent_other_fee_x             INT4,
    pagent_price_x                 INT4,
    pagent_proceed_price_x         INT4,
    pagent_purchase_price_x        INT4,
    pagent_purchased_at            TIMESTAMPTZ,
    pagent_receipt_id              INT8,
    payment_status                 INT4,
    payment_type                   INT4,
    prepaid_amount_vnd             INT4,
    price_updated_at               TIMESTAMPTZ,
    product_link                   TEXT,
    purchase_fee_vnd               INT4,
    purchase_fee_x                 INT4,
    purchased_pagent_commission_at TIMESTAMPTZ,
    quantity                       INT4,
    real_weight                    INT4,
    remain_amount_vnd              INT4,
    shipping_address               TEXT,
    shipping_district              TEXT,
    shipping_district_name         TEXT,
    shipping_name                  TEXT,
    shipping_phone                 TEXT,
    shipping_province              TEXT,
    shipping_province_name         TEXT,
    shipping_ward                  TEXT,
    shipping_ward_name             TEXT,
    supplier                       TEXT,
    supplier_courier               TEXT,
    supplier_courier_name          TEXT,
    supplier_name                  TEXT,
    supplier_order_number          TEXT,
    supplier_price_vnd             INT4,
    supplier_price_x               INT4,
    supplier_shipping_fee_x        INT4,
    supplier_tracking_number       TEXT,
    surcharge_x                    INT4,
    t3pl                           TEXT,
    t3pl_name                      TEXT,
    tax_x                          INT4,
    total_amount_vnd               INT4,
    total_fee_vnd                  INT4,
    update_pagent_price_at         TIMESTAMPTZ,
    volumetric_weight              INT4,
    width                          INT4,

    is_test INT2
);

CREATE INDEX IF NOT EXISTS order_item_admin_id_idx ON "order_item" (admin_id);
CREATE INDEX IF NOT EXISTS order_item_box_id_idx ON "order_item" (box_id);
CREATE INDEX IF NOT EXISTS order_item_cancelled_at_idx ON "order_item" (cancelled_at);
CREATE INDEX IF NOT EXISTS order_item_closed_at_idx ON "order_item" (closed_at);
CREATE INDEX IF NOT EXISTS order_item_created_at_idx ON "order_item" (created_at);
CREATE INDEX IF NOT EXISTS order_item_delivered_to_customer_at_idx ON "order_item" (delivered_to_customer_at);
CREATE INDEX IF NOT EXISTS order_item_delivered_xx_at_idx ON "order_item" (delivered_xx_at);
CREATE INDEX IF NOT EXISTS order_item_gscode_idx ON "order_item" (gscode);
CREATE INDEX IF NOT EXISTS order_item_mark_paid_at_idx ON "order_item" (mark_paid_at);
CREATE INDEX IF NOT EXISTS order_item_merchant_id_idx ON "order_item" (merchant_id);
CREATE INDEX IF NOT EXISTS order_item_merchant_idx ON "order_item" (merchant);
CREATE INDEX IF NOT EXISTS order_item_pagent_id_idx ON "order_item" (pagent_id);
CREATE INDEX IF NOT EXISTS order_item_pagent_idx ON "order_item" (pagent);
CREATE INDEX IF NOT EXISTS order_item_state_final_idx ON "order_item" (state_final);
CREATE INDEX IF NOT EXISTS order_item_state_idx ON "order_item" (state);
CREATE INDEX IF NOT EXISTS order_item_updated_at_idx ON "order_item" (updated_at);
CREATE INDEX IF NOT EXISTS order_merchant_order_id_idx ON "order_item" (merchant_order_id);


CREATE TABLE IF NOT EXISTS "order_item_history" (
    order_item_id    INT8 NOT NULL,
    revision    INT2 NOT NULL,
    user_id     INT8 NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL,

    prev_state  TEXT,
    curr_state  TEXT NOT NULL,
    state_final INT2 NOT NULL,
    changes     JSONB
);

CREATE INDEX IF NOT EXISTS order_item_history_order_item_id_idx
    ON order_item_history (order_item_id);


CREATE TABLE IF NOT EXISTS "pagent_receipt" (
	id                          INT8 PRIMARY KEY,
	pagent_id                   INT8,
	admin_id                    INT8,
	created_at                  TIMESTAMPTZ,
	receipt_at                  TIMESTAMPTZ,
	pagent_purchasing_amount_x  INT4,
	commission_percent          INT2,
	commission_amount_x         INT4,
	commission_amount_vnd       INT4,
	exchange_rate               INT4,
	note_purchase_commission    TEXT
);

CREATE TABLE IF NOT EXISTS "email_history" (
	id              INT8 PRIMARY KEY,
	from_address    TEXT,
	to_address      TEXT,
	subject         TEXT,
	created_at      TIMESTAMPTZ,
	status          BOOL,
	error_message   TEXT
);

CREATE INDEX IF NOT EXISTS email_history_from_address ON "email_history" (from_address);
CREATE INDEX IF NOT EXISTS email_history_created_at ON "email_history" (created_at);

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
