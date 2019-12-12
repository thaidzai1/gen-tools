--
-- TOC entry 298332 (class 1255 OID 16518)
-- Name: add_merchant_plan_into_merchant_order(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_merchant_plan_into_merchant_order() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  merchantPlanID INT8;
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id FROM merchant_order) LOOP
      SELECT merchant_plan_id INTO merchantPlanID FROM merchant_plan_order where merchant_order_id = rec.id;
      IF merchantPlanID <> 0 THEN
          UPDATE merchant_order SET merchant_plan_id = merchantPlanID WHERE id = rec.id;
      END IF;
      merchantPlanID := NULL;
    END LOOP;
    -- DELETE FROM merchant_plan_order;
    -- DROP TABLE IF EXISTS merchant_plan_order;
    RETURN 'done';
END
$$;


--
-- TOC entry 298442 (class 1255 OID 554660)
-- Name: bank_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bank_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO bank_history(revision, bank_id, owner_name, owner_account, bank_name, bank_province, bank_branch, user_id, changes)
        VALUES (NEW.rid, NEW.id, NEW.owner_name, NEW.owner_account, NEW.bank_name, NEW.bank_province, NEW.bank_branch, NEW.user_id, to_json(NEW));
    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO bank_history(revision, bank_id, owner_name, owner_account, bank_name, bank_province, bank_branch, user_id, changes)
        VALUES (NEW.rid, NEW.id, NEW.owner_name, NEW.owner_account, NEW.bank_name, NEW.bank_province, NEW.bank_branch, NEW.user_id, changes);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298337 (class 1255 OID 16519)
-- Name: box_create_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.box_create_code() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE CURR_TIME TEXT;
BEGIN
    CURR_TIME = (select substring(date_part('year', CURRENT_DATE at time zone 'ict')::text, 3, 2)::text || lpad(date_part('month', CURRENT_DATE at time zone 'ict')::text, 2, '0'));   
        IF NEW.state >= '4A' THEN
            NEW.code = 'B4' || CURR_TIME || LPAD(next_box_seq(CURR_TIME)::text, 4, '0'); 
        ELSE
            NEW.code = 'GIC' || CURR_TIME || LPAD(next_box_seq(CURR_TIME)::text, 3, '0');            
        END IF;
    RETURN NEW;
END
$$;


--
-- TOC entry 298333 (class 1255 OID 16520)
-- Name: box_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.box_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO box_history(revision, box_id, changes, user_id, curr_state, prev_state)
        VALUES (nextval('box_history_seq'), OLD.id, to_json(OLD), OLD.action_admin_id, 'DELETED', OLD.state);

    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO box_history(revision, box_id, changes, user_id, curr_state)
        VALUES (NEW.rid, NEW.id, to_json(NEW), NEW.action_admin_id, NEW.state);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO box_history(revision, box_id, changes, user_id, curr_state)
        VALUES (NEW.rid, NEW.id, changes, NEW.action_admin_id, NEW.state);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298334 (class 1255 OID 16521)
-- Name: check_coupon_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_coupon_code() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.code = '' THEN
        RAISE EXCEPTION 'The column code must be not null.';
    END IF;
    IF NEW.description = '' THEN
        RAISE EXCEPTION 'The column description must be not null.';
    END IF;
    IF NEW.title = '' THEN
        RAISE EXCEPTION 'The column title must be not null.';
    END IF;
    RETURN NEW;
END
$$;


--
-- TOC entry 298335 (class 1255 OID 16522)
-- Name: check_update_mo_state_done(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_update_mo_state_done() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
    IF TG_OP = 'UPDATE' AND NEW.state = 'D' THEN
  UPDATE merchant_order mo
  SET state = 'D'
  WHERE id = NEW.merchant_order_id and 
  (select count(id) from order_item where merchant_order_id = NEW.merchant_order_id and state = 'D' and state_final >= 0) =
  (select count(id) from order_item where merchant_order_id = NEW.merchant_order_id and state_final >= 0) AND
  (select count(id) from order_item where merchant_order_id = NEW.merchant_order_id and state_final >= 0) > 0;
 END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298461 (class 1255 OID 574306)
-- Name: cod_session_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cod_session_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO cod_session_history(revision, cod_session_id, curr_state, user_id, changes)
        VALUES (NEW.rid, NEW.id, NEW.state, NEW.action_admin_id, to_json(NEW));
    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO cod_session_history(revision, cod_session_id, prev_state, curr_state, user_id, changes)
        VALUES (NEW.rid, NEW.id, OLD.state, NEW.state, NEW.action_admin_id, changes);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298421 (class 1255 OID 531178)
-- Name: compute_sorting_code_when_change_district_province_on_lastmile(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.compute_sorting_code_when_change_district_province_on_lastmile() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    mo RECORD;
    province_sorting_code TEXT;
    district_sorting_code TEXT;
    oi_4a INT;
    oi_3a_4a INT;
    new_sorting_code TEXT;
    test_code TEXT;
BEGIN
    -- Update Lastmile Info after update Merchant Order
    -- to prevent update wrong sorting code
    IF (TG_OP = 'UPDATE' AND (NEW.district <> OLD.district OR NEW.province <> OLD.province)) THEN
        SELECT sorting_code INTO province_sorting_code FROM province WHERE code = NEW.province;
        SELECT sorting_code INTO district_sorting_code FROM district WHERE code = NEW.district;
        IF (province_sorting_code <> '' AND district_sorting_code <> '') THEN
            FOR mo IN (SELECT * FROM merchant_order
                WHERE last_mile_shipping_info_id = NEW.id
                    AND state_final >=0 AND (state <= '1SZ' OR state <= '2Z')
                    AND state NOT IN ('1FK', '1FZ')) LOOP
                IF (mo.merchant_type = 'cbe' OR mo.merchant_type = 'cbe_transhipment') THEN
                    new_sorting_code = province_sorting_code || '-2-' || district_sorting_code;
                ELSE
                    new_sorting_code = province_sorting_code || '-1-' || district_sorting_code;
                END IF;

                SELECT count(id) INTO oi_4a FROM order_item WHERE merchant_order_id = mo.id AND state_final >=0 AND state > '4A' LIMIT 1;
                SELECT count(id) INTO oi_3a_4a FROM order_item WHERE merchant_order_id = mo.id AND state_final >=0 AND state BETWEEN '3A' AND '4A' LIMIt 1;
                
                IF (oi_4a > 0) THEN
                    RAISE EXCEPTION 'Cannot update lastmile shipping info of order: % when order item state > 4A', mo.code;
                ELSE
                    IF (oi_3a_4a > 0) THEN
                        IF (new_sorting_code <> mo.sorting_code) THEN
                            RAISE EXCEPTION 'Cannot update lastmile shipping info of order: % has difference sorting code when order item state between 3A AND 4A', mo.code;
                        END IF;
                    ELSE
                        UPDATE merchant_order
                        SET sorting_code = new_sorting_code
                        WHERE id = mo.id;
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END IF;
    RETURN NEW;
END
$$;


--
-- TOC entry 298422 (class 1255 OID 531177)
-- Name: compute_sorting_code_when_insert_update_mo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.compute_sorting_code_when_insert_update_mo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    lm RECORD;
    province_sorting_code TEXT;
    district_sorting_code TEXT;
    oi_4a INT;
    oi_3a_4a INT;
    new_sorting_code TEXT;
BEGIN
    IF (TG_OP = 'INSERT' AND NEW.last_mile_shipping_info_id <> 0) THEN
        SELECT * INTO lm FROM last_mile_shipping_info WHERE id = NEW.last_mile_shipping_info_id;
        IF (lm.province <> '' AND lm.district <> '' ) THEN
            SELECT sorting_code INTO province_sorting_code FROM province WHERE code = lm.province;
            SELECT sorting_code INTO district_sorting_code FROM district WHERE code = lm.district;
            IF (province_sorting_code <> '' AND district_sorting_code <> '') THEN
                IF (NEW.merchant_type = 'cbe' OR NEW.merchant_type = 'cbe_transhipment') THEN
                    NEW.sorting_code = province_sorting_code || '-2-' || district_sorting_code;
                ELSE
                    NEW.sorting_code = province_sorting_code || '-1-' || district_sorting_code;
                END IF;
            END IF;
        END IF;
    ELSIF (TG_OP = 'UPDATE' AND NEW.last_mile_shipping_info_id <> OLD.last_mile_shipping_info_id) THEN
        SELECT count(id) INTO oi_4a FROM order_item WHERE merchant_order_id = NEW.id AND state_final >=0 AND state > '4A' LIMIT 1;
        SELECT count(id) INTO oi_3a_4a FROM order_item WHERE merchant_order_id = NEW.id AND state_final >=0 AND state BETWEEN '3A' AND '4A' LIMIT 1;
        IF (oi_4a > 0) THEN
            RAISE EXCEPTION 'Cannot update lastmile shipping info of order: % when order item state > 4A', NEW.code;
        ELSE
            -- check new sorting code
            SELECT * INTO lm FROM last_mile_shipping_info WHERE id = NEW.last_mile_shipping_info_id;
            IF (lm.province <> '' AND lm.district <> '' ) THEN
                SELECT sorting_code INTO province_sorting_code FROM province WHERE code = lm.province;
                SELECT sorting_code INTO district_sorting_code FROM district WHERE code = lm.district;
                IF (province_sorting_code <> '' AND district_sorting_code <> '') THEN
                    IF (NEW.merchant_type = 'cbe' OR NEW.merchant_type = 'cbe_transhipment') THEN
                        new_sorting_code = province_sorting_code || '-2-' || district_sorting_code;
                    ELSE
                        new_sorting_code = province_sorting_code || '-1-' || district_sorting_code;
                    END IF;
                    IF (oi_3a_4a > 0) THEN
                        IF (new_sorting_code <> OLD.sorting_code) THEN
                            RAISE EXCEPTION 'Cannot update lastmile shipping info of order: % has difference sorting code when order item state between 3A AND 4A', NEW.code;
                        END IF;
                    ELSE
                        NEW.sorting_code = new_sorting_code;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END
$$;


--
-- TOC entry 298436 (class 1255 OID 555018)
-- Name: create_bank_info_for_merchant(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_bank_info_for_merchant() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id, code FROM merchant WHERE code <> '') LOOP
        INSERT INTO bank(merchant_id, merchant_code, user_id) VALUES(rec.id, rec.code, rec.id);
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298407 (class 1255 OID 565728)
-- Name: create_bank_when_merchant_created(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_bank_when_merchant_created() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- ignore trivial changes
    INSERT INTO bank(merchant_id, merchant_code, user_id) VALUES(NEW.id, NEW.code, NEW.id);
    RETURN NEW;
END;
$$;


--
-- TOC entry 298446 (class 1255 OID 560927)
-- Name: create_code_order(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_code_order() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (select id, code from merchant_order where id in (1453203146398074361,1453203821080456859,1453332292845524778,1453346568383433753,1453348183786599571,1453128321041978185,1453133761405488542,1454079984074140550,1451080925283180479,1451080925283180479,1451080925283180479,1454156058006341767,1451080925283180479,1451080925283180479,1451080925283180479,1451080925283180479,1451080925283180479,1451080925283180479,1451080925283180479)) LOOP
        UPDATE wallet_transaction_history set merchant_order_code = rec.code where merchant_order_id = rec.id;
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298440 (class 1255 OID 560433)
-- Name: create_merchant_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_merchant_code() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id, code FROM merchant) LOOP
        UPDATE wallet_transaction set merchant_code = rec.code where merchant_id = rec.id;
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298410 (class 1255 OID 567071)
-- Name: create_merchant_contract_existed(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_merchant_contract_existed() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (select wallet.id, code from wallet inner join merchant on wallet.merchant_id = merchant.id where wallet.merchant_code = '') LOOP
        UPDATE wallet SET merchant_code = rec.code WHERE id = rec.id;
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298449 (class 1255 OID 566826)
-- Name: create_merchant_contract_when_created(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_merchant_contract_when_created() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
		UPDATE merchant_contract SET merchant_code = NEW.code WHERE id = NEW.id; 
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO merchant_contract(id, merchant_code, verify_state, term_state, user_id) VALUES(NEW.id, NEW.code, 'New', 'WaitTerm', NEW.id); 
		RETURN NEW;
	END IF;
	RETURN NEW;
END;
$$;


--
-- TOC entry 298443 (class 1255 OID 560440)
-- Name: create_merchant_name(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_merchant_name() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id, name FROM merchant) LOOP
        UPDATE wallet_transaction set merchant_name = rec.name where merchant_id = rec.id;
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298445 (class 1255 OID 560901)
-- Name: create_merchant_order_code_transaction(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_merchant_order_code_transaction() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (select id,code from merchant_order where id in (1454156058006341767,1451080925283180479,1451080925283180479,1451080925283180479,1451080925283180479,1451080925283180479,1451080925283180479,1451080925283180479,1451080925283180479,1454079984074140550,1451080925283180479,1451080925283180479,1453348183786599571,1453346568383433753,1453332292845524778,1453203821080456859,1453203146398074361,1453133761405488542,1453128321041978185)) LOOP
        UPDATE wallet_transaction SET merchant_order_code = rec.code where merchant_order_id = rec.id;
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298409 (class 1255 OID 565797)
-- Name: create_payment_wallet_transaction(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_payment_wallet_transaction() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	rec RECORD;
BEGIN
	FOR rec IN(
		SELECT
			mo.id AS merchant_order_id, mo.code AS merchant_order_code, m.id AS merchant_id, m.code AS merchant_code, m.name AS merchant_name, w.id AS wallet_id, op.total_amount_after_discount_vnd AS value_vnd FROM merchant_order AS mo
			INNER JOIN order_price AS op ON mo.id = op.order_id
			INNER JOIN merchant AS m ON mo.merchant = m.code
			INNER JOIN wallet AS w ON m.id = w.merchant_id
		WHERE
			mo.id NOT in(
				SELECT
					merchant_order_id FROM wallet_transaction)
				AND state_final >= 0
				AND state in('1SD'))
	LOOP
		INSERT INTO wallet_transaction (value_vnd, type, state, state_final, merchant_order_code, merchant_code, merchant_name, merchant_id, merchant_order_id, wallet_id, user_id)
			VALUES(rec.value_vnd, 'P', 'P1', 0, rec.merchant_order_code, rec.merchant_code, rec.merchant_name, rec.merchant_id, rec.merchant_order_id, rec.wallet_id, rec.merchant_id);
	END LOOP;
	RETURN 'done';
END;
$$;


--
-- TOC entry 298424 (class 1255 OID 550805)
-- Name: create_wallet_for_merchant(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_wallet_for_merchant() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id, code, name FROM merchant WHERE code <> '') LOOP
        INSERT INTO wallet(balance_vnd, merchant_id, merchant_code, merchant_name, user_id, status) VALUES(0, rec.id, rec.code, rec.name, rec.id, 0);
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298444 (class 1255 OID 560454)
-- Name: create_wallet_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_wallet_id() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id, wallet_id FROM wallet_transaction) LOOP
        UPDATE wallet_transaction_history set wallet_id = rec.wallet_id where wallet_transaction_id = rec.id;
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298437 (class 1255 OID 555932)
-- Name: create_wallet_when_merchant_created(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_wallet_when_merchant_created() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF (TG_OP = 'UPDATE') THEN
		UPDATE wallet SET merchant_code = NEW.code WHERE merchant_id = NEW.id; 
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO wallet(balance_vnd, merchant_id, merchant_code, merchant_name, user_id, status) VALUES(0, NEW.id, NEW.code, NEW.name, NEW.id, 0); 
		RETURN NEW;
	END IF;
	RETURN NEW;
END;
$$;


--
-- TOC entry 298419 (class 1255 OID 530929)
-- Name: delete_mo(text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_mo(codes text[]) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
 rec RECORD;
    mo_rec RECORD;
    oih_ids text;
    moh_ids text;
BEGIN
 for mo_rec in (select id, code, state from merchant_order where code =  ANY(codes)) loop
        IF mo_rec.state != '1SZ' THEN
            return 'Error: Merchant Order must be in state: 1SZ!';
        END IF;
        FOR rec in (select distinct state from order_item where gscode = mo_rec.code) LOOP
            if rec.state != '1SZ' then
                return 'Error: Order Item must be in state: 1SZ!';
            end if;
        END LOOP;

        delete from product where merchant_order_id = mo_rec.id;

        delete from package_info where merchant_order_id = mo_rec.id;

        delete from order_item_history where order_item_id in (select id from order_item where gscode = mo_rec.code);

        delete from order_item where gscode = mo_rec.code;

        delete from merchant_order_history where merchant_order_id = mo_rec.id;

        delete from merchant_order where id = mo_rec.id;
    end loop;

 RETURN 'done';
END
$$;


--
-- TOC entry 298417 (class 1255 OID 530641)
-- Name: delete_mo(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_mo(input_code text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
 mo_state text;
 rec RECORD;
BEGIN
 select state into mo_state from merchant_order where code = input_code;
 IF mo_state != '1SZ' THEN
  return 'Merchant Order must be in state: 1SZ';
 END IF;
 FOR rec in (select distinct state from order_item where gscode = input_code) LOOP
  if rec.state != '1SZ' then
   return 'Order Item must be in state: 1SZ';
  end if;
 END LOOP;

 delete from product where merchant_order_id = (select id from merchant_order where code = input_code);

 delete from package_info where merchant_order_id = (select id from merchant_order where code = input_code);

 delete from order_item_history where order_item_id in (select id from order_item where gscode = input_code);

 delete from order_item where gscode = input_code;

 delete from merchant_order_history where merchant_order_id in (select id from merchant_order where code = input_code);

 delete from merchant_order where code = input_code;

 RETURN 'done';
END
$$;


--
-- TOC entry 298408 (class 1255 OID 16523)
-- Name: delivery_order_create_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delivery_order_create_code() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE CURR_TIME TEXT;
BEGIN
    CURR_TIME = (select substring(date_part('year', CURRENT_DATE at time zone 'ict')::text, 3, 2)::text || lpad(date_part('month', CURRENT_DATE at time zone 'ict')::text, 2, '0'));
    IF NEW.state = '3A' OR NEW.state = '3P' THEN
        NEW.code = 'GIC2' || CURR_TIME || LPAD(next_delivery_order_seq(CURR_TIME)::text, 4, '0');
    ELSE
        IF NEW.picking_type = 'f4tolm' THEN
            NEW.code = 'DOD' || CURR_TIME || LPAD(next_delivery_order_f4_seq(CURR_TIME)::text, 6, '0');
        ELSIF NEW.picking_type = 'f4cbetolm' THEN
            NEW.code = 'DOC' || CURR_TIME || LPAD(next_delivery_order_f4_seq(CURR_TIME)::text, 6, '0');
        ELSIF NEW.picking_type = 'whtowh' THEN
            NEW.code = 'DOR' || CURR_TIME || LPAD(next_delivery_order_f4_seq(CURR_TIME)::text, 6, '0');
        ELSIF NEW.picking_type = 'f4tomc' THEN
            NEW.code = 'DOM' || CURR_TIME || LPAD(next_delivery_order_f4_seq(CURR_TIME)::text, 6, '0');
        ELSE 
            NEW.code = 'DI' || CURR_TIME || LPAD(next_delivery_order_f4_seq(CURR_TIME)::text, 6, '0');
        END IF;
    END IF;
    RETURN NEW;
END
$$;


--
-- TOC entry 298435 (class 1255 OID 562475)
-- Name: finance_refund_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.finance_refund_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO finance_refund_history(revision,finance_refund_id,wallet_transaction_id,prev_state,curr_state,user_id,changes)
        VALUES (NEW.rid,NEW.id,NEW.wallet_transaction_id,OLD.state,NEW.state,NEW.user_id,to_json(NEW));
    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO finance_refund_history(revision,finance_refund_id,wallet_transaction_id,prev_state,curr_state,user_id,changes)
        VALUES (NEW.rid,NEW.id,NEW.wallet_transaction_id,OLD.state,NEW.state,NEW.user_id,changes);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298338 (class 1255 OID 16524)
-- Name: fix_consignee_cbe(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fix_consignee_cbe() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    IF (NEW.state != '3P' OR OLD.state != '3A') THEN
      RETURN NEW;
    END IF;
    FOR rec in (select
      p.code,
      p.consignee_name,
      cc.name,
      cc.address,
      ward.name as "ward",
      district.name as "district",
      province.name as "province",
      cc.phone
      from order_item as o
      inner join merchant_order mo
      on o.merchant_order_id = mo.id
      inner join parcel p on p.id = o.parcel_id
      inner join consignee_cbe cc on cc.id = mo.cbe_consignee_id
      inner join ward on ward.code = cc.ward
      inner join district on district.code = cc.district
      inner join province on province.code = cc.province
      where mo.merchant = 'ME2G' and p.state = '3A' and cc.name != p.consignee_name) LOOP
      RAISE INFO '%s %s', rec.code, rec.consignee_name;
      UPDATE parcel set consignee_name = rec.name, consignee_address = concat(rec.address,', ', rec.ward, ', ', rec.district, ', ', rec.province), consignee_tel = rec.phone WHERE code = rec.code AND state = '3A' AND consignee_name != rec.name;
    END LOOP;
    RETURN NEW;
END
$$;


--
-- TOC entry 298339 (class 1255 OID 16525)
-- Name: fix_consignee_cbe_inv(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fix_consignee_cbe_inv() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec in (select
      p.code,
      p.consignee_name,
      cc.name,
      cc.address,
      ward.name as "ward",
      district.name as "district",
      province.name as "province",
      cc.phone
      from order_item as o
      inner join merchant_order mo
      on o.merchant_order_id = mo.id
      inner join parcel p on p.id = o.parcel_id
      inner join consignee_cbe cc on cc.id = mo.cbe_consignee_id
      inner join ward on ward.code = cc.ward
      inner join district on district.code = cc.district
      inner join province on province.code = cc.province
      where mo.merchant = 'ME2G' and p.state = '3A' and cc.name != p.consignee_name) LOOP
      RAISE INFO '%s %s', rec.code, rec.consignee_name;
      UPDATE parcel set consignee_name = rec.name, consignee_address = concat(rec.address,', ', rec.ward, ', ', rec.district, ', ', rec.province), consignee_tel = rec.phone WHERE code = rec.code AND state = '3A' AND consignee_name != rec.name;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298340 (class 1255 OID 16526)
-- Name: fix_consignee_cbe_test(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fix_consignee_cbe_test() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec in (select
      cc.name,
      cc.address,
      ward.name as "ward",
      district.name as "district",
      province.name as "province",
      cc.phone
      from order_item as o
      inner join merchant_order mo
      on o.merchant_order_id = mo.id
      inner join consignee_cbe cc on cc.id = mo.cbe_consignee_id
      inner join ward on ward.code = cc.ward
      inner join district on district.code = cc.district
      inner join province on province.code = cc.province
      where mo.merchant = 'ME2G' limit 1) LOOP
      RAISE INFO '%s', rec.name;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298341 (class 1255 OID 16527)
-- Name: fix_migrate_mo_state_done(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fix_migrate_mo_state_done() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
 rec RECORD;
BEGIN
 FOR rec IN (select merchant_order_id, curr_state from merchant_order_history moh 
    where moh.merchant_order_id IN (select id from merchant_order mo where state_final >=0 and state ='D' and (select count(id) from order_item where merchant_order_id = mo.id and state_final >=0) <1 ) 
     AND revision >= (select max(revision) from merchant_order_history where merchant_order_id = moh.merchant_order_id)
    order by merchant_order_id, revision desc)
 LOOP
      UPDATE merchant_order
SET state = rec.curr_state
   WHERE id = rec.merchant_order_id;
    END LOOP;
    RETURN 'Done';
END
$$;


--
-- TOC entry 298342 (class 1255 OID 16528)
-- Name: fix_migrate_wrong_data(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fix_migrate_wrong_data() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
 rec RECORD;
 data_update RECORD;
BEGIN
    FOR rec IN (select * from merchant_order_history where changes->>'state_final' = '-2' and updated_at::date = now()::date) LOOP
        SELECT * INTO data_update FROM merchant_order_history where merchant_order_id = rec.merchant_order_id AND revision = (rec.revision - 1);
        IF data_update.merchant_order_id <> 0 THEN
            UPDATE merchant_order
            SET state_final = data_update.state_final
            WHERE id = data_update.merchant_order_id AND state_final = -2;
        END IF;
    END LOOP;
    RETURN '--done --';
END
$$;


--
-- TOC entry 298343 (class 1255 OID 16529)
-- Name: fix_mo_1z_to_done(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fix_mo_1z_to_done() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  orders_done INT;
  order_items INT;
  rec RECORD;
  order_item_history RECORD;
BEGIN
    FOR rec IN (select id from merchant_order where created_at::date < now()::date and state = '1Z' and state_final >= 0) LOOP
      orders_done := 0;
   order_items :=0;
   FOR order_item_history IN (select * from order_item_history oih where order_item_id IN (select id from order_item where merchant_order_id = rec.id) AND state_final >=0 AND revision >= 
  (SELECT max(revision) from order_item_history where order_item_id = oih.order_item_id and state_final >=0 )) LOOP
   order_items := order_items + 1;
  IF order_item_history.prev_state = 'D' and order_item_history.curr_state = '1Z' THEN
    orders_done := orders_done + 1;
  END IF;
    END LOOP;
   RAISE NOTICE '% orders_done', orders_done;
   RAISE NOTICE '% order_items', order_items;
   IF orders_done = order_items and order_items > 0 THEN
   update merchant_order set state = 'D' where id = rec.id;
   update order_item set state = 'D' where merchant_order_id = rec.id and state_final >= 0;
   END IF;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298344 (class 1255 OID 16530)
-- Name: fix_oi_gcode_one_time(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fix_oi_gcode_one_time() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  count INT;
  rec RECORD;
BEGIN
    count := 1;
    FOR rec IN (SELECT * FROM order_item where gscode = 'EJ.HPVF.0039' and state = 'D') LOOP
      UPDATE order_item SET gcode = ('EJ.HPVF.0039-' || count) WHERE id = rec.id;
      count := count + 1;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298345 (class 1255 OID 16531)
-- Name: fix_order_item_cbe_product_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fix_order_item_cbe_product_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  t2_row product%ROWTYPE;
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id,merchant_order_id FROM order_item WHERE state_final >= 0 AND state = '3A' AND product_id = 0) LOOP
      SELECT DISTINCT ON (merchant_order_id) * INTO t2_row FROM product WHERE merchant_order_id = rec.merchant_order_id;
      RAISE NOTICE '%', t2_row;
      IF (t2_row.id IS NOT NULL) THEN
        RAISE NOTICE '%', t2_row.id;
        UPDATE order_item SET product_id = t2_row.id,product_name=t2_row.name WHERE id = rec.id AND product_id = 0 AND state = '3A' AND state_final >= 0;
      END IF;
    END LOOP;
    RETURN NEW;
END
$$;


--
-- TOC entry 298347 (class 1255 OID 16532)
-- Name: fix_order_item_cbe_product_id_inv(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fix_order_item_cbe_product_id_inv() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  t2_row product%ROWTYPE;
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id,merchant_order_id FROM order_item WHERE state_final >= 0 AND state = '3A' AND product_id = 0) LOOP
      SELECT DISTINCT ON (merchant_order_id) * INTO t2_row FROM product WHERE merchant_order_id = rec.merchant_order_id;
      RAISE NOTICE '%', t2_row;
      IF (t2_row.id IS NOT NULL) THEN
        RAISE NOTICE '%', t2_row.id;
        UPDATE order_item SET product_id = t2_row.id,product_name=t2_row.name WHERE id = rec.id AND product_id = 0 AND state = '3A' AND state_final >= 0;
      END IF;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298348 (class 1255 OID 16533)
-- Name: fix_status_amount(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fix_status_amount() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
  z3 INT;
BEGIN
    FOR rec IN (SELECT id, status_amount,total_item,status_amount->>'S' "s",status_amount->>'3A' "3a",status_amount->>'3AP' "3ap",status_amount->>'3P' "3p",status_amount->>'3Z' "3z"
                FROM wh_inventory_item
                WHERE total_item < cast(status_amount->>'3Z' as int)) LOOP
      z3 = rec.total_item;
      RAISE NOTICE '%', z3;
      UPDATE wh_inventory_item SET status_amount = jsonb_set(rec.status_amount, '{3Z}', ('"' || z3 || '"')::jsonb) where id = rec.id;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298349 (class 1255 OID 16534)
-- Name: get_data_t(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_data_t(from_date date, to_date date) RETURNS TABLE(code text, flow text, mo_state text, po_state text, product_link text, pagent text, customer_paid_date text, pagent_order_date text, supplier_order_number text, supplier_order_number_date text, supplier_tracking_number text, supplier_tracking_number_date text, warehouse_scan_date text)
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
  stn TEXT;
BEGIN
    FOR rec IN (SELECT * FROM merchant_order
    JOIN merchant on merchant.id = merchant_order.merchant_id
    WHERE state_final >=0
       AND merchant_order.created_at BETWEEN from_date AND to_date
       AND merchant.is_cbe = false AND merchant.code != 'ME2G'
    AND merchant.code != 'PRKA') LOOP
  code := rec.code;
  flow := rec.flow;
  supplier_order_number := rec.supplier_order_number;
  mo_state := rec.state;
  
  SELECT link INTO product_link
  FROM product
  WHERE merchant_order_id = rec.id LIMIT 1;
  
  SELECT pagent.name || ' - ' || pagent.code,
   TO_CHAR(pagent_order.created_at, 'YYYY-MM-DD HH24:MI:SS'),
   pagent_order.state
  INTO pagent, pagent_order_date, po_state
  FROM pagent_order
  JOIN pagent ON pagent.id = pagent_order.pagent_id
  WHERE pagent_order.state_final >=0 AND pagent_order.merchant_order_id = rec.id LIMIT 1;

  SELECT MIN(TO_CHAR(moh.updated_at, 'YYYY-MM-DD HH24:MI:SS'))
  INTO supplier_order_number_date
     FROM merchant_order_history moh
     WHERE moh.merchant_order_id = rec.id
   AND moh.changes ->> 'supplier_order_number' != '';
         
  SELECT MIN(TO_CHAR(moh.updated_at, 'YYYY-MM-DD HH24:MI:SS'))
  INTO customer_paid_date
  FROM merchant_order_history moh
  WHERE moh.merchant_order_id = rec.id
   AND moh.changes ->> 'state' IN ('1Z', '1SB');
  
  supplier_tracking_number := '';
     supplier_tracking_number_date := '';
     warehouse_scan_date := '';

  IF rec.supplier_tracking_number = '' OR rec.supplier_tracking_number = '-' OR rec.supplier_tracking_number isnull THEN
   RETURN NEXT;
  END IF;
  FOR stn IN (SELECT regexp_split_to_table(rec.supplier_tracking_number, ' ')) LOOP
   IF stn IN ('/', 'c', 'chờ', 'có', 'd', 'f', 'tracking', 'chờ tracking', '', '-', '1', '"') THEN
    CONTINUE;
   END IF;
   
   supplier_tracking_number := stn;

   SELECT MIN(TO_CHAR(moh.updated_at, 'YYYY-MM-DD HH24:MI:SS'))
   INTO supplier_tracking_number_date
   FROM merchant_order_history moh
   WHERE moh.merchant_order_id = rec.id
    AND moh.changes ->> 'supplier_tracking_number' != ''
    AND stn IN (SELECT regexp_split_to_table(moh.changes ->> 'supplier_tracking_number', ' '));
   
   SELECT MIN(TO_CHAR(whi.created_at, 'YYYY-MM-DD HH24:MI:SS'))
   INTO warehouse_scan_date
   FROM wh_inventory_item whi
   JOIN order_item oi ON oi.wh_inventory_item_id = whi.id
   WHERE whi.supplier_tracking_number = stn AND oi.merchant_order_id = rec.id;
   RETURN NEXT;
  END LOOP;
 END LOOP;
END
$$;


--
-- TOC entry 298466 (class 1255 OID 569896)
-- Name: get_merchant_for_test(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_merchant_for_test() RETURNS TABLE(name text, code text)
    LANGUAGE plpgsql
    AS $$
BEGIN
   RETURN QUERY SELECT
      merchant.name, merchant.code
   FROM
      merchant
   LIMIT 1;
END; $$;


--
-- TOC entry 298465 (class 1255 OID 569893)
-- Name: get_merchant_for_test(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_merchant_for_test(p_pattern character varying) RETURNS TABLE(name character varying, code character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
   RETURN QUERY SELECT
      name, code
   FROM
      merchant
   LIMIT 1 ;
END; $$;


--
-- TOC entry 298350 (class 1255 OID 16535)
-- Name: log_coupon_code_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_coupon_code_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'INSERT') THEN
    INSERT INTO coupon_code_history
        (coupon_code_id, revision, user_id, changes)
    VALUES
        (NEW.id, NEW.rid, NEW.action_admin_id, to_jsonb(NEW));
    ELSIF
    (TG_OP = 'UPDATE') THEN
        changes := to_jsonb
    ((hstore
    (NEW.*)-hstore
    (OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

-- ignore trivial changes
IF (changes = '{}'::JSONB) THEN
RETURN NULL;
END
IF;

        INSERT INTO coupon_code_history
    (coupon_code_id, revision, user_id, changes)
VALUES
    (NEW.id, NEW.rid, NEW.action_admin_id, changes);
END
IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298351 (class 1255 OID 16536)
-- Name: log_coupon_conidtion_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_coupon_conidtion_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'INSERT') THEN
    INSERT INTO coupon_condition_history
        (coupon_condition_id, revision, user_id, changes)
    VALUES
        (NEW.id, NEW.rid, NEW.action_admin_id, to_jsonb(NEW));
    ELSIF
    (TG_OP = 'UPDATE') THEN
        changes := to_jsonb
    ((hstore
    (NEW.*)-hstore
    (OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

-- ignore trivial changes
IF (changes = '{}'::JSONB) THEN
RETURN NULL;
END
IF;

        INSERT INTO coupon_condition_history
    (coupon_condition_id, revision, user_id, changes)
VALUES
    (NEW.id, NEW.rid, NEW.action_admin_id, changes);
END
IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298352 (class 1255 OID 16537)
-- Name: log_users_group_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_users_group_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO users_group_history (users_group_id, revision, user_id, changes)
        VALUES (NEW.id, NEW.rid, NEW.action_admin_id, to_jsonb(NEW));
    ELSIF (TG_OP = 'UPDATE') THEN
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN
            RETURN NULL;
        END IF;
        INSERT INTO users_group_history (users_group_id, revision, user_id, changes)
        VALUES (NEW.id, NEW.rid, NEW.action_admin_id, changes);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298353 (class 1255 OID 16538)
-- Name: mapping_cbe(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mapping_cbe() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  t2_row RECORD;
  rec RECORD;
BEGIN
    FOR rec IN (select * from wh_inventory_item where sku = supplier_tracking_number and status_amount->>'3A' isnull and status_amount->>'S' = '1' and warehouse = 'SZX001') LOOP
      SELECT * INTO t2_row FROM order_item WHERE state = '1SZ' AND state_final=0 AND gscode = rec.sku limit 1;
      RAISE NOTICE 'whi: %', rec.sku;
      RAISE NOTICE '%', t2_row.id;
      IF (t2_row.id IS NOT NULL) THEN
        RAISE NOTICE '%', t2_row.id;
        UPDATE order_item SET warehouse = rec.warehouse, sku = rec.sku, real_weight=rec.weight, weight=rec.weight, state = '3A',wh_inventory_item_id=rec.id WHERE id = t2_row.id AND state = '1SZ';
        UPDATE wh_inventory_item SET status_amount='{"S": 1, "3A": 1}'::jsonb WHERE id = rec.id;
      END IF;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298448 (class 1255 OID 568945)
-- Name: merchant_contract_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_contract_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO merchant_contract_history(merchant_contract_id, verify_state, term_state, user_id, changes) VALUES (NEW.id, NEW.verify_state, NEW.term_state, NEW.user_id, to_json(NEW));
    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;
        INSERT INTO merchant_contract_history(merchant_contract_id, verify_state, term_state, user_id, changes) VALUES (NEW.id, NEW.verify_state, NEW.term_state, NEW.user_id, changes);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298354 (class 1255 OID 16539)
-- Name: merchant_create_mseq(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_create_mseq() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS mseq_%s', NEW.id);
    RETURN NEW;
END
$$;


--
-- TOC entry 298355 (class 1255 OID 16540)
-- Name: merchant_drop_mseq(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_drop_mseq() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE FORMAT('drop sequence IF EXISTS mseq_%s', OLD.id);
    RETURN NEW;
END
$$;


--
-- TOC entry 298356 (class 1255 OID 16541)
-- Name: merchant_order_create_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_order_create_code() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
BEGIN
    IF (substring(NEW.code, '\.$') IS NULL) THEN
        RETURN NEW;
    END IF;

    NEW.code = NEW.code || LPAD(next_mseq(NEW.merchant_id)::text, 4, '0');
    RETURN NEW;
END
$_$;


--
-- TOC entry 298357 (class 1255 OID 16542)
-- Name: merchant_order_create_mohseq(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_order_create_mohseq() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS mohseq_%s', NEW.id);
    RETURN NEW;
END
$$;


--
-- TOC entry 298358 (class 1255 OID 16543)
-- Name: merchant_order_drop_mohseq(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_order_drop_mohseq() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE FORMAT('DROP SEQUENCE IF EXISTS mohseq_%s', OLD.id);
    RETURN NEW;
END
$$;


--
-- TOC entry 298359 (class 1255 OID 16544)
-- Name: merchant_order_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_order_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        -- INSERT INTO merchant_order_history(revision, merchant_order_id, changes, user_id, curr_state, prev_state, state_final)
        -- VALUES (nextval('merchant_order_history_seq'), OLD.id, to_json(OLD), OLD.action_admin_id, OLD.state, OLD.state, OLD.state_final);
        RETURN NULL;
    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO merchant_order_history(revision, merchant_order_id, changes, user_id, curr_state, state_final)
        VALUES (NEW.rid, NEW.id, to_json(NEW), NEW.action_admin_id, NEW.state, NEW.state_final);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO merchant_order_history(revision, merchant_order_id, changes, user_id, curr_state, state_final)
        VALUES (NEW.rid, NEW.id, changes, NEW.action_admin_id, NEW.state, NEW.state_final);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298360 (class 1255 OID 16545)
-- Name: merchant_order_history_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_order_history_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- TOC entry 298361 (class 1255 OID 16546)
-- Name: merchant_order_item_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_order_item_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- TOC entry 298362 (class 1255 OID 16547)
-- Name: merchant_order_test_item_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_order_test_item_update() RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE total_closed    INT2;
    DECLARE total_cancelled INT2;
    DECLARE mid             INT8;
    BEGIN
        FOR mid IN (SELECT id FROM "merchant_order") LOOP
            SELECT COUNT(*) INTO total_closed
            FROM "order_item"
            WHERE merchant_order_id = mid AND state_final <> 0;
            SELECT COUNT(*) INTO total_cancelled
            FROM "order_item"
            WHERE merchant_order_id = mid AND state_final < 0;
            UPDATE "merchant_order" SET closed_items = @total_closed,cancelled_items = @total_cancelled WHERE id = mid;
        END LOOP;
    END;
$$;


--
-- TOC entry 298363 (class 1255 OID 16548)
-- Name: merchant_order_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_order_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF (NEW.merchant_id IS NOT NULL AND NEW.merchant_id <> 0) THEN
            NEW.merchant := (SELECT code FROM merchant WHERE id = NEW.merchant_id);
            IF (NEW.merchant IS NULL) THEN
                RAISE EXCEPTION 'merchant does not exist or has not been activated';
            END IF;
        END IF;
		RETURN NEW;
    END;
$$;


--
-- TOC entry 298364 (class 1255 OID 16549)
-- Name: merchant_plan_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_plan_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF (NEW.merchant_id IS NOT NULL AND NEW.merchant_id <> 0) THEN
            NEW.merchant := (SELECT code FROM merchant WHERE id = NEW.merchant_id);
            IF (NEW.merchant IS NULL) THEN
                RAISE EXCEPTION 'merchant does not exist or has not been activated';
            END IF;
        END IF;
        IF (NEW.plan_id IS NOT NULL AND NEW.plan_id <> 0) THEN
            NEW.plan_name := (SELECT name FROM plan WHERE id = NEW.plan_id);
            NEW.max_weight := (SELECT max_weight FROM plan WHERE id = NEW.plan_id);
            IF (NEW.plan_name IS NULL) THEN
                RAISE EXCEPTION 'plan does not exist or has not been activated';
            END IF;
        END IF;
        IF (NEW.fallback_from_plan_id IS NOT NULL AND NEW.fallback_from_plan_id <> 0) THEN
            NEW.fallback_from_plan_name := (SELECT name FROM plan WHERE id = NEW.fallback_from_plan_id);
        END IF;
        IF (NEW.upgrade_from_plan_id IS NOT NULL AND NEW.upgrade_from_plan_id <> 0) THEN
            NEW.upgrade_from_plan_name := (SELECT name FROM plan WHERE id = NEW.upgrade_from_plan_id);
        END IF;
  RETURN NEW;
    END;
$$;


--
-- TOC entry 298365 (class 1255 OID 16550)
-- Name: merchant_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.merchant_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN

        IF (NEW.province IS NOT NULL AND NEW.province <> '') THEN
            NEW.province_name := (SELECT name FROM province WHERE code = NEW.province);
            IF (NEW.province_name IS NULL) THEN
                RAISE EXCEPTION 'province does not exist';
            END IF;
        END IF;

        IF (NEW.district IS NOT NULL AND NEW.district <> '') THEN
            NEW.district_name := (SELECT name FROM district WHERE code = NEW.district);
            IF (NEW.district_name IS NULL) THEN
                RAISE EXCEPTION 'district does not exist';
            END IF;
        END IF;

        IF (NEW.ward IS NOT NULL AND NEW.ward <> '') THEN
            NEW.ward_name := (SELECT name FROM ward WHERE code = NEW.ward);
            IF (NEW.ward_name IS NULL) THEN
                RAISE EXCEPTION 'ward does not exist';
            END IF;
        END IF;

        RETURN NEW;
    END;
$$;


--
-- TOC entry 298366 (class 1255 OID 16551)
-- Name: migrate_category_for_product(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_category_for_product() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  orderItemCateg TEXT;
  rec RECORD;
BEGIN
    FOR rec IN (SELECT * FROM product WHERE category isnull) LOOP
      SELECT category INTO orderItemCateg FROM order_item WHERE merchant_order_id = rec.merchant_order_id
    AND category notnull AND category != '' LIMIT 1;
   IF orderItemCateg notnull AND orderItemCateg != '' THEN
    UPDATE product SET category = orderItemCateg WHERE id = rec.id;
   ELSE
    UPDATE order_item SET category = '0015'
  WHERE merchant_order_id = rec.merchant_order_id AND (category isnull or category = '');
  
  UPDATE product SET category = '0015'
  WHERE id = rec.id;
   END IF;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298367 (class 1255 OID 16552)
-- Name: migrate_data_order_item_f3_pack(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_data_order_item_f3_pack() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  whInventoryItemID INT8;
  parcelID INT8;
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id FROM order_item) LOOP
      SELECT wh_inventory_item_id, parcel_id INTO whInventoryItemID, parcelID FROM order_item_pack where order_item_id = rec.id;
      UPDATE order_item SET wh_inventory_item_id = whInventoryItemID, parcel_id = parcelID WHERE id = rec.id;
      whInventoryItemID := NULL;
      parcelID := NULL;
    END LOOP;
    -- DELETE FROM order_item_pack;
    -- DROP TABLE IF EXISTS order_item_pack;
    RETURN 'done';
END
$$;


--
-- TOC entry 298346 (class 1255 OID 16553)
-- Name: migrate_data_order_item_pack(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_data_order_item_pack() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  whInventoryItemID INT8;
  parcelID INT8;
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id FROM order_item) LOOP
      SELECT wh_inventory_item_id, parcel_id INTO whInventoryItemID, parcelID FROM order_item_pack where order_item_id = rec.id;
      UPDATE order_item SET wh_inventory_item_id = whInventoryItemID, parcel_id = parcelID WHERE id = rec.id;
      whInventoryItemID := NULL;
      parcelID := NULL;
    END LOOP;
    -- DELETE FROM order_item_pack;
    -- DROP TABLE IF EXISTS order_item_pack;
    RETURN 'done';
END
$$;


--
-- TOC entry 298336 (class 1255 OID 16554)
-- Name: migrate_merchant_code_on_order_items(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_merchant_code_on_order_items() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
  mcode text;
BEGIN
    FOR rec IN (SELECT * FROM order_item where merchant isnull and merchant_id notnull) LOOP
   SELECT code INTO mcode FROM merchant WHERE id = rec.merchant_id;
   UPDATE order_item SET merchant = mcode WHERE id = rec.id;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298368 (class 1255 OID 16555)
-- Name: migrate_merchant_id_on_order_item(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_merchant_id_on_order_item() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
  mc_id bigint;
BEGIN
    FOR rec IN (SELECT * FROM order_item where merchant_id isnull) LOOP
   SELECT id INTO mc_id FROM merchant WHERE code = rec.merchant;
   UPDATE order_item SET merchant_id = mc_id WHERE id = rec.id;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298369 (class 1255 OID 16556)
-- Name: migrate_mo_state_done(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_mo_state_done() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
    UPDATE merchant_order mo
 SET state = 'D'
 WHERE id IN (SELECT id from merchant_order where state_final >=0 and state != 'D') and 
  (select count(id) from order_item where merchant_order_id = mo.id and state = 'D' and state_final >= 0) =
  (select count(id) from order_item where merchant_order_id = mo.id and state_final >= 0) AND
  (select count(id) from order_item where merchant_order_id = mo.id and state_final >= 0) > 0;
    RETURN 'done';
END
$$;


--
-- TOC entry 298370 (class 1255 OID 16557)
-- Name: migrate_mos_1c_to_1z(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_mos_1c_to_1z() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
 UPDATE order_item SET state = '1Z' WHERE state_final >=0 AND merchant_order_id IN (SELECT id from merchant_order WHERE state = '1C' AND state_final >=0);
 
 UPDATE merchant_order SET state = '1Z' WHERE id IN (SELECT id from merchant_order WHERE state = '1C' AND state_final >=0);

 RETURN 'done';
END
$$;


--
-- TOC entry 298371 (class 1255 OID 16558)
-- Name: migrate_ois_1z_to_current_state(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_ois_1z_to_current_state() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
 rec RECORD;
BEGIN
 FOR rec IN (select order_item_id, curr_state from order_item_history oih 
    where oih.order_item_id IN (select id from order_item where state = '1Z') 
     AND revision >= (select max(revision) from order_item_history where order_item_id = oih.order_item_id)
    order by order_item_id, revision desc)
 LOOP
      UPDATE order_item
   SET state = rec.curr_state
   WHERE id = rec.order_item_id;
    END LOOP;
    
 RETURN 'done';
END
$$;


--
-- TOC entry 298372 (class 1255 OID 16559)
-- Name: migrate_order_item_sorting_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_order_item_sorting_code() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  sortingCode TEXT;
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id FROM order_item WHERE sorting_code isnull OR sorting_code = '') LOOP
      SELECT province.sorting_code INTO sortingCode
        FROM province
        INNER JOIN last_mile_shipping_info lm on lm.province = province.code
        INNER JOIN merchant_order mo ON mo.last_mile_shipping_info_id = lm.id
        INNER JOIN order_item ON order_item.merchant_order_id = mo.id
        WHERE order_item.id = rec.id;
      IF sortingCode ISNULL THEN
        sortingCode = '2';
      END IF;
      UPDATE order_item SET sorting_code = sortingCode WHERE id = rec.id;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298373 (class 1255 OID 16560)
-- Name: migrate_order_price(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_order_price() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (SELECT * FROM merchant_order WHERE id NOT IN (SELECT order_id as id FROM order_price)) LOOP
      INSERT INTO order_price (order_id, pricing_version, est_basket_value_x, basket_value_x, us_tax_x, us_shipping_fee_x, purchasing_fee_x, surcharge_x, gido_fee_x, total_fee_x, total_amount_x, discount_vnd, total_amount_after_discount_vnd, exchange_rate, chargeable_weight, action_admin_id)
      VALUES (rec.id, 0, rec.est_basket_value_x, rec.basket_value_x, rec.us_tax_x, rec.us_shipping_fee_x, rec.purchase_fee_x, rec.surcharge_x, rec.gido_fee_x, (rec.total_fee_vnd/23390.0*100)::int4, (rec.total_amount_vnd/23390.0*100)::int4, rec.discount_vnd, rec.total_amount_vnd, 23390, rec.chargeable_weight, 0::INT8);
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298374 (class 1255 OID 16561)
-- Name: migrate_pagent_order(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_pagent_order() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
  sf INT2;
  ss TEXT;
BEGIN
    FOR rec IN (SELECT DISTINCT ON (merchant_order_id, changes->>'pagent_id') merchant_order_id, mo.code, changes->>'pagent_id' as "pagent_id", oi.pagent_id as "cur_pagent_id", oih.user_id, oih.updated_at as "created_at", oi.consol_warehouse as "warehouse", oi.pagent_est_purchasing_amount_x, oi.pagent_purchase_price_x, oi.pagent_other_fee_x, pagent_commission_percent, pagent_commission_x, oi.supplier_order_number, oi.supplier_courier, oi.supplier_tracking_number, oi.state, oi.state_final
                FROM order_item oi
                INNER JOIN order_item_history oih ON oi.id = oih.order_item_id
                INNER JOIN merchant_order mo ON oi.merchant_order_id = mo.id
                WHERE prev_state = '1Z' AND curr_state = '2A') LOOP
      IF rec.pagent_id::TEXT <> rec.cur_pagent_id::TEXT OR (rec.pagent_id::TEXT = rec.cur_pagent_id::TEXT AND rec.state_final < 0) THEN
        sf = -2;
        ss = '2A';
      ELSEIF rec.state >= '2Z' THEN
        sf = 1;
        ss = '2Z';
      ELSE
        sf = 0;
        ss = rec.state;
      END IF;
      RAISE NOTICE '%', rec.pagent_est_purchasing_amount_x;
      INSERT INTO pagent_order (merchant_order_id, code, pagent_id, warehouse, total_amount_x, supplier_price_x, discount_x, shipping_fee_x, tax_x, currency, exchange_rate, commission_percent, commission_x, supplier_order_number, supplier_courier, supplier_tracking_number, state, state_final, created_at, action_admin_id)
      VALUES (rec.merchant_order_id, rec.code, rec.pagent_id::INT8, rec.warehouse, rec.pagent_est_purchasing_amount_x, rec.pagent_purchase_price_x, 0, 0, rec.pagent_other_fee_x, 'USD', rec.pagent_purchase_price_x, rec.pagent_commission_percent, rec.pagent_commission_x, rec.supplier_order_number, rec.supplier_courier, rec.supplier_tracking_number, ss, sf, rec.created_at, rec.user_id);
      IF ss = '2A' OR ss = '2B' OR (ss = '2Z' AND sf = 0) THEN
        UPDATE merchant_order SET state = ss WHERE id = rec.merchant_order_id;
      END IF;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298375 (class 1255 OID 16562)
-- Name: migrate_product_info(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_product_info() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  t2_row order_item%ROWTYPE;
  quantity INT4;
  rec RECORD;
  lid INT8;
BEGIN
    FOR rec IN (SELECT id FROM merchant_order) LOOP
      SELECT DISTINCT ON (merchant_order_id) * INTO t2_row FROM order_item WHERE merchant_order_id = rec.id;
      SELECT count(*) INTO quantity FROM order_item where merchant_order_id = rec.id;
      SELECT id INTO lid FROM product where merchant_order_id = rec.id AND sku = t2_row.sku AND name = t2_row.product_name AND link = t2_row.product_link;
      IF lid IS NULL THEN
        INSERT INTO product (merchant_order_id, sku, name, category, link, price_x, currency, gift, number_of_set, item_in_set)
        VALUES (rec.id, t2_row.sku, t2_row.product_name, t2_row.category, t2_row.product_link, t2_row.supplier_price_x, 'USD', false, quantity, 1)
        RETURNING id INTO lid;
      END IF;
      UPDATE order_item SET product_id = lid WHERE merchant_order_id = rec.id;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298376 (class 1255 OID 16563)
-- Name: migrate_shipping_info(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_shipping_info() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  t2_row order_item%ROWTYPE;
  lid INT8;
  rec RECORD;
  m_row merchant%ROWTYPE;
BEGIN
  FOR rec IN (SELECT id FROM merchant_order WHERE last_mile_shipping_info_id = 0 OR last_mile_shipping_info_id isnull) LOOP
    SELECT DISTINCT ON (merchant_order_id) * INTO t2_row FROM order_item WHERE merchant_order_id = rec.id;
    IF (t2_row.shipping_name IS NULL OR t2_row.shipping_phone IS NULL OR t2_row.shipping_address IS NULL)
      OR (t2_row.shipping_name = '' OR t2_row.shipping_phone = '' OR t2_row.shipping_address = '') THEN
      IF t2_row.merchant_id IS NULL THEN
        continue;
      END IF;
      SELECT * INTO m_row FROM merchant WHERE id = t2_row.merchant_id;
      SELECT id INTO lid
      FROM last_mile_shipping_info 
      WHERE 
        name = m_row.name 
        AND phone = m_row.phone
        AND address = m_row.address;
      IF lid IS NULL THEN
        INSERT INTO last_mile_shipping_info (merchant_id, name, email, phone,address, ward, district, province, created_at, updated_at)
        VALUES (m_row.id, m_row.name, m_row.email, m_row.phone, m_row.address, m_row.ward, m_row.district, m_row.province, now(), now())
        RETURNING id INTO lid;
      END IF;
      UPDATE merchant_order SET last_mile_shipping_info_id = lid, note_shipping = t2_row.note_shipping WHERE id = rec.id;
      continue;
    END IF;
    SELECT id INTO lid
    FROM last_mile_shipping_info 
    WHERE 
      name = t2_row.shipping_name 
      AND phone = t2_row.shipping_phone
      AND address = t2_row.shipping_address;
    IF lid IS NULL THEN
      INSERT INTO last_mile_shipping_info (merchant_id, name, phone,address, ward, district, province, created_at, updated_at)
      VALUES (t2_row.merchant_id, t2_row.shipping_name, t2_row.shipping_phone, t2_row.shipping_address, t2_row.shipping_ward, t2_row.shipping_district, t2_row.shipping_province, now(), now())
      RETURNING id INTO lid;
    END IF;
    UPDATE merchant_order SET last_mile_shipping_info_id = lid, note_shipping = t2_row.note_shipping WHERE id = rec.id;

  END LOOP;
  RETURN 'done';
END
$$;


--
-- TOC entry 298429 (class 1255 OID 538781)
-- Name: migrate_tracking_package_mo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_tracking_package_mo() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
  tracking RECORD;
  tracking_rel RECORD;
  newTracking RECORD;
BEGIN
    FOR rec IN (SELECT * FROM package_info WHERE tracking_id <> 0) LOOP
      FOR tracking_rel IN (
              SELECT * FROM tracking_merchant_order_rel 
              WHERE tracking_id = rec.tracking_id AND merchant_order_id = rec.merchant_order_id) LOOP
        SELECT * INTO tracking FROM tracking_number WHERE id = rec.id LIMIT 1;

        IF (tracking.merchant_order_id ISNULL OR tracking.merchant_order_id = 0) THEN
          UPDATE tracking_number SET merchant_order_id = rec.merchant_order_id WHERE id = rec.id;
        ELSE
          IF (tracking.merchant_order_id <> tracking_rel.merchant_order_id) THEN
            INSERT INTO tracking_number(id, code, action_admin_id, created_at, updated_at, merchant_order_id, no_packages)
              VALUES (rec.id, rec.tracking_number, 0, now(), now(), rec.merchant_order_id, tracking_rel.no_packages);
            UPDATE package_info SET tracking_id = rec.id 
              WHERE id = rec.id AND merchant_order_id = rec.merchant_order_id;
            UPDATE order_item SET tracking_number_id = rec.id 
              WHERE merchant_order_id = rec.merchant_order_id AND tracking_id = rec.tracking_id AND state <= '1SZ';
          END IF;
        END IF;

      END LOOP;
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298377 (class 1255 OID 16564)
-- Name: next_box_seq(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.next_box_seq(curr_time text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 0 FROM pg_class WHERE relname = 'box_seq_' || CURR_TIME
    ) THEN
        EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS box_seq_%s', CURR_TIME);
    END IF;
    RETURN nextval('box_seq_' || CURR_TIME);
END
$$;


--
-- TOC entry 298378 (class 1255 OID 16565)
-- Name: next_delivery_order_f4_seq(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.next_delivery_order_f4_seq(curr_time text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 0 FROM pg_class WHERE relname = 'delivery_order_f4_seq_' || CURR_TIME
    ) THEN
        EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS delivery_order_f4_seq_%s', CURR_TIME);
    END IF;
    RETURN nextval('delivery_order_f4_seq_' || CURR_TIME);
END
$$;


--
-- TOC entry 298379 (class 1255 OID 16566)
-- Name: next_delivery_order_seq(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.next_delivery_order_seq(curr_time text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 0 FROM pg_class WHERE relname = 'delivery_order_seq_' || CURR_TIME
    ) THEN
        EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS delivery_order_seq_%s', CURR_TIME);
    END IF;
    RETURN nextval('delivery_order_seq_' || CURR_TIME);
END
$$;


--
-- TOC entry 298380 (class 1255 OID 16567)
-- Name: next_mseq(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.next_mseq(mid bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
        rs := setval('mseq_' || mid, 1);
    END IF;
    RETURN rs;
END
$$;


--
-- TOC entry 298381 (class 1255 OID 16568)
-- Name: next_parcel_f4_seq(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.next_parcel_f4_seq(curr_time text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 0 FROM pg_class WHERE relname = 'parcel_f4_seq_' || CURR_TIME
    ) THEN
        EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS parcel_f4_seq_%s', CURR_TIME);
    END IF;
    RETURN nextval('parcel_f4_seq_' || CURR_TIME);
END
$$;


--
-- TOC entry 298382 (class 1255 OID 16569)
-- Name: next_parcel_seq(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.next_parcel_seq(curr_time text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 0 FROM pg_class WHERE relname = 'parcel_seq_' || CURR_TIME
    ) THEN
        EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS parcel_seq_%s', CURR_TIME);
    END IF;
    RETURN nextval('parcel_seq_' || CURR_TIME);
END
$$;


--
-- TOC entry 298441 (class 1255 OID 559179)
-- Name: next_stock_seq(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.next_stock_seq(stock_seq_name text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE 
  SEQ_NAME text;
BEGIN
    SEQ_NAME = 'stock_seq_' || stock_seq_name;
    IF NOT EXISTS (
        SELECT 0 FROM pg_class WHERE relname = SEQ_NAME
    ) THEN
        EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS %s', SEQ_NAME);
    END IF;

    RETURN nextval(SEQ_NAME);
END
$$;


--
-- TOC entry 298383 (class 1255 OID 16570)
-- Name: order_item_create_oihseq(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.order_item_create_oihseq() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE FORMAT('CREATE SEQUENCE IF NOT EXISTS oihseq_%s', NEW.id);
    RETURN NEW;
END
$$;


--
-- TOC entry 298384 (class 1255 OID 16571)
-- Name: order_item_drop_oihseq(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.order_item_drop_oihseq() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE FORMAT('drop sequence IF EXISTS oihseq_%s', OLD.id);
    RETURN NEW;
END
$$;


--
-- TOC entry 298385 (class 1255 OID 16572)
-- Name: order_item_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.order_item_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        -- INSERT INTO order_item_history(revision, order_item_id, changes, user_id, curr_state, prev_state, state_final)
        -- VALUES (nextval('order_item_history_seq'), OLD.id, to_json(OLD), OLD.action_admin_id, OLD.state, OLD.state, OLD.state_final);
        RETURN NULL;
    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO order_item_history(revision, order_item_id, changes, user_id, curr_state, state_final)
        VALUES (NEW.rid, NEW.id, to_json(NEW), NEW.action_admin_id, NEW.state, NEW.state_final);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "revision"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO order_item_history(revision, order_item_id, changes, user_id, curr_state, state_final)
        VALUES (NEW.rid, NEW.id, changes, NEW.action_admin_id, NEW.state, NEW.state_final);
    END IF;
    RETURN NULL;
END;
$$;


--
-- TOC entry 298386 (class 1255 OID 16573)
-- Name: order_item_history_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.order_item_history_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- TOC entry 298387 (class 1255 OID 16574)
-- Name: order_item_pack_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.order_item_pack_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO order_item_pack_history(revision, order_item_id, changes, user_id)
        VALUES (nextval('order_item_pack_history_seq'), OLD.order_item_id, to_json(OLD), OLD.action_admin_id);

    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO order_item_pack_history(revision, order_item_id, changes, user_id)
        VALUES (NEW.rid, NEW.order_item_id, to_json(NEW), NEW.action_admin_id);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO order_item_pack_history(revision, order_item_id, changes, user_id)
        VALUES (NEW.rid, NEW.order_item_id, changes, NEW.action_admin_id);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298423 (class 1255 OID 16575)
-- Name: order_item_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.order_item_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE sortingCode TEXT;
BEGIN
    IF (NEW.gcode != '') THEN
        IF (TG_OP = 'UPDATE' AND OLD.gcode != '') THEN
            IF (OLD.gcode != NEW.gcode) THEN
                RAISE EXCEPTION 'gcode can not be changed';
            END IF;
        END IF;
    END IF;
    IF (NEW.sorting_code = '' OR NEW.sorting_code ISNULL) THEN
        SELECT province.sorting_code INTO sortingCode
          FROM province
          INNER JOIN last_mile_shipping_info lm on lm.province = province.code
          INNER JOIN merchant_order mo ON mo.last_mile_shipping_info_id = lm.id
          WHERE mo.id = NEW.merchant_order_id;
        IF sortingCode ISNULL THEN
          sortingCode = '2';
        END IF;
        NEW.sorting_code = sortingCode;
    END IF;
    RETURN NEW;
END
$$;


--
-- TOC entry 298388 (class 1255 OID 16576)
-- Name: order_item_update_weight(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.order_item_update_weight() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE realWeight    INT4;
    DECLARE estWeight  INT4;
    BEGIN
        SELECT sum(real_weight) INTO realWeight
        FROM "order_item"
        WHERE merchant_order_id = NEW.merchant_order_id AND state_final >= 0;
        SELECT sum(est_weight) INTO estWeight
        FROM "order_item"
        WHERE merchant_order_id = NEW.merchant_order_id AND state_final >= 0;
        UPDATE "merchant_order" SET est_weight = @estWeight,real_weight = @realWeight WHERE id = NEW.merchant_order_id;
        RETURN NEW;
    END;
$$;


--
-- TOC entry 298390 (class 1255 OID 16577)
-- Name: order_price_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.order_price_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO order_price_history(revision, order_id, changes, user_id)
        VALUES (nextval('order_price_history_seq'), OLD.order_id, to_json(OLD), OLD.action_admin_id);

    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO order_price_history(revision, order_id, changes, user_id)
        VALUES (NEW.rid, NEW.order_id, to_json(NEW), NEW.action_admin_id);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO order_price_history(revision, order_id, changes, user_id)
        VALUES (NEW.rid, NEW.order_id, changes, NEW.action_admin_id);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298431 (class 1255 OID 538829)
-- Name: package_info_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.package_info_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        -- INSERT INTO package_info_history(revision, tracking_id, changes, user_id, curr_tracking, prev_tracking, state_final)
        -- VALUES (nextval('package_info_history_seq'), OLD.id, to_json(OLD), OLD.action_admin_id, OLD.state, OLD.state, OLD.state_final);
        RETURN NULL;
    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO package_info_history(revision, package_info_id, changes, user_id, curr_tracking)
        VALUES (NEW.rid, NEW.id, to_json(NEW), NEW.action_admin_id, NEW.tracking_number);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "revision"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO package_info_history(package_info_id, revision, changes, user_id, curr_tracking, prev_tracking)
        VALUES (NEW.id, NEW.rid, changes, NEW.action_admin_id, NEW.tracking_number, OLD.tracking_number);
    END IF;
    RETURN NULL;
END;
$$;


--
-- TOC entry 298391 (class 1255 OID 16578)
-- Name: pagent_order_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pagent_order_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        RETURN NULL;

    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO pagent_order_history(revision, pagent_order_id, curr_state, state_final, changes, user_id)
        VALUES (NEW.rid, NEW.id, NEW.state, NEW.state_final, to_json(NEW), NEW.action_admin_id);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO pagent_order_history(revision, pagent_order_id, prev_state, curr_state, state_final, changes, user_id)
        VALUES (NEW.rid, NEW.id, OLD.state, NEW.state, NEW.state_final, changes, NEW.action_admin_id);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298427 (class 1255 OID 16579)
-- Name: parcel_create_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.parcel_create_code() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  CURR_TIME TEXT;
  COUNT_PARCEL INT;
BEGIN
    IF (NEW.code ISNULL OR NEW.code = '') THEN
      CURR_TIME = (select substring(date_part('year', CURRENT_DATE at time zone 'ict')::text, 3, 2)::text || lpad(date_part('month', CURRENT_DATE at time zone 'ict')::text, 2, '0'));
      IF NEW.state = '3A' THEN
        NEW.code = 'GIC2' || CURR_TIME || LPAD(next_parcel_seq(CURR_TIME)::text, 4, '0');
      ELSE                                                                                                                                                                            
        NEW.code = 'P4' || CURR_TIME || LPAD(next_parcel_f4_seq(CURR_TIME)::text, 6, '0');
      END IF;
    ELSE
      IF NEW.parcel_type = 'DAIGOU' THEN
        SELECT COUNT(code) INTO COUNT_PARCEL 
        FROM parcel 
        WHERE id IN (
          SELECT DISTINCT parcel.id
          FROM parcel
          JOIN parcel_item on parcel.id = parcel_item.parcel_id
          JOIN wh_inventory_item ON parcel_item.wh_inventory_item_id = wh_inventory_item.id
          WHERE wh_inventory_item.supplier_tracking_number = NEW.code AND parcel.code !~ 'GIC'
        );
        IF COUNT_PARCEL > 0 THEN
          NEW.code = NEW.code || '-' || COUNT_PARCEL::text;
        END IF;
      END IF;
    END IF;
    RETURN NEW;
END
$$;


--
-- TOC entry 298392 (class 1255 OID 16580)
-- Name: parcel_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.parcel_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        RETURN NULL;
    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO parcel_history(revision, parcel_id, changes, user_id, curr_state)
        VALUES (NEW.rid, NEW.id, to_json(NEW), NEW.action_admin_id, NEW.state);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO parcel_history(revision, parcel_id, changes, user_id, prev_state, curr_state)
        VALUES (NEW.rid, NEW.id, changes, NEW.action_admin_id, OLD.state, NEW.state);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298393 (class 1255 OID 16581)
-- Name: plan_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.plan_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO plan_history(revision, plan_id, changes)
        VALUES (nextval('plan_history_seq'), OLD.id, to_json(OLD));

    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO plan_history(revision, plan_id, changes)
        VALUES (NEW.rid, NEW.id, to_json(NEW));

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO plan_history(revision, plan_id, changes)
        VALUES (NEW.rid, NEW.id, changes);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298394 (class 1255 OID 16582)
-- Name: pricing_config_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pricing_config_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO pricing_config_history(revision, pricing_config_id, changes, user_id)
        VALUES (nextval('pricing_config_history_seq'), OLD.id, to_json(OLD), OLD.action_admin_id);

    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO pricing_config_history(revision, pricing_config_id, changes, user_id)
        VALUES (NEW.rid, NEW.id, to_json(NEW), NEW.action_admin_id);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO pricing_config_history(revision, pricing_config_id, changes, user_id)
        VALUES (NEW.rid, NEW.id, changes, NEW.action_admin_id);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298411 (class 1255 OID 569071)
-- Name: replace_token_follow_platform(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.replace_token_follow_platform() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
		DELETE FROM user_fcm_token WHERE user_id = NEW.user_id and access_token = NEW.access_token and platform = NEW.platform and application = NEW.application;
    END IF;
    RETURN NEW;
END
$$;


--
-- TOC entry 298438 (class 1255 OID 559177)
-- Name: stock_request_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.stock_request_code() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  merchant RECORD;
  CURR_TIME text;
  stock_seq_name text;
BEGIN
    select * into merchant from merchant where id = NEW.merchant_id limit 1;
    CURR_TIME = (select substring(date_part('year', CURRENT_DATE at time zone 'ict')::text, 1, 4)::text || lpad(date_part('month', CURRENT_DATE at time zone 'ict')::text, 2, '0') || lpad(date_part('day', CURRENT_DATE at time zone 'ict')::text, 2, '0'));
    stock_seq_name = merchant.code || CURR_TIME;
    NEW.stock_request_number = stock_seq_name || '-' || next_stock_seq(stock_seq_name);
    RETURN NEW;
END;
$$;


--
-- TOC entry 298395 (class 1255 OID 16583)
-- Name: surcharge_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.surcharge_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO surcharge_history(revision, id, changes, user_id)
        VALUES (nextval('surcharge_history_seq'), OLD.id, to_json(OLD), OLD.action_admin_id);

    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO surcharge_history(revision, id, changes, user_id)
        VALUES (NEW.rid, NEW.id, to_json(NEW), NEW.action_admin_id);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO surcharge_history(revision, id, changes, user_id)
        VALUES (NEW.rid, NEW.id, changes, NEW.action_admin_id);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298464 (class 1255 OID 574655)
-- Name: sync_actual_weight_order_item_package_info(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_actual_weight_order_item_package_info() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    changes JSONB;
    rec RECORD;
    recItem RECORD;
BEGIN
    FOR rec in (select * from package_info where (actual_weight = 0 OR actual_weight is null) AND state > '1SZ' AND state_final >= 0) LOOP
        SELECT * INTO recItem FROM order_item where package_info_id = rec.id AND order_item.state = rec.state AND real_weight > 0 LIMIT 1;
        IF recItem.id > 0 THEN
            UPDATE package_info SET actual_weight = recItem.real_weight WHERE id = rec.id;
			raise info '%: %', rec.id, recItem.real_weight; 
        END IF;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298462 (class 1255 OID 574480)
-- Name: sync_order_item_package_info(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_order_item_package_info() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF NEW.package_info_id > 0 AND NEW.state = '3A' AND OLD.state = '1SZ' THEN
        update package_info set actual_weight = NEW.real_weight WHERE id = NEW.package_info_id;
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298396 (class 1255 OID 16584)
-- Name: sync_sku_from_product(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_sku_from_product() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (select distinct on (sku) product.id,sku,name_en,merchant_order.created_at,description,unit_weight,merchant_order.merchant
                from product 
                inner join merchant_order on merchant_order.id = product.merchant_order_id
                where sku <> '' and name_en <> '' and merchant_order.created_at >= '2019-03-01') LOOP
      RAISE NOTICE '%', rec.sku;
      INSERT INTO sku(id,sku,title,description,created_at,weight,source)
      VALUES (rec.id,rec.sku,rec.name_en,rec.description,rec.created_at,rec.unit_weight,rec.merchant)
      ON CONFLICT (sku)
      DO NOTHING;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298389 (class 1255 OID 516790)
-- Name: sync_sku_from_product_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_sku_from_product_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    SELECT * INTO rec FROM merchant_order WHERE id = NEW.merchant_order_id LIMIT 1;
    IF (rec.id IS NOT NULL) THEN
      INSERT INTO sku(id,sku,title,description,created_at,weight,source)
      VALUES (NEW.id,NEW.sku,NEW.name_en,NEW.description,NEW.created_at,NEW.unit_weight,rec.merchant)
      ON CONFLICT (sku)
      DO NOTHING;
    END IF;
    RETURN NEW;
END
$$;


--
-- TOC entry 298420 (class 1255 OID 531101)
-- Name: sync_state_order_item_mo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_state_order_item_mo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  countTotal INT;
  countState INT;
BEGIN
  IF NEW.state != OLD.state THEN
    SELECT COUNT(*) INTO countTotal FROM order_item WHERE gscode = NEW.gscode AND state_final >= 0;
    SELECT COUNT(*) INTO countState FROM order_item WHERE gscode = NEW.gscode AND state = NEW.state AND state_final >= 0;
    IF countState = countTotal THEN
      UPDATE merchant_order SET state = NEW.state WHERE code = NEW.gscode AND state = OLD.state AND merchant_type in ('cbe','cbe_transhipment');
    END IF;
  END IF;
  RETURN NULL;
END;
$$;


--
-- TOC entry 298397 (class 1255 OID 16585)
-- Name: sync_tracking_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_tracking_number() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (select mo.*
                  from merchant_order mo
                  inner join order_item oi on mo.id = oi.merchant_order_id
                  where mo.state = '1SZ' and oi.state = '1SZ' and oi.supplier_tracking_number != mo.supplier_tracking_number) LOOP
      RAISE NOTICE '%', rec.code;
      UPDATE order_item SET supplier_tracking_number = rec.supplier_tracking_number WHERE merchant_order_id = rec.id AND state = '1SZ' AND supplier_tracking_number != rec.supplier_tracking_number;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298398 (class 1255 OID 16586)
-- Name: sync_tracking_number_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_tracking_number_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    IF (NEW.state != '1SZ') THEN
      RETURN NEW;
    END IF;
    IF NEW.supplier_tracking_number <> '' THEN
      UPDATE order_item SET supplier_tracking_number = NEW.supplier_tracking_number WHERE merchant_order_id = NEW.id AND state = '1SZ' AND supplier_tracking_number <> NEW.supplier_tracking_number;
    END IF;
    RETURN NEW;
END
$$;


--
-- TOC entry 298428 (class 1255 OID 538695)
-- Name: tracking_number_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tracking_number_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        -- INSERT INTO tracking_number_history(revision, tracking_id, changes, user_id, curr_code, prev_code, state_final)
        -- VALUES (nextval('tracking_number_history_seq'), OLD.id, to_json(OLD), OLD.action_admin_id, OLD.state, OLD.state, OLD.state_final);
        RETURN NULL;
    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO tracking_number_history(revision, tracking_id, changes, user_id, curr_code)
        VALUES (NEW.rid, NEW.id, to_json(NEW), NEW.action_admin_id, NEW.code);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "revision"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO tracking_number_history(revision, tracking_id, changes, user_id, curr_code)
        VALUES (NEW.rid, NEW.id, changes, NEW.action_admin_id, NEW.code);
    END IF;
    RETURN NULL;
END;
$$;


--
-- TOC entry 298413 (class 1255 OID 530541)
-- Name: update_all_tracking_number_for_packages(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_all_tracking_number_for_packages() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  packageId INT8;
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id, code FROM tracking_number) LOOP
      SELECT id INTO packageId FROM package_info where tracking_id = rec.id;
      IF packageId <> 0 THEN
          UPDATE package_info SET tracking_number = rec.code WHERE id = packageId;
      END IF;
      packageId := NULL;
    END LOOP;
    -- DELETE FROM merchant_plan_order;
    -- DROP TABLE IF EXISTS merchant_plan_order;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298399 (class 1255 OID 16587)
-- Name: update_delivery_order_item(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_delivery_order_item() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
  record RECORD;
BEGIN
  FOR record  IN SELECT id, delivery_order_id FROM box
  WHERE delivery_order_id IS NOT NULL OR delivery_order_id > 0
  LOOP
    RAISE NOTICE 'Create delivery order %d', record.delivery_order_id;
    RAISE NOTICE 'box %d', record.id;
    INSERT INTO delivery_order_item(delivery_order_id, item_id, table_name) VALUES (record.delivery_order_id, record.id, 'box');
  END LOOP;
  RETURN;
END
$$;


--
-- TOC entry 298418 (class 1255 OID 530817)
-- Name: update_merchant_id_for_package_info(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_merchant_id_for_package_info() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (SELECT id, merchant_id FROM merchant_order) LOOP
      UPDATE package_info SET merchant_id = rec.merchant_id WHERE merchant_order_id = rec.id and merchant_id is null;
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298430 (class 1255 OID 541672)
-- Name: update_num_contact_deliver(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_num_contact_deliver() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.lastmile_status = 'WAITING_CONTACT' THEN
        IF CHAR_LENGTH(OLD.lastmile_status) > 0 THEN
            NEW.num_contact = OLD.num_contact + 1;
        ELSE
            NEW.num_contact = 0;
        END IF;
    ELSIF NEW.lastmile_status = 'IN_PROCESS' THEN
        IF OLD.num_deliver > 0 THEN
            NEW.num_deliver = OLD.num_deliver + 1;
        ELSE
            NEW.num_deliver = 1;
        END IF;         
    END IF;
    RETURN NEW; 
END;
$$;


--
-- TOC entry 298400 (class 1255 OID 16588)
-- Name: update_order_item_product(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_order_item_product() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (select sku, pro.id 
                from product as pro
                    inner join merchant_order as mo on mo.id = pro.merchant_order_id
                where mo.supplier_tracking_number ~ 'YES24') LOOP
      UPDATE order_item SET product_id = rec.id WHERE sku = rec.sku and supplier_tracking_number ~ 'YES24';
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298433 (class 1255 OID 541813)
-- Name: update_parcel_num_contact(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_parcel_num_contact() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    D_NUM_CONTACT INT;
    C_NUM_CONTACT INT;
    rec RECORD;
    new_rec RECORD;
BEGIN
    SELECT
        * INTO new_rec
    FROM
        parcel
    WHERE
        code = NEW.code;
    IF CHAR_LENGTH(NEW.code) > 0 THEN
        -- Get num_contact
        D_NUM_CONTACT = (
            SELECT
                CASE WHEN num_contact IS NULL THEN
                    0
                ELSE
                    num_contact
                END
            FROM
                parcel
            WHERE
                code = NEW.code)::int + 1;
        -- Update num_contact
        UPDATE
            parcel
        SET
            num_contact = D_NUM_CONTACT,
            action_admin_id = NEW.action_admin_id
        WHERE
            code = NEW.code;
        -- Update child parcel
        IF new_rec.parcel_type = 'GROUP' THEN
            FOR rec IN
            SELECT
                *
            FROM
                parcel
            WHERE
                vnhub_box_id = new_rec.id LOOP
                    -- Get num_contact
                    C_NUM_CONTACT = (
                        SELECT
                            CASE WHEN num_contact IS NULL THEN
                                0
                            ELSE
                                num_contact
                            END
                        FROM
                            parcel
                        WHERE
                            id = rec.id)::int + 1;
                    -- Update num_contact
                    UPDATE
                        parcel
                    SET
                        num_contact = C_NUM_CONTACT,
                        action_admin_id = NEW.action_admin_id
                    WHERE
                        id = rec.id;
                    -- reset num_contact
                    C_NUM_CONTACT = 0;
                END LOOP;
        END IF;
        -- Change last_mile_status
        IF D_NUM_CONTACT > 2 AND NEW.call_status = 'fail' THEN
            UPDATE
                parcel
            SET
                last_mile_status = 'WAITING_CUSTOMER_CONFIRM_RETURN',
                action_admin_id = NEW.action_admin_id
            WHERE
                code = NEW.code;
        END IF;
    END IF;
    RETURN NULL;
END;
$$;


--
-- TOC entry 298412 (class 1255 OID 542431)
-- Name: update_parcel_num_deliver(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_parcel_num_deliver() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    C_NUM_DELIVER INT;
    new_rec RECORD;
    rec RECORD;
BEGIN
    -- Change parcel last mile status to BOOKING_CREATED
    IF NEW.status = 'ACCEPTED' THEN
        UPDATE
            parcel
        SET
            last_mile_status = 'BOOKING_CREATED'
        WHERE
            code = NEW.code;
    END IF;
    --
    IF NEW.status = 'IN PROCESS' OR NEW.status = 'Delivering' THEN
        UPDATE
            parcel
        SET
            num_deliver = (
                SELECT
                    count(id)
                FROM
                    last_mile_booking_history
                WHERE
                    code = NEW.code
                    AND status IN ('IN PROCESS', 'Delivering')
                GROUP BY
                    code),
            last_mile_status = 'IN_PROCESS'
        WHERE
            code = NEW.code;
        -- Update child parcel
        SELECT
            * INTO new_rec
        FROM
            parcel
        WHERE
            code = NEW.code;
        IF new_rec.parcel_type = 'GROUP' THEN
            FOR rec IN
            SELECT
                *
            FROM
                parcel
            WHERE
                vnhub_box_id = new_rec.id LOOP
                    -- Get num_deliver
                    C_NUM_DELIVER = (
                        SELECT
                            CASE WHEN num_deliver IS NULL THEN
                                0
                            ELSE
                                num_deliver
                            END
                        FROM
                            parcel
                        WHERE
                            id = rec.id)::int + 1;
                    -- Update num_deliver
                    UPDATE
                        parcel
                    SET
                        num_deliver = C_NUM_DELIVER
                    WHERE
                        id = rec.id;
                    -- reset num_deliver
                    C_NUM_DELIVER = 0;
                END LOOP;
        END IF;
    END IF;
    --
    IF NEW.status = 'FAILED' OR NEW.status = 'DeliverFail' THEN
        UPDATE
            parcel
        SET
            last_mile_status = 'DELIVERY_FAIL'
        WHERE
            code = NEW.code;
    END IF;
    -- Change parcel last mile status to DONE
    IF NEW.status = 'Delivered' OR NEW.status = 'COMPLETED' THEN
        UPDATE
            parcel
        SET
            last_mile_status = 'DONE'
        WHERE
            code = NEW.code;
    END IF;
    RETURN NEW;
END;
$$;


--
-- TOC entry 298401 (class 1255 OID 16589)
-- Name: update_rid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_rid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.rid = nextval(TG_ARGV[0]);
    RETURN NEW;
END
$$;


--
-- TOC entry 298402 (class 1255 OID 16590)
-- Name: update_seller_cbe_parcel(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_seller_cbe_parcel() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (select s.*, p.code
                  from parcel p 
                  inner join order_item oi on oi.parcel_id = p.id
                  inner join merchant_order mo on mo.id = oi.merchant_order_id
                  inner join seller s on s.id = mo.seller_id
                  where p.quantity = 1 and p.state = '3A' and p.shipper_name != s.name) LOOP
      RAISE NOTICE '%', rec.code;
      UPDATE parcel SET shipper_name = rec.name, shipper_address = rec.address, shipper_tel = rec.phone WHERE code = rec.code AND state = '3A' AND shipper_name != rec.name;
    END LOOP;
    RETURN 'done';
END
$$;


--
-- TOC entry 298432 (class 1255 OID 542780)
-- Name: update_state_for_package_info(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_state_for_package_info() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
    FOR rec IN (select oi.id, oi.gscode, oi.state, oi.state_final, pi.id as package_info_id
                from order_item as oi
                inner join package_info as pi
                on oi.merchant_order_id = pi.merchant_order_id
                inner join merchant_order as mo
                on oi.merchant_order_id = mo.id
                where (oi.package_info_id is null or oi.package_info_id = 0) and merchant_type in ('cbe', 'cbe_transhipment')) LOOP
      UPDATE package_info SET tracking_number = rec.gscode, state = rec.state, state_final = rec.state_final WHERE id = rec.package_info_id;
      UPDATE order_item SET package_info_id = rec.package_info_id WHERE id = rec.id;
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298416 (class 1255 OID 530570)
-- Name: update_state_package_info_by_order_item_state(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_state_package_info_by_order_item_state() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    -- ignore trivial changes
    IF (NEW.state = OLD.state AND NEW.state_final = OLD.state_final) THEN RETURN NEW; END IF;
    UPDATE package_info set state = NEW.state, state_final = NEW.state_final where id = NEW.package_info_id;
    RETURN NEW;
END;
$$;


--
-- TOC entry 298425 (class 1255 OID 538696)
-- Name: update_tracking_no_packages(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_tracking_no_packages() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  noPackages INT;
BEGIN
    SELECT COUNT(id) INTO noPackages FROM package_info WHERE merchant_order_id = NEW.merchant_order_id AND tracking_id = NEW.tracking_id;
    UPDATE tracking_number SET no_packages = noPackages WHERE id = NEW.tracking_id AND merchant_order_id = NEW.merchant_order_id;
    RETURN NULL;
END;
$$;


--
-- TOC entry 298415 (class 1255 OID 530478)
-- Name: update_tracking_number_package_info_by_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_tracking_number_package_info_by_code() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    -- ignore trivial changes
    IF (NEW.code = OLD.code) THEN RETURN NEW; END IF;
    UPDATE package_info set tracking_number = NEW.code where tracking_id = NEW.id AND merchant_order_id = NEW.merchant_order_id AND merchant_order_id <> 0 AND merchant_order_id IS NOT NULL;
    RETURN NEW;
END;
$$;


--
-- TOC entry 298414 (class 1255 OID 530479)
-- Name: update_tracking_number_package_info_by_tracking_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_tracking_number_package_info_by_tracking_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- ignore trivial changes
    IF (NEW.tracking_id = OLD.tracking_id) THEN RETURN NEW; END IF;
    UPDATE package_info set tracking_number = (SELECT code from tracking_number WHERE id = NEW.tracking_id) where id = NEW.id;
    RETURN NEW;
END;
$$;


--
-- TOC entry 298426 (class 1255 OID 535346)
-- Name: update_tracking_package_info(text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_tracking_package_info(codes text[]) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
  trackingRec int8;
  pinfoRec INT8;
  trackingID BIGINT;
BEGIN
    FOR rec IN (SELECT * FROM pagent_order WHERE code = ANY(codes)) LOOP
      IF rec.state = '2Z' THEN
        RAISE INFO '%', rec.code;
          SELECT id INTO trackingRec FROM tracking_number WHERE code = rec.supplier_tracking_number;
          IF trackingRec ISNULL THEN
            INSERT INTO tracking_number(id,code,created_at,updated_at) VALUES(rec.id,rec.supplier_tracking_number,now(),now());
          END IF;
          SELECT id INTO trackingID FROM tracking_number WHERE code = rec.supplier_tracking_number LIMIT 1;
          RAISE INFO 'hello: %', trackingID;
          SELECT id INTO pinfoRec FROM package_info WHERE merchant_order_id = rec.merchant_order_id;
          IF pinfoRec ISNULL THEN
            INSERT INTO package_info(id,merchant_order_id,tracking_id,merchant_id,created_at,updated_at)
              VALUES (rec.id,rec.merchant_order_id,trackingID,rec.id,now(),now());
          END IF;
      END IF;
    END LOOP;
    RETURN 'done';
END;
$$;


--
-- TOC entry 298439 (class 1255 OID 558061)
-- Name: update_user_token_fcm(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_user_token_fcm() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN NULL;
END;
$$;


--
-- TOC entry 298403 (class 1255 OID 16591)
-- Name: update_warehouse_for_inventory_item(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_warehouse_for_inventory_item() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE r INT8;
BEGIN
  FOR r IN SELECT id FROM wh_inventory_item
  WHERE warehouse IS NULL
  LOOP
    RAISE NOTICE 'update warehouse for item %d', r;
    UPDATE wh_inventory_item SET warehouse = (select warehouse from wh_inventory_package where supplier_tracking_number = (select supplier_tracking_number from wh_inventory_item where id = r)) WHERE id = r;
  END LOOP;
  RETURN;
END
$$;


--
-- TOC entry 298404 (class 1255 OID 16592)
-- Name: validate_coupon_condition_type_value_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_coupon_condition_type_value_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE rule INTEGER;
BEGIN
    SELECT count(id)
    INTO rule
    FROM coupon_rule cr
        JOIN coupon_code cc ON cc.id = cr.coupon_code_id
    WHERE cr.coupon_condition_id = NEW.id AND cc.active = true
    LIMIT 1;

    IF (rule > 0) THEN
        RAISE EXCEPTION 'You cannot change the condition while related coupon code active.';
END
IF;
    RETURN NEW;
END
$$;


--
-- TOC entry 298434 (class 1255 OID 544470)
-- Name: vnhub_parcel_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.vnhub_parcel_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO vnhub_parcel_history (revision, parcel_code, changes, user_id, curr_state, prev_state)
        VALUES (nextval('vnhub_parcel_history_seq'), OLD.code, to_json(OLD), OLD.action_admin_id, 'DELETED', OLD.state);
        ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO vnhub_parcel_history (revision, parcel_code, changes, user_id, curr_state)
        VALUES (NEW.rid, NEW.code, to_json(NEW), NEW.action_admin_id, NEW.state);
    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb ((hstore (NEW.*) - hstore (OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);
        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN
            RETURN NULL;
        END IF;
        INSERT INTO vnhub_parcel_history (revision, parcel_code, changes, user_id, prev_state, curr_state)
        VALUES (NEW.rid, NEW.code, changes, NEW.action_admin_id, OLD.state, NEW.state);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298463 (class 1255 OID 551273)
-- Name: wallet_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.wallet_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO wallet_history(revision, wallet_id, wallet_transaction_id, curr_balance, user_id, changes)
        VALUES (NEW.rid, NEW.id, NEW.wallet_transaction_id, NEW.balance_vnd, NEW.user_id, to_json(NEW));
    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO wallet_history(revision, wallet_id, wallet_transaction_id, prev_balance, curr_balance, user_id, changes)
        VALUES (NEW.rid, NEW.id, NEW.wallet_transaction_id, OLD.balance_vnd, NEW.balance_vnd, NEW.user_id, changes);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298447 (class 1255 OID 551001)
-- Name: wallet_transaction_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.wallet_transaction_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO wallet_transaction_history(revision, wallet_transaction_id, merchant_order_id, merchant_id, curr_state, type, state_final, user_id, changes)
        VALUES (NEW.rid, NEW.id, NEW.merchant_order_id, NEW.merchant_id, NEW.state, NEW.type, NEW.state_final, NEW.user_id, to_json(NEW));
    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO wallet_transaction_history(revision, wallet_transaction_id, merchant_order_id, merchant_id, prev_state, curr_state, type, state_final, user_id, changes)
        VALUES (NEW.rid, NEW.id, NEW.merchant_order_id, NEW.merchant_id, OLD.state, NEW.state, NEW.type, NEW.state_final, NEW.user_id, changes);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298405 (class 1255 OID 16593)
-- Name: wh_inventory_item_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.wh_inventory_item_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        return NULL;

    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO wh_inventory_item_history(revision, wh_inventory_item_id, changes, user_id)
        VALUES (NEW.rid, NEW.id, to_json(NEW), NEW.action_admin_id);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO wh_inventory_item_history(revision, wh_inventory_item_id, changes, user_id)
        VALUES (NEW.rid, NEW.id, changes, NEW.action_admin_id);
    END IF;
    RETURN NULL;
END
$$;


--
-- TOC entry 298406 (class 1255 OID 16594)
-- Name: wh_inventory_package_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.wh_inventory_package_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE changes JSONB;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO wh_inventory_package_history(revision, wh_inventory_package_id, changes, user_id, curr_state, prev_state)
        VALUES (nextval('wh_inventory_package_history_seq'), OLD.id, to_json(OLD), OLD.action_admin_id, OLD.state::text, OLD.state::text);

    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO wh_inventory_package_history(revision, wh_inventory_package_id, changes, user_id, curr_state)
        VALUES (NEW.rid, NEW.id, to_json(NEW), NEW.action_admin_id, NEW.state::text);

    ELSE
        -- calculate only changed columns then encode as jsonb
        -- also ignore uninteresting fields like "updated_at", "rid"
        changes := to_jsonb((hstore(NEW.*)-hstore(OLD.*)) - '{updated_at,rid,action_admin_id}'::TEXT[]);

        -- ignore trivial changes
        IF (changes = '{}'::JSONB) THEN RETURN NULL; END IF;

        INSERT INTO wh_inventory_package_history(revision, wh_inventory_package_id, changes, user_id, curr_state, prev_state)
        VALUES (NEW.rid, NEW.id, changes, NEW.action_admin_id, NEW.state::text, OLD.state::text);
    END IF;
    RETURN NULL;
END
$$;

CREATE TRIGGER box_create_code BEFORE INSERT ON public.box FOR EACH ROW EXECUTE PROCEDURE public.box_create_code();


--
-- TOC entry 600231 (class 2620 OID 516412)
-- Name: box box_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER box_history AFTER INSERT OR DELETE OR UPDATE ON public.box FOR EACH ROW EXECUTE PROCEDURE public.box_history();


--
-- TOC entry 600305 (class 2620 OID 574308)
-- Name: cod_session cod_session_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cod_session_history AFTER INSERT OR UPDATE ON public.cod_session FOR EACH ROW EXECUTE PROCEDURE public.cod_session_history();


--
-- TOC entry 600241 (class 2620 OID 531180)
-- Name: last_mile_shipping_info compute_sorting_code_when_change_district_province_on_lastmile; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER compute_sorting_code_when_change_district_province_on_lastmile BEFORE UPDATE ON public.last_mile_shipping_info FOR EACH ROW EXECUTE PROCEDURE public.compute_sorting_code_when_change_district_province_on_lastmile();


--
-- TOC entry 600233 (class 2620 OID 516413)
-- Name: coupon_code coupon_code_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER coupon_code_changes AFTER INSERT OR UPDATE ON public.coupon_code FOR EACH ROW EXECUTE PROCEDURE public.log_coupon_code_changes();


--
-- TOC entry 600234 (class 2620 OID 516414)
-- Name: coupon_code coupon_code_check_code; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER coupon_code_check_code BEFORE INSERT OR UPDATE ON public.coupon_code FOR EACH ROW EXECUTE PROCEDURE public.check_coupon_code();


--
-- TOC entry 600236 (class 2620 OID 516415)
-- Name: coupon_condition coupon_condition_type_value_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER coupon_condition_type_value_changes BEFORE UPDATE ON public.coupon_condition FOR EACH ROW EXECUTE PROCEDURE public.validate_coupon_condition_type_value_changes();


--
-- TOC entry 600237 (class 2620 OID 516416)
-- Name: coupon_condition coupon_conidtion_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER coupon_conidtion_changes AFTER INSERT OR UPDATE ON public.coupon_condition FOR EACH ROW EXECUTE PROCEDURE public.log_coupon_conidtion_history();


--
-- TOC entry 600245 (class 2620 OID 565729)
-- Name: merchant create_bank; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER create_bank AFTER INSERT ON public.merchant FOR EACH ROW EXECUTE PROCEDURE public.create_bank_when_merchant_created();


--
-- TOC entry 600246 (class 2620 OID 587701)
-- Name: merchant create_merchant_contract_when_created; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER create_merchant_contract_when_created AFTER INSERT OR UPDATE ON public.merchant FOR EACH ROW EXECUTE PROCEDURE public.create_merchant_contract_when_created();


--
-- TOC entry 600247 (class 2620 OID 587702)
-- Name: merchant create_wallet; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER create_wallet AFTER INSERT OR UPDATE ON public.merchant FOR EACH ROW EXECUTE PROCEDURE public.create_wallet_when_merchant_created();


--
-- TOC entry 600239 (class 2620 OID 516417)
-- Name: delivery_order delivery_order_create_code; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delivery_order_create_code BEFORE INSERT ON public.delivery_order FOR EACH ROW EXECUTE PROCEDURE public.delivery_order_create_code();


--
-- TOC entry 600302 (class 2620 OID 564184)
-- Name: finance_refund finance_refund_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER finance_refund_history AFTER INSERT OR DELETE OR UPDATE ON public.finance_refund FOR EACH ROW EXECUTE PROCEDURE public.finance_refund_history();


--
-- TOC entry 600257 (class 2620 OID 516418)
-- Name: order_item fix_consignee_cbe_tiki; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER fix_consignee_cbe_tiki AFTER UPDATE ON public.order_item FOR EACH ROW EXECUTE PROCEDURE public.fix_consignee_cbe();


--
-- TOC entry 600258 (class 2620 OID 516419)
-- Name: order_item fix_order_item_cbe_product_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER fix_order_item_cbe_product_id AFTER UPDATE ON public.order_item FOR EACH ROW EXECUTE PROCEDURE public.fix_order_item_cbe_product_id();


--
-- TOC entry 600303 (class 2620 OID 572590)
-- Name: merchant_contract merchant_contract_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_contract_history AFTER INSERT OR UPDATE ON public.merchant_contract FOR EACH ROW EXECUTE PROCEDURE public.merchant_contract_history();


--
-- TOC entry 600242 (class 2620 OID 516420)
-- Name: merchant merchant_create_mseq; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_create_mseq AFTER INSERT ON public.merchant FOR EACH ROW EXECUTE PROCEDURE public.merchant_create_mseq();


--
-- TOC entry 600243 (class 2620 OID 516421)
-- Name: merchant merchant_drop_mseq; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_drop_mseq AFTER DELETE ON public.merchant FOR EACH ROW EXECUTE PROCEDURE public.merchant_drop_mseq();


--
-- TOC entry 600248 (class 2620 OID 516422)
-- Name: merchant_order merchant_order_create_code; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_order_create_code BEFORE INSERT ON public.merchant_order FOR EACH ROW EXECUTE PROCEDURE public.merchant_order_create_code();


--
-- TOC entry 600249 (class 2620 OID 516423)
-- Name: merchant_order merchant_order_create_mohseq; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_order_create_mohseq AFTER INSERT ON public.merchant_order FOR EACH ROW EXECUTE PROCEDURE public.merchant_order_create_mohseq();


--
-- TOC entry 600250 (class 2620 OID 516424)
-- Name: merchant_order merchant_order_drop_mohseq; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_order_drop_mohseq AFTER DELETE ON public.merchant_order FOR EACH ROW EXECUTE PROCEDURE public.merchant_order_drop_mohseq();


--
-- TOC entry 600251 (class 2620 OID 516425)
-- Name: merchant_order merchant_order_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_order_history AFTER INSERT OR DELETE OR UPDATE ON public.merchant_order FOR EACH ROW EXECUTE PROCEDURE public.merchant_order_history();


--
-- TOC entry 600255 (class 2620 OID 516426)
-- Name: merchant_order_history merchant_order_history_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_order_history_insert BEFORE INSERT ON public.merchant_order_history FOR EACH ROW EXECUTE PROCEDURE public.merchant_order_history_insert();


--
-- TOC entry 600252 (class 2620 OID 516427)
-- Name: merchant_order merchant_order_sync_tracking_oi; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_order_sync_tracking_oi AFTER UPDATE ON public.merchant_order FOR EACH ROW EXECUTE PROCEDURE public.sync_tracking_number_trigger();


--
-- TOC entry 600253 (class 2620 OID 516428)
-- Name: merchant_order merchant_order_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_order_update BEFORE INSERT OR UPDATE ON public.merchant_order FOR EACH ROW EXECUTE PROCEDURE public.merchant_order_update();


--
-- TOC entry 600256 (class 2620 OID 516429)
-- Name: merchant_plan merchant_plan_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_plan_update BEFORE INSERT OR UPDATE ON public.merchant_plan FOR EACH ROW EXECUTE PROCEDURE public.merchant_plan_update();


--
-- TOC entry 600244 (class 2620 OID 516430)
-- Name: merchant merchant_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER merchant_update BEFORE INSERT OR UPDATE ON public.merchant FOR EACH ROW EXECUTE PROCEDURE public.merchant_update();


--
-- TOC entry 600259 (class 2620 OID 516431)
-- Name: order_item order_item_create_oihseq; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER order_item_create_oihseq AFTER INSERT ON public.order_item FOR EACH ROW EXECUTE PROCEDURE public.order_item_create_oihseq();


--
-- TOC entry 600260 (class 2620 OID 516432)
-- Name: order_item order_item_drop_oihseq; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER order_item_drop_oihseq AFTER DELETE ON public.order_item FOR EACH ROW EXECUTE PROCEDURE public.order_item_drop_oihseq();


--
-- TOC entry 600261 (class 2620 OID 516433)
-- Name: order_item order_item_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER order_item_history AFTER INSERT OR DELETE OR UPDATE ON public.order_item FOR EACH ROW EXECUTE PROCEDURE public.order_item_history();


--
-- TOC entry 600268 (class 2620 OID 516434)
-- Name: order_item_history order_item_history_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER order_item_history_insert BEFORE INSERT ON public.order_item_history FOR EACH ROW EXECUTE PROCEDURE public.order_item_history_insert();


--
-- TOC entry 600262 (class 2620 OID 516435)
-- Name: order_item order_item_state_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER order_item_state_changes AFTER UPDATE ON public.order_item FOR EACH ROW EXECUTE PROCEDURE public.check_update_mo_state_done();


--
-- TOC entry 600263 (class 2620 OID 516436)
-- Name: order_item order_item_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER order_item_update BEFORE INSERT OR UPDATE ON public.order_item FOR EACH ROW EXECUTE PROCEDURE public.order_item_update();


--
-- TOC entry 600269 (class 2620 OID 516437)
-- Name: order_price order_price_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER order_price_history AFTER INSERT OR DELETE OR UPDATE ON public.order_price FOR EACH ROW EXECUTE PROCEDURE public.order_price_history();


--
-- TOC entry 600272 (class 2620 OID 538833)
-- Name: package_info package_info_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER package_info_history AFTER INSERT OR UPDATE ON public.package_info FOR EACH ROW EXECUTE PROCEDURE public.package_info_history();


--
-- TOC entry 600273 (class 2620 OID 516438)
-- Name: pagent_order pagent_order_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER pagent_order_history AFTER INSERT OR DELETE OR UPDATE ON public.pagent_order FOR EACH ROW EXECUTE PROCEDURE public.pagent_order_history();


--
-- TOC entry 600275 (class 2620 OID 516439)
-- Name: parcel parcel_create_code; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER parcel_create_code BEFORE INSERT ON public.parcel FOR EACH ROW EXECUTE PROCEDURE public.parcel_create_code();


--
-- TOC entry 600276 (class 2620 OID 516440)
-- Name: parcel parcel_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER parcel_history AFTER INSERT OR DELETE OR UPDATE ON public.parcel FOR EACH ROW EXECUTE PROCEDURE public.parcel_history();


--
-- TOC entry 600278 (class 2620 OID 516441)
-- Name: plan plan_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER plan_history AFTER INSERT OR DELETE OR UPDATE ON public.plan FOR EACH ROW EXECUTE PROCEDURE public.plan_history();


--
-- TOC entry 600280 (class 2620 OID 516442)
-- Name: pricing_config pricing_config_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER pricing_config_history AFTER INSERT OR DELETE OR UPDATE ON public.pricing_config FOR EACH ROW EXECUTE PROCEDURE public.pricing_config_history();


--
-- TOC entry 600283 (class 2620 OID 516443)
-- Name: surcharge surcharge_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER surcharge_history AFTER INSERT OR DELETE OR UPDATE ON public.surcharge FOR EACH ROW EXECUTE PROCEDURE public.surcharge_history();


--
-- TOC entry 600267 (class 2620 OID 574481)
-- Name: order_item sync_order_item_package_info; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sync_order_item_package_info AFTER UPDATE ON public.order_item FOR EACH ROW EXECUTE PROCEDURE public.sync_order_item_package_info();


--
-- TOC entry 600282 (class 2620 OID 516791)
-- Name: product sync_sku_from_product; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sync_sku_from_product AFTER INSERT ON public.product FOR EACH ROW EXECUTE PROCEDURE public.sync_sku_from_product_trigger();


--
-- TOC entry 600265 (class 2620 OID 531102)
-- Name: order_item sync_state_order_item_mo; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sync_state_order_item_mo AFTER UPDATE ON public.order_item FOR EACH ROW EXECUTE PROCEDURE public.sync_state_order_item_mo();


--
-- TOC entry 600293 (class 2620 OID 538700)
-- Name: tracking_number tracking_number_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tracking_number_history AFTER INSERT OR UPDATE ON public.tracking_number FOR EACH ROW EXECUTE PROCEDURE public.tracking_number_history();


--
-- TOC entry 600240 (class 2620 OID 542433)
-- Name: last_mile_booking_history update_parcel_num_contact; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_parcel_num_contact AFTER INSERT ON public.last_mile_booking_history FOR EACH ROW EXECUTE PROCEDURE public.update_parcel_num_deliver();


--
-- TOC entry 600294 (class 2620 OID 542657)
-- Name: call_history update_parcel_num_contact; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_parcel_num_contact AFTER INSERT ON public.call_history FOR EACH ROW EXECUTE PROCEDURE public.update_parcel_num_contact();


--
-- TOC entry 600254 (class 2620 OID 516444)
-- Name: merchant_order update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.merchant_order FOR EACH ROW EXECUTE PROCEDURE public.update_rid('merchant_order_history_seq');


--
-- TOC entry 600264 (class 2620 OID 516445)
-- Name: order_item update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.order_item FOR EACH ROW EXECUTE PROCEDURE public.update_rid('order_item_history_seq');


--
-- TOC entry 600279 (class 2620 OID 516446)
-- Name: plan update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.plan FOR EACH ROW EXECUTE PROCEDURE public.update_rid('plan_history_seq');


--
-- TOC entry 600232 (class 2620 OID 516447)
-- Name: box update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.box FOR EACH ROW EXECUTE PROCEDURE public.update_rid('box_history_seq');


--
-- TOC entry 600277 (class 2620 OID 516448)
-- Name: parcel update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.parcel FOR EACH ROW EXECUTE PROCEDURE public.update_rid('parcel_history_seq');


--
-- TOC entry 600289 (class 2620 OID 516449)
-- Name: wh_inventory_package update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.wh_inventory_package FOR EACH ROW EXECUTE PROCEDURE public.update_rid('wh_inventory_package_history_seq');


--
-- TOC entry 600287 (class 2620 OID 516450)
-- Name: wh_inventory_item update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.wh_inventory_item FOR EACH ROW EXECUTE PROCEDURE public.update_rid('wh_inventory_item_history_seq');


--
-- TOC entry 600281 (class 2620 OID 516451)
-- Name: pricing_config update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.pricing_config FOR EACH ROW EXECUTE PROCEDURE public.update_rid('pricing_config_history_seq');


--
-- TOC entry 600270 (class 2620 OID 516452)
-- Name: order_price update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.order_price FOR EACH ROW EXECUTE PROCEDURE public.update_rid('order_price_history_seq');


--
-- TOC entry 600284 (class 2620 OID 516453)
-- Name: surcharge update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.surcharge FOR EACH ROW EXECUTE PROCEDURE public.update_rid('surcharge_history_seq');


--
-- TOC entry 600235 (class 2620 OID 516454)
-- Name: coupon_code update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.coupon_code FOR EACH ROW EXECUTE PROCEDURE public.update_rid('coupon_code_history_seq');


--
-- TOC entry 600238 (class 2620 OID 516455)
-- Name: coupon_condition update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.coupon_condition FOR EACH ROW EXECUTE PROCEDURE public.update_rid('coupon_condition_history_seq');


--
-- TOC entry 600285 (class 2620 OID 516456)
-- Name: users_group update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.users_group FOR EACH ROW EXECUTE PROCEDURE public.update_rid('users_group_history_seq');


--
-- TOC entry 600274 (class 2620 OID 516457)
-- Name: pagent_order update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.pagent_order FOR EACH ROW EXECUTE PROCEDURE public.update_rid('pagent_order_history_seq');


--
-- TOC entry 600292 (class 2620 OID 538699)
-- Name: tracking_number update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.tracking_number FOR EACH ROW EXECUTE PROCEDURE public.update_rid('tracking_number_history_seq');


--
-- TOC entry 600271 (class 2620 OID 538832)
-- Name: package_info update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.package_info FOR EACH ROW EXECUTE PROCEDURE public.update_rid('package_info_history_seq');


--
-- TOC entry 600296 (class 2620 OID 544523)
-- Name: vnhub_parcel update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.vnhub_parcel FOR EACH ROW EXECUTE PROCEDURE public.update_rid('vnhub_parcel_history_seq');


--
-- TOC entry 600301 (class 2620 OID 564183)
-- Name: finance_refund update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.finance_refund FOR EACH ROW EXECUTE PROCEDURE public.update_rid('finance_refund_history_seq');


--
-- TOC entry 600300 (class 2620 OID 564185)
-- Name: wallet_transaction update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.wallet_transaction FOR EACH ROW EXECUTE PROCEDURE public.update_rid('wallet_transaction_history_seq');


--
-- TOC entry 600297 (class 2620 OID 564187)
-- Name: wallet update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.wallet FOR EACH ROW EXECUTE PROCEDURE public.update_rid('wallet_history_seq');


--
-- TOC entry 600304 (class 2620 OID 574307)
-- Name: cod_session update_rid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_rid BEFORE INSERT OR UPDATE ON public.cod_session FOR EACH ROW EXECUTE PROCEDURE public.update_rid('cod_session_history_seq');


--
-- TOC entry 600266 (class 2620 OID 536173)
-- Name: order_item update_state_package_info_by_order_item_state; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_state_package_info_by_order_item_state AFTER INSERT OR UPDATE ON public.order_item FOR EACH ROW EXECUTE PROCEDURE public.update_state_package_info_by_order_item_state();


--
-- TOC entry 600291 (class 2620 OID 536175)
-- Name: tracking_number update_tracking_number_package_info_by_code; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_tracking_number_package_info_by_code AFTER INSERT OR UPDATE ON public.tracking_number FOR EACH ROW EXECUTE PROCEDURE public.update_tracking_number_package_info_by_code();


--
-- TOC entry 600286 (class 2620 OID 516458)
-- Name: users_group users_group_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER users_group_changes AFTER INSERT OR UPDATE ON public.users_group FOR EACH ROW EXECUTE PROCEDURE public.log_users_group_history();


--
-- TOC entry 600295 (class 2620 OID 544471)
-- Name: vnhub_parcel vnhub_parcel_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER vnhub_parcel_history AFTER INSERT OR DELETE OR UPDATE ON public.vnhub_parcel FOR EACH ROW EXECUTE PROCEDURE public.vnhub_parcel_history();


--
-- TOC entry 600298 (class 2620 OID 564188)
-- Name: wallet wallet_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER wallet_history AFTER INSERT OR DELETE OR UPDATE ON public.wallet FOR EACH ROW EXECUTE PROCEDURE public.wallet_history();


--
-- TOC entry 600299 (class 2620 OID 566478)
-- Name: wallet_transaction wallet_transaction_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER wallet_transaction_history AFTER INSERT OR UPDATE ON public.wallet_transaction FOR EACH ROW EXECUTE PROCEDURE public.wallet_transaction_history();


--
-- TOC entry 600288 (class 2620 OID 516459)
-- Name: wh_inventory_item wh_inventory_item_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER wh_inventory_item_history AFTER INSERT OR DELETE OR UPDATE ON public.wh_inventory_item FOR EACH ROW EXECUTE PROCEDURE public.wh_inventory_item_history();


--
-- TOC entry 600290 (class 2620 OID 516460)
-- Name: wh_inventory_package wh_inventory_package_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER wh_inventory_package_history AFTER INSERT OR DELETE OR UPDATE ON public.wh_inventory_package FOR EACH ROW EXECUTE PROCEDURE public.wh_inventory_package_history();

