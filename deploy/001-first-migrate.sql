
BEGIN;
CREATE TABLE IF NOT EXISTS receipt (
	id bigint PRIMARY KEY NOT NULL,
	code text,
	type text,
	vendor_id bigint,
	sender_name text,
	sender_phone text,
	warehouse text,
	status text,
	total_amount bigint,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint
);
CREATE INDEX IF NOT EXISTS receipt_code ON "receipt" USING btree (code);
CREATE TABLE IF NOT EXISTS users_group_history (
	users_group_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS users_group_history_group_id_idx ON "users_group_history" USING btree (users_group_id);
CREATE TABLE IF NOT EXISTS delivery_order_item (
	id bigint PRIMARY KEY NOT NULL,
	delivery_order_id bigint,
	item_id bigint,
	table_name text
);
CREATE UNIQUE INDEX IF NOT EXISTS delivery_order_id_item_id ON "delivery_order_item" USING btree (delivery_order_id, item_id);
CREATE TABLE IF NOT EXISTS order_price_transportation_fee (
	order_price_id bigint NOT NULL,
	transportation_fee_id bigint NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL,
	service_type text NOT NULL,
	value bigint NOT NULL,
	chargeable_weight bigint NOT NULL,
	service_id bigint NOT NULL,
	id bigint NOT NULL
);
CREATE INDEX IF NOT EXISTS fkIdx_194 ON "order_price_transportation_fee" USING btree (order_price_id);
CREATE INDEX IF NOT EXISTS fkIdx_203 ON "order_price_transportation_fee" USING btree (transportation_fee_id);
CREATE TABLE IF NOT EXISTS pagent_receipt (
	id bigint PRIMARY KEY NOT NULL,
	pagent_id bigint,
	admin_id bigint,
	created_at timestamp,
	receipt_at timestamp,
	pagent_purchasing_amount_x integer,
	commission_percent smallint,
	commission_amount_x integer,
	commission_amount_vnd integer,
	exchange_rate integer,
	note_purchase_commission text
);
CREATE TABLE IF NOT EXISTS invoice (
	id bigint PRIMARY KEY NOT NULL,
	invoice_no text Unique,
	date date,
	payment_type text,
	payment_term text,
	hawb_id bigint
);
CREATE TABLE IF NOT EXISTS last_mile_provider (
	id bigint PRIMARY KEY NOT NULL,
	code text,
	name text,
	description text,
	active boolean,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS package_info (
	id bigint PRIMARY KEY NOT NULL,
	merchant_order_id bigint,
	length integer,
	height integer,
	width integer,
	weight integer,
	dimension_weight integer,
	created_at timestamp,
	updated_at timestamp,
	tracking_id bigint,
	state text,
	tracking_number text,
	merchant_id bigint,
	order_code text,
	state_final integer,
	rid bigint,
	action_admin_id bigint,
	actual_weight bigint
);
CREATE INDEX IF NOT EXISTS package_info_created_at_idx ON "package_info" USING btree (created_at);
CREATE INDEX IF NOT EXISTS package_info_id_idx ON "package_info" USING btree (id);
CREATE INDEX IF NOT EXISTS package_info_merchant_order_id_idx ON "package_info" USING btree (merchant_order_id);
CREATE INDEX IF NOT EXISTS package_info_rid_idx ON "package_info" USING btree (rid);
CREATE INDEX IF NOT EXISTS package_info_updated_at_idx ON "package_info" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS service_fee (
	id bigint PRIMARY KEY NOT NULL,
	name text NOT NULL,
	code text NOT NULL,
	description text NOT NULL,
	fee bigint NOT NULL,
	lower_threshold integer NOT NULL,
	upper_threshold integer NOT NULL,
	unit text NOT NULL,
	active boolean,
	created_at timestamp,
	updated_at timestamp,
	unit_fee text,
	service_id bigint,
	country text,
	action_admin_id text
);
CREATE UNIQUE INDEX IF NOT EXISTS pk_service_fee ON "service_fee" USING btree (id);
CREATE TABLE IF NOT EXISTS webhook_header_metadata (
	id bigint PRIMARY KEY NOT NULL,
	webhook_id bigint NOT NULL,
	key text NOT NULL,
	value text NOT NULL,
	action_admin_id bigint,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS cod_session (
	id bigint PRIMARY KEY NOT NULL,
	parent_id bigint,
	code text,
	type text,
	description text,
	action_admin_id bigint,
	total_amount bigint,
	actual_amount bigint,
	amount_of_discrepancy bigint,
	state text,
	has_child boolean,
	transaction_date timestamp,
	rid bigint,
	created_at timestamp,
	updated_at timestamp
);
CREATE UNIQUE INDEX IF NOT EXISTS cod_session_code_idx ON "cod_session" USING btree (code);
CREATE INDEX IF NOT EXISTS cod_session_created_at_idx ON "cod_session" USING btree (created_at);
CREATE INDEX IF NOT EXISTS cod_session_has_child_idx ON "cod_session" USING btree (has_child);
CREATE UNIQUE INDEX IF NOT EXISTS cod_session_id_pkey ON "cod_session" USING btree (id);
CREATE INDEX IF NOT EXISTS cod_session_parent_id_idx ON "cod_session" USING btree (parent_id);
CREATE INDEX IF NOT EXISTS cod_session_rid_idx ON "cod_session" USING btree (rid);
CREATE INDEX IF NOT EXISTS cod_session_state_idx ON "cod_session" USING btree (state);
CREATE INDEX IF NOT EXISTS cod_session_transaction_date_idx ON "cod_session" USING btree (transaction_date);
CREATE INDEX IF NOT EXISTS cod_session_type_idx ON "cod_session" USING btree (type);
CREATE INDEX IF NOT EXISTS cod_session_updated_at_idx ON "cod_session" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS coupon_rule (
	coupon_code_id bigint NOT NULL,
	coupon_condition_id bigint NOT NULL
);
CREATE TABLE IF NOT EXISTS inspection_fee (
	id bigint PRIMARY KEY NOT NULL,
	fee bigint NOT NULL,
	lower_threshold integer NOT NULL,
	upper_threshold integer NOT NULL,
	product_price_threshold bigint NOT NULL,
	active boolean,
	created_at timestamp,
	updated_at timestamp
);
CREATE UNIQUE INDEX IF NOT EXISTS pk_inspection_fee ON "inspection_fee" USING btree (id);
CREATE TABLE IF NOT EXISTS order_price_service (
	id bigint PRIMARY KEY NOT NULL,
	order_price_id bigint NOT NULL,
	value bigint NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	service_id bigint
);
CREATE INDEX IF NOT EXISTS order_price_service_order_price_id_idx ON "order_price_service" USING btree (order_price_id);
CREATE UNIQUE INDEX IF NOT EXISTS pk_order_price_service ON "order_price_service" USING btree (id);
CREATE TABLE IF NOT EXISTS pagent (
	id bigint PRIMARY KEY NOT NULL,
	code text Unique,
	created_at timestamp,
	updated_at timestamp,
	deleted_at timestamp,
	disabled_at timestamp,
	name text NOT NULL,
	email text NOT NULL Unique,
	phone text NOT NULL Unique,
	address text,
	avatar text,
	commission_percent double precision
);
CREATE TABLE IF NOT EXISTS pricing_config (
	id bigint PRIMARY KEY NOT NULL,
	price_per_item_x integer,
	price_per_weight_x integer,
	insurance_fee_percent integer,
	purchasing_fee_percent integer,
	exchange_rate integer,
	plan_id bigint,
	country text,
	currency text,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint,
	rid bigint,
	active boolean,
	category text,
	cost_of_sale_percent double precision,
	profit_margin_percent double precision
);
CREATE INDEX IF NOT EXISTS pricing_config_action_admin_id_idx ON "pricing_config" USING btree (action_admin_id);
CREATE INDEX IF NOT EXISTS pricing_config_active_idx ON "pricing_config" USING btree (active);
CREATE INDEX IF NOT EXISTS pricing_config_category_idx ON "pricing_config" USING btree (category);
CREATE INDEX IF NOT EXISTS pricing_config_country_idx ON "pricing_config" USING btree (country);
CREATE INDEX IF NOT EXISTS pricing_config_created_at_idx ON "pricing_config" USING btree (created_at);
CREATE INDEX IF NOT EXISTS pricing_config_id_idx ON "pricing_config" USING btree (id);
CREATE INDEX IF NOT EXISTS pricing_config_plan_id_idx ON "pricing_config" USING btree (plan_id);
CREATE INDEX IF NOT EXISTS pricing_config_updated_at_idx ON "pricing_config" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS pricing_config_history (
	pricing_config_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS pricing_config_history_revision_idx ON "pricing_config_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS tracking_merchant_order_rel (
	merchant_order_id bigint NOT NULL,
	tracking_id bigint NOT NULL,
	no_packages integer
);
CREATE TABLE IF NOT EXISTS cart (
	id bigint PRIMARY KEY NOT NULL,
	merchant_id bigint,
	name_cart text,
	link_cart text,
	image_cart text,
	site text,
	price_cart text,
	currency text,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS coupon_code_history (
	coupon_code_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS coupon_code_history_coupon_id_idx ON "coupon_code_history" USING btree (coupon_code_id);
CREATE TABLE IF NOT EXISTS merchant_plan (
	id bigint PRIMARY KEY NOT NULL,
	merchant_id bigint,
	merchant text,
	admin_id bigint,
	plan_id bigint,
	plan_name text,
	mark_paid_by_admin_id bigint,
	cancelled_by_admin_id bigint,
	created_at timestamp,
	updated_at timestamp,
	started_at timestamp,
	expired_at timestamp,
	paid_at timestamp,
	disabled_at timestamp,
	cancelled_at timestamp,
	closed_at timestamp,
	max_weight integer,
	used_weight integer,
	est_used_weight integer,
	note text,
	is_upgraded boolean,
	upgrade_from_plan_id bigint,
	upgrade_from_plan_name text,
	is_renewal boolean,
	is_fallback boolean,
	fallback_from_plan_id bigint,
	fallback_from_plan_name text,
	status boolean,
	state smallint
);
CREATE INDEX IF NOT EXISTS merchant_plan_created_at_idx ON "merchant_plan" USING btree (created_at);
CREATE INDEX IF NOT EXISTS merchant_plan_expired_at_idx ON "merchant_plan" USING btree (expired_at);
CREATE INDEX IF NOT EXISTS merchant_plan_fallback_from_plan_id_idx ON "merchant_plan" USING btree (fallback_from_plan_id);
CREATE INDEX IF NOT EXISTS merchant_plan_fallback_from_plan_name_idx ON "merchant_plan" USING btree (fallback_from_plan_name);
CREATE INDEX IF NOT EXISTS merchant_plan_is_fallback_idx ON "merchant_plan" USING btree (is_fallback);
CREATE INDEX IF NOT EXISTS merchant_plan_is_renewal_idx ON "merchant_plan" USING btree (is_renewal);
CREATE INDEX IF NOT EXISTS merchant_plan_merchant_id_idx ON "merchant_plan" USING btree (merchant_id);
CREATE INDEX IF NOT EXISTS merchant_plan_merchant_idx ON "merchant_plan" USING btree (merchant);
CREATE INDEX IF NOT EXISTS merchant_plan_plan_id_idx ON "merchant_plan" USING btree (plan_id);
CREATE INDEX IF NOT EXISTS merchant_plan_plan_name_idx ON "merchant_plan" USING btree (plan_name);
CREATE INDEX IF NOT EXISTS merchant_plan_started_at_idx ON "merchant_plan" USING btree (started_at);
CREATE INDEX IF NOT EXISTS merchant_plan_status_idx ON "merchant_plan" USING btree (status);
CREATE INDEX IF NOT EXISTS merchant_plan_updated_at_idx ON "merchant_plan" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS fcm_topic (
	id bigint PRIMARY KEY NOT NULL,
	name text,
	title text,
	created_at timestamp,
	updated_at timestamp,
	disabled_at timestamp
);
CREATE INDEX IF NOT EXISTS fcm_topic_created_at_idx ON "fcm_topic" USING btree (created_at);
CREATE INDEX IF NOT EXISTS fcm_topic_disabled_at_idx ON "fcm_topic" USING btree (disabled_at);
CREATE INDEX IF NOT EXISTS fcm_topic_name_idx ON "fcm_topic" USING btree (name);
CREATE INDEX IF NOT EXISTS fcm_topic_updated_at_idx ON "fcm_topic" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS gic_staff (
	id bigint PRIMARY KEY NOT NULL,
	code text Unique,
	created_at timestamp,
	updated_at timestamp,
	deleted_at timestamp,
	disabled_at timestamp,
	roles text[],
	name text NOT NULL,
	email text NOT NULL Unique,
	phone text NOT NULL Unique,
	avatar text
);
CREATE TABLE IF NOT EXISTS pricing_config_service (
	id bigint PRIMARY KEY NOT NULL,
	pricing_config_id bigint,
	service_fee_id bigint,
	active boolean,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS quotation_charge (
	id bigint PRIMARY KEY NOT NULL,
	range integer,
	price integer,
	quotation_id bigint
);
CREATE TABLE IF NOT EXISTS ward (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL,
	district integer NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	district_code integer
);
CREATE INDEX IF NOT EXISTS ward_code_idx ON "ward" USING btree (code);
CREATE INDEX IF NOT EXISTS ward_district_code_idx ON "ward" USING btree (district);
CREATE TABLE IF NOT EXISTS airport (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL Unique,
	description text,
	city_name text,
	country_name text,
	iaco text,
	faa text,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS attribute (
	id bigint PRIMARY KEY NOT NULL,
	name text,
	description text,
	merchant_id bigint,
	created_at timestamp,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS attribute_created_at_idx ON "attribute" USING btree (created_at);
CREATE INDEX IF NOT EXISTS attribute_id_idx ON "attribute" USING btree (id);
CREATE INDEX IF NOT EXISTS attribute_merchant_id_idx ON "attribute" USING btree (merchant_id);
CREATE INDEX IF NOT EXISTS attribute_name_idx ON "attribute" USING btree (name);
CREATE INDEX IF NOT EXISTS attribute_updated_at_idx ON "attribute" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS delivery_order (
	id bigint PRIMARY KEY NOT NULL,
	code text,
	warehouse text,
	forwarding_agent text,
	truck_number text,
	driver_name text,
	action_admin_id bigint,
	pickup_at timestamp,
	est_pickup_at timestamp,
	created_at timestamp NOT NULL,
	updated_at timestamp,
	state text,
	picking_type text,
	est_weight integer,
	weight integer,
	admin_id bigint,
	dest_warehouse text,
	type smallint,
	active boolean,
	customs_broker_agent text
);
CREATE INDEX IF NOT EXISTS delivery_order_admin_id_idx ON "delivery_order" USING btree (action_admin_id);
CREATE INDEX IF NOT EXISTS delivery_order_code_idx ON "delivery_order" USING btree (code);
CREATE INDEX IF NOT EXISTS delivery_order_created_at_idx ON "delivery_order" USING btree (created_at);
CREATE INDEX IF NOT EXISTS delivery_order_customs_broker_agent_idx ON "delivery_order" USING btree (customs_broker_agent);
CREATE INDEX IF NOT EXISTS delivery_order_forwarding_agent_idx ON "delivery_order" USING btree (forwarding_agent);
CREATE INDEX IF NOT EXISTS delivery_order_id_idx ON "delivery_order" USING btree (id);
CREATE INDEX IF NOT EXISTS delivery_order_pickup_at_idx ON "delivery_order" USING btree (pickup_at);
CREATE INDEX IF NOT EXISTS delivery_order_state_idx ON "delivery_order" USING btree (state);
CREATE INDEX IF NOT EXISTS delivery_order_updated_at_idx ON "delivery_order" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS delivery_order_warehouse_idx ON "delivery_order" USING btree (warehouse);
CREATE TABLE IF NOT EXISTS plan_history (
	plan_id bigint NOT NULL,
	revision bigint NOT NULL,
	updated_at timestamp NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS plan_history_revision_idx ON "plan_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS transit_booking_history (
	id bigint PRIMARY KEY NOT NULL,
	transit_booking_id bigint,
	changes jsonb,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS last_mile_shipping_info (
	id bigint PRIMARY KEY NOT NULL,
	merchant_id bigint,
	name text NOT NULL,
	phone text NOT NULL,
	email text,
	address text NOT NULL,
	district text NOT NULL,
	ward text NOT NULL,
	province text NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	longitude double precision,
	latitude double precision
);
CREATE INDEX IF NOT EXISTS last_mile_shipping_info_created_at_idx ON "last_mile_shipping_info" USING btree (created_at);
CREATE INDEX IF NOT EXISTS last_mile_shipping_info_id_idx ON "last_mile_shipping_info" USING btree (id);
CREATE INDEX IF NOT EXISTS last_mile_shipping_info_merchant_id_idx ON "last_mile_shipping_info" USING btree (merchant_id);
CREATE INDEX IF NOT EXISTS last_mile_shipping_info_updated_at_idx ON "last_mile_shipping_info" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS warehouse (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL Unique,
	description text,
	address text,
	ward text,
	district text,
	province text,
	country text,
	phone text,
	consignee text,
	created_at timestamp,
	updated_at timestamp,
	active boolean,
	sorting_code text
);
CREATE INDEX IF NOT EXISTS warehouse_active_idx ON "warehouse" USING btree (active);
CREATE TABLE IF NOT EXISTS coupon_condition_history (
	coupon_condition_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS coupon_condition_history_coupon_id_idx ON "coupon_condition_history" USING btree (coupon_condition_id);
CREATE TABLE IF NOT EXISTS stock_item (
	id bigint PRIMARY KEY NOT NULL,
	stock_request_number text,
	stock_request_id bigint,
	merchant_id bigint,
	merchant_code text,
	type text,
	code text,
	title text,
	unit_of_measurement text,
	quantity integer,
	warehouse text,
	state text,
	state_final smallint,
	action_admin_id bigint,
	created_at timestamp,
	updated_at timestamp,
	cancelled_at timestamp
);
CREATE INDEX IF NOT EXISTS stock_item_code_idx ON "stock_item" USING btree (code);
CREATE INDEX IF NOT EXISTS stock_item_created_at_idx ON "stock_item" USING btree (created_at);
CREATE INDEX IF NOT EXISTS stock_item_id_idx ON "stock_item" USING btree (id);
CREATE INDEX IF NOT EXISTS stock_item_state_final_idx ON "stock_item" USING btree (state_final);
CREATE INDEX IF NOT EXISTS stock_item_state_idx ON "stock_item" USING btree (state);
CREATE INDEX IF NOT EXISTS stock_item_stock_request_number_idx ON "stock_item" USING btree (stock_request_number);
CREATE INDEX IF NOT EXISTS stock_item_updated_at_idx ON "stock_item" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS stock_item_warehouse_idx ON "stock_item" USING btree (warehouse);
CREATE TABLE IF NOT EXISTS surcharge (
	id bigint,
	category text,
	min_item_price integer,
	min_surcharge integer,
	surcharge_percent integer,
	is_vip boolean,
	surcharge_type smallint,
	value integer,
	box_weight integer,
	action_admin_id bigint,
	rid bigint,
	created_at timestamp,
	updated_at timestamp
);
CREATE UNIQUE INDEX IF NOT EXISTS surcharge_category_idx ON "surcharge" USING btree (category);
CREATE INDEX IF NOT EXISTS surcharge_id_idx ON "surcharge" USING btree (id);
CREATE INDEX IF NOT EXISTS surcharge_is_vip_idx ON "surcharge" USING btree (is_vip);
CREATE INDEX IF NOT EXISTS surcharge_rid_idx ON "surcharge" USING btree (rid);
CREATE INDEX IF NOT EXISTS surcharge_surcharge_type_idx ON "surcharge" USING btree (surcharge_type);
CREATE TABLE IF NOT EXISTS tracking_number (
	id bigint PRIMARY KEY NOT NULL,
	code text,
	action_admin_id bigint,
	created_at timestamp,
	updated_at timestamp,
	deleted_at timestamp,
	merchant_order_id bigint,
	no_packages integer,
	rid bigint
);
CREATE UNIQUE INDEX IF NOT EXISTS tracking_number_code_merchant_order_id ON "tracking_number" USING btree (code, merchant_order_id);
CREATE UNIQUE INDEX IF NOT EXISTS tracking_number_code_merchant_order_id_idx ON "tracking_number" USING btree (code, merchant_order_id);
CREATE INDEX IF NOT EXISTS tracking_number_rid_idx ON "tracking_number" USING btree (rid);
CREATE TABLE IF NOT EXISTS notes (
	id bigint PRIMARY KEY NOT NULL,
	type text,
	code text,
	note text,
	created_at timestamp
);
CREATE INDEX IF NOT EXISTS note_code ON "notes" USING btree (code);
CREATE UNIQUE INDEX IF NOT EXISTS note_code_type ON "notes" USING btree (type, code);
CREATE TABLE IF NOT EXISTS payment_history (
	id bigint PRIMARY KEY NOT NULL,
	merchant_order_id bigint NOT NULL,
	wallet_transaction_id bigint NOT NULL,
	value_vnd double precision NOT NULL,
	type text NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS receipt_detail (
	id bigint PRIMARY KEY NOT NULL,
	receipt_id bigint,
	parcel_id bigint,
	booking_id bigint,
	amount bigint,
	created_at timestamp,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS booking_id_idx ON "receipt_detail" USING btree (booking_id);
CREATE INDEX IF NOT EXISTS parcel_id_idx ON "receipt_detail" USING btree (parcel_id);
CREATE INDEX IF NOT EXISTS receipt_detail_receipt_idx ON "receipt_detail" USING btree (receipt_id);
CREATE TABLE IF NOT EXISTS invoice_goods_type (
	invoice_id bigint NOT NULL,
	goods_type_id bigint NOT NULL
);
CREATE TABLE IF NOT EXISTS merchant_contract_history (
	id bigint PRIMARY KEY NOT NULL,
	merchant_contract_id bigint NOT NULL,
	verify_state text,
	term_state text,
	changes text NOT NULL,
	user_id bigint NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS order_item (
	id bigint PRIMARY KEY NOT NULL,
	gcode text Unique,
	gscode text,
	flow text,
	state text NOT NULL,
	state_final smallint NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	cancelled_at timestamp,
	merchant_order_id bigint NOT NULL,
	warehouse text,
	note_admin text,
	note_cancel text,
	real_weight integer,
	supplier_courier text,
	supplier_price_x integer,
	supplier_tracking_number text,
	forwarding_agent text,
	is_test smallint,
	product_name text,
	action_admin_id bigint,
	rid bigint,
	customs_broker_agent text,
	last_mile_provider text,
	last_mile_code text,
	sku text,
	last_mile_status text,
	wh_inventory_item_id bigint,
	parcel_id bigint,
	weight integer,
	vnhub_parcel_id bigint,
	product_id bigint,
	sorting_code text,
	tracking_number_id bigint,
	package_info_id bigint
);
CREATE INDEX IF NOT EXISTS order_item_cancelled_at_idx ON "order_item" USING btree (cancelled_at);
CREATE INDEX IF NOT EXISTS order_item_created_at_idx ON "order_item" USING btree (created_at);
CREATE INDEX IF NOT EXISTS order_item_f4parcel_id_idx ON "order_item" USING btree (vnhub_parcel_id);
CREATE INDEX IF NOT EXISTS order_item_gscode_idx ON "order_item" USING btree (gscode);
CREATE INDEX IF NOT EXISTS order_item_parcel_id_idx ON "order_item" USING btree (parcel_id);
CREATE INDEX IF NOT EXISTS order_item_rid_idx ON "order_item" USING btree (rid);
CREATE INDEX IF NOT EXISTS order_item_sku_idx ON "order_item" USING btree (sku);
CREATE INDEX IF NOT EXISTS order_item_state_final_idx ON "order_item" USING btree (state_final);
CREATE INDEX IF NOT EXISTS order_item_state_idx ON "order_item" USING btree (state);
CREATE INDEX IF NOT EXISTS order_item_supplier_tracking_number_idx ON "order_item" USING btree (supplier_tracking_number);
CREATE INDEX IF NOT EXISTS order_item_updated_at_idx ON "order_item" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS order_item_warehouse_idx ON "order_item" USING btree (warehouse);
CREATE INDEX IF NOT EXISTS order_merchant_order_id_idx ON "order_item" USING btree (merchant_order_id);
CREATE TABLE IF NOT EXISTS package_info_history (
	package_info_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	prev_tracking text,
	curr_tracking text NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS package_info_history_revision_idx ON "package_info_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS role (
	id bigint PRIMARY KEY NOT NULL,
	name text NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	deleted_at timestamp
);
CREATE TABLE IF NOT EXISTS finance_refund (
	id bigint PRIMARY KEY NOT NULL,
	wallet_transaction_id bigint NOT NULL,
	value_vnd double precision NOT NULL,
	state text NOT NULL,
	type text NOT NULL,
	state_final integer NOT NULL,
	merchant_id bigint NOT NULL,
	wallet_id bigint,
	bank_id bigint,
	note_admin text,
	user_id bigint NOT NULL,
	rid bigint,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS hawb (
	id bigint PRIMARY KEY NOT NULL,
	booking_id bigint,
	parcel_id bigint,
	mawb_id bigint,
	lot text,
	account_no text,
	sign_shipper text,
	payment_type_id bigint,
	excute_on date,
	excute_at text,
	excute_by text,
	currency text,
	chgs text,
	wtva_1 text,
	wtva_2 text,
	other_1 text,
	other_2 text,
	decl_val_for_carrier text,
	decl_val_for_customs text
);
CREATE TABLE IF NOT EXISTS holiday_cn_table (
	holiday date,
	country text
);
CREATE TABLE IF NOT EXISTS wallet (
	id bigint PRIMARY KEY NOT NULL,
	balance_vnd double precision NOT NULL,
	merchant_id bigint NOT NULL,
	merchant_code text NOT NULL,
	merchant_name text NOT NULL,
	user_id bigint,
	status integer,
	rid bigint,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL,
	wallet_transaction_id bigint
);
CREATE INDEX IF NOT EXISTS wallet_created_at_idx ON "wallet" USING btree (created_at);
CREATE INDEX IF NOT EXISTS wallet_merchant_id_idx ON "wallet" USING btree (merchant_id);
CREATE INDEX IF NOT EXISTS wallet_status_idx ON "wallet" USING btree (status);
CREATE INDEX IF NOT EXISTS wallet_updated_at_idx ON "wallet" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS user_fcm_token (
	user_id bigint,
	token text,
	access_token text,
	platform text,
	application text,
	created_at timestamp,
	updated_at timestamp,
	disabled_at timestamp
);
CREATE INDEX IF NOT EXISTS user_fcm_access_token_token_idx ON "user_fcm_token" USING btree (access_token);
CREATE INDEX IF NOT EXISTS user_fcm_token_application_idx ON "user_fcm_token" USING btree (application);
CREATE INDEX IF NOT EXISTS user_fcm_token_created_at_idx ON "user_fcm_token" USING btree (created_at);
CREATE INDEX IF NOT EXISTS user_fcm_token_platform_idx ON "user_fcm_token" USING btree (platform);
CREATE UNIQUE INDEX IF NOT EXISTS user_fcm_token_token_idx ON "user_fcm_token" USING btree (token);
CREATE INDEX IF NOT EXISTS user_fcm_token_updated_at_idx ON "user_fcm_token" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS user_fcm_token_user_id_idx ON "user_fcm_token" USING btree (user_id);
CREATE TABLE IF NOT EXISTS wallet_transaction_history (
	id bigint PRIMARY KEY NOT NULL,
	wallet_transaction_id bigint NOT NULL,
	revision bigint NOT NULL,
	prev_state text,
	curr_state text,
	merchant_order_id bigint,
	user_id bigint NOT NULL,
	changes text NOT NULL,
	mark_as_read integer,
	read_at timestamp,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL,
	merchant_id bigint,
	state_final integer,
	type text
);
CREATE TABLE IF NOT EXISTS booking (
	id bigint PRIMARY KEY NOT NULL,
	br_code text,
	bc_code text,
	quotation_id bigint,
	etd timestamp,
	eta timestamp,
	doc_cut_off timestamp,
	goods_cut_off timestamp,
	state text
);
CREATE TABLE IF NOT EXISTS coupon_condition (
	id bigint PRIMARY KEY NOT NULL,
	description text,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint NOT NULL,
	rid bigint,
	condition_type smallint NOT NULL,
	condition_value text
);
CREATE TABLE IF NOT EXISTS shipping_instruction (
	id bigint PRIMARY KEY NOT NULL,
	mawb_id bigint,
	booking_id bigint,
	shipper_name text,
	f_agent text,
	f_consignee text
);
CREATE TABLE IF NOT EXISTS quotation (
	id bigint PRIMARY KEY NOT NULL,
	etd text,
	leadtime integer,
	doc_cut_off integer,
	goods_cut_off integer,
	f_agent text,
	carrier text,
	currency text,
	valid_date date,
	expired_date date,
	state text
);
CREATE TABLE IF NOT EXISTS wh_inventory_item (
	id bigint PRIMARY KEY NOT NULL,
	supplier_tracking_number text,
	sku text,
	product_name text,
	color text,
	size text,
	asin text,
	model text,
	brand text,
	description text,
	weight integer,
	created_at timestamp,
	updated_at timestamp,
	state smallint,
	action_admin_id bigint,
	rid bigint,
	active boolean,
	status_amount jsonb,
	total_weight integer,
	total_item integer,
	images text[],
	warehouse text,
	location bigint,
	merchant_code text,
	scanned_times integer,
	length integer,
	width integer,
	height integer
);
CREATE INDEX IF NOT EXISTS wh_inventory_item_active_idx ON "wh_inventory_item" USING btree (active);
CREATE INDEX IF NOT EXISTS wh_inventory_item_asin_idx ON "wh_inventory_item" USING btree (asin);
CREATE INDEX IF NOT EXISTS wh_inventory_item_brand_idx ON "wh_inventory_item" USING btree (brand);
CREATE INDEX IF NOT EXISTS wh_inventory_item_created_at_idx ON "wh_inventory_item" USING btree (created_at);
CREATE INDEX IF NOT EXISTS wh_inventory_item_merchant_code_idx ON "wh_inventory_item" USING btree (merchant_code);
CREATE INDEX IF NOT EXISTS wh_inventory_item_model_idx ON "wh_inventory_item" USING btree (model);
CREATE INDEX IF NOT EXISTS wh_inventory_item_product_name_idx ON "wh_inventory_item" USING btree (product_name);
CREATE INDEX IF NOT EXISTS wh_inventory_item_rid_idx ON "wh_inventory_item" USING btree (rid);
CREATE INDEX IF NOT EXISTS wh_inventory_item_sku_idx ON "wh_inventory_item" USING btree (sku);
CREATE INDEX IF NOT EXISTS wh_inventory_item_supplier_tracking_number_idx ON "wh_inventory_item" USING btree (supplier_tracking_number);
CREATE INDEX IF NOT EXISTS wh_inventory_item_updated_at_idx ON "wh_inventory_item" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS wh_inventory_item_warehouse_idx ON "wh_inventory_item" USING btree (warehouse);
CREATE TABLE IF NOT EXISTS courier (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL Unique,
	description text,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS last_mile_booking_history (
	id bigint PRIMARY KEY NOT NULL,
	last_mile_booking_id bigint,
	status text,
	created_at timestamp,
	rid bigint,
	code text
);
CREATE TABLE IF NOT EXISTS order_price (
	order_id bigint NOT NULL,
	pricing_version bigint,
	est_basket_value_x integer,
	basket_value_x integer,
	us_tax_x integer,
	us_shipping_fee_x integer,
	purchasing_fee_x integer,
	surcharge_x integer,
	insurance_fee_x integer,
	last_mile_fee_vnd integer,
	gido_fee_x integer,
	total_fee_x integer,
	total_amount_x integer,
	discount_vnd integer,
	total_amount_before_discount_vnd integer,
	total_amount_after_discount_vnd integer,
	exchange_rate integer,
	chargeable_weight integer,
	extra_amount_vnd integer,
	extra_chargeable_weight integer,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint,
	rid bigint,
	total_gifts_fee_x integer,
	transport_fee bigint,
	customs_fee bigint,
	pricing_config_id bigint,
	transportation_fee_value bigint,
	id bigint PRIMARY KEY NOT NULL,
	type text,
	profit_margin bigint,
	cost_of_sale bigint,
	chargeable_distance integer
);
CREATE INDEX IF NOT EXISTS order_price_created_at_idx ON "order_price" USING btree (created_at);
CREATE UNIQUE INDEX IF NOT EXISTS order_price_id_idx ON "order_price" USING btree (id);
CREATE INDEX IF NOT EXISTS order_price_order_id_idx ON "order_price" USING btree (order_id);
CREATE INDEX IF NOT EXISTS order_price_updated_at_idx ON "order_price" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS wallet_transaction (
	id bigint PRIMARY KEY NOT NULL,
	value_vnd double precision NOT NULL,
	actual_value_vnd double precision,
	type text NOT NULL,
	state text NOT NULL,
	state_final integer NOT NULL,
	merchant_order_code text,
	merchant_code text,
	merchant_name text,
	merchant_id bigint NOT NULL,
	merchant_order_id bigint,
	note_admin text,
	note_user text,
	user_id bigint NOT NULL,
	rid bigint,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);
CREATE INDEX IF NOT EXISTS wallet_transaction_created_at_idx ON "wallet_transaction" USING btree (created_at);
CREATE INDEX IF NOT EXISTS wallet_transaction_merchant_id_idx ON "wallet_transaction" USING btree (merchant_id);
CREATE INDEX IF NOT EXISTS wallet_transaction_state_final_idx ON "wallet_transaction" USING btree (state_final);
CREATE INDEX IF NOT EXISTS wallet_transaction_state_idx ON "wallet_transaction" USING btree (state);
CREATE INDEX IF NOT EXISTS wallet_transaction_type_idx ON "wallet_transaction" USING btree (type);
CREATE TABLE IF NOT EXISTS stock_box (
	id bigint PRIMARY KEY NOT NULL,
	stock_request_number text,
	stock_request_id bigint,
	warehouse text,
	code text,
	length integer,
	width integer,
	height integer,
	state text,
	state_final smallint,
	action_admin_id bigint,
	created_at timestamp,
	updated_at timestamp,
	cancelled_at timestamp,
	weight bigint
);
CREATE INDEX IF NOT EXISTS stock_box_code_idx ON "stock_box" USING btree (code);
CREATE INDEX IF NOT EXISTS stock_box_created_at_idx ON "stock_box" USING btree (created_at);
CREATE INDEX IF NOT EXISTS stock_box_id_idx ON "stock_box" USING btree (id);
CREATE INDEX IF NOT EXISTS stock_box_state_final_idx ON "stock_box" USING btree (state_final);
CREATE INDEX IF NOT EXISTS stock_box_state_idx ON "stock_box" USING btree (state);
CREATE INDEX IF NOT EXISTS stock_box_stock_request_number_idx ON "stock_box" USING btree (stock_request_number);
CREATE INDEX IF NOT EXISTS stock_box_updated_at_idx ON "stock_box" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS stock_box_warehouse_idx ON "stock_box" USING btree (warehouse);
CREATE TABLE IF NOT EXISTS stock_request (
	id bigint PRIMARY KEY NOT NULL,
	stock_request_number text,
	merchant_id bigint,
	type text,
	estimated_delivery_date timestamp,
	actual_delivery_date timestamp,
	stock_location text,
	warehouse text,
	total_number_of_boxes integer,
	total_volume bigint,
	total_weight bigint,
	country text,
	pickup_request boolean,
	contact_name text,
	contact_address text,
	contact_phone text,
	state text,
	state_final smallint,
	action_admin_id bigint,
	created_at timestamp,
	updated_at timestamp,
	cancelled_at timestamp,
	tracking_number text
);
CREATE INDEX IF NOT EXISTS stock_request_created_at_idx ON "stock_request" USING btree (created_at);
CREATE INDEX IF NOT EXISTS stock_request_id_idx ON "stock_request" USING btree (id);
CREATE INDEX IF NOT EXISTS stock_request_merchant_id_idx ON "stock_request" USING btree (merchant_id);
CREATE INDEX IF NOT EXISTS stock_request_number_idx ON "stock_request" USING btree (stock_request_number);
CREATE INDEX IF NOT EXISTS stock_request_pickup_request_idx ON "stock_request" USING btree (pickup_request);
CREATE INDEX IF NOT EXISTS stock_request_state_final_idx ON "stock_request" USING btree (state_final);
CREATE INDEX IF NOT EXISTS stock_request_state_idx ON "stock_request" USING btree (state);
CREATE INDEX IF NOT EXISTS stock_request_updated_at_idx ON "stock_request" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS stock_request_warehouse_idx ON "stock_request" USING btree (warehouse);
CREATE TABLE IF NOT EXISTS user_users_group_rel (
	users_group_id bigint NOT NULL,
	user_id bigint NOT NULL
);
CREATE TABLE IF NOT EXISTS payment_type (
	id bigint PRIMARY KEY NOT NULL,
	code text Unique,
	description text
);
CREATE TABLE IF NOT EXISTS plan (
	id bigint PRIMARY KEY NOT NULL,
	name text,
	description text,
	max_weight integer,
	period smallint,
	shipping_price_per_weight_x integer,
	purchasing_price_percent integer,
	created_at timestamp,
	updated_at timestamp,
	disabled_at timestamp,
	status boolean,
	rid bigint,
	action_admin_id bigint
);
CREATE INDEX IF NOT EXISTS plan_created_at_idx ON "plan" USING btree (created_at);
CREATE UNIQUE INDEX IF NOT EXISTS plan_name_idx ON "plan" USING btree (name);
CREATE INDEX IF NOT EXISTS plan_rid_idx ON "plan" USING btree (rid);
CREATE INDEX IF NOT EXISTS plan_status_idx ON "plan" USING btree (status);
CREATE INDEX IF NOT EXISTS plan_updated_at_idx ON "plan" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS supplier (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL Unique,
	description text
);
CREATE TABLE IF NOT EXISTS transit_quotation (
	id bigint PRIMARY KEY NOT NULL,
	quotation_id bigint,
	port_of_loading text,
	port_of_discharge text,
	sequence integer
);
CREATE TABLE IF NOT EXISTS bank (
	id bigint PRIMARY KEY NOT NULL,
	merchant_id bigint NOT NULL,
	merchant_code text NOT NULL,
	owner_name text,
	owner_account text,
	bank_name text,
	bank_province text,
	bank_branch text,
	user_id bigint,
	rid bigint,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS box_history (
	box_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	prev_state text,
	curr_state text NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS box_history_revision_idx ON "box_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS pagent_order_history (
	revision bigint,
	pagent_order_id bigint,
	prev_state text,
	curr_state text,
	state_final text,
	changes jsonb,
	user_id bigint,
	updated_at timestamp NOT NULL
);
CREATE INDEX IF NOT EXISTS pagent_order_history_curr_state_idx ON "pagent_order_history" USING btree (curr_state);
CREATE INDEX IF NOT EXISTS pagent_order_history_pagent_order_id_idx ON "pagent_order_history" USING btree (pagent_order_id);
CREATE INDEX IF NOT EXISTS pagent_order_history_prev_state_idx ON "pagent_order_history" USING btree (prev_state);
CREATE INDEX IF NOT EXISTS pagent_order_history_revision_idx ON "pagent_order_history" USING btree (revision);
CREATE INDEX IF NOT EXISTS pagent_order_history_state_final_idx ON "pagent_order_history" USING btree (state_final);
CREATE INDEX IF NOT EXISTS pagent_order_history_updated_at_idx ON "pagent_order_history" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS pagent_order_history_user_id_idx ON "pagent_order_history" USING btree (user_id);
CREATE TABLE IF NOT EXISTS order_price_new (
	order_id bigint,
	pricing_version bigint,
	est_basket_value_x integer,
	basket_value_x integer,
	us_tax_x integer,
	us_shipping_fee_x integer,
	purchasing_fee_x integer,
	surcharge_x integer,
	insurance_fee_x integer,
	last_mile_fee_vnd integer,
	gido_fee_x integer,
	total_fee_x integer,
	total_amount_x integer,
	discount_vnd integer,
	total_amount_before_discount_vnd integer,
	total_amount_after_discount_vnd integer,
	exchange_rate integer,
	chargeable_weight integer,
	extra_amount_vnd integer,
	extra_chargeable_weight integer,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint,
	rid bigint,
	total_gifts_fee_x integer,
	transport_fee bigint,
	customs_fee bigint,
	pricing_config_id bigint,
	transportation_fee_value bigint,
	id bigint NOT NULL
);
CREATE TABLE IF NOT EXISTS parcel_history (
	parcel_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	prev_state text,
	curr_state text NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS parcel_history_revision_idx ON "parcel_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS transit_booking (
	id bigint PRIMARY KEY NOT NULL,
	booking_id bigint,
	transit_no text,
	carrier text,
	port_of_loading text,
	port_of_discharge text,
	etd timestamp,
	eta timestamp,
	ata timestamp,
	atd timestamp,
	sequence integer
);
CREATE TABLE IF NOT EXISTS consignee_tel (
	id integer PRIMARY KEY NOT NULL,
	tel text,
	created_at timestamp NOT NULL,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS consignee_tel_idx ON "consignee_tel" USING btree (tel);
CREATE TABLE IF NOT EXISTS country (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL,
	created_at timestamp,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS country_code_idx ON "country" USING btree (code);
CREATE TABLE IF NOT EXISTS forwarding_agent (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL Unique,
	description text,
	short_name text,
	address text,
	phone text,
	fax text,
	pic text,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS product (
	id bigint PRIMARY KEY NOT NULL,
	merchant_order_id bigint,
	sku text,
	name text,
	category text,
	link text NOT NULL,
	price_x integer,
	currency text,
	gift boolean,
	number_of_set integer,
	item_in_set integer,
	package_info_id bigint,
	unit_weight integer,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint,
	description text,
	name_en text,
	name_kr text,
	name_cn text,
	brand text,
	image text
);
CREATE INDEX IF NOT EXISTS product_category_idx ON "product" USING btree (category);
CREATE INDEX IF NOT EXISTS product_created_at_idx ON "product" USING btree (created_at);
CREATE INDEX IF NOT EXISTS product_gift_idx ON "product" USING btree (gift);
CREATE INDEX IF NOT EXISTS product_id_idx ON "product" USING btree (id);
CREATE INDEX IF NOT EXISTS product_merchant_order_id_idx ON "product" USING btree (merchant_order_id);
CREATE INDEX IF NOT EXISTS product_package_info_id_idx ON "product" USING btree (package_info_id);
CREATE INDEX IF NOT EXISTS product_sku_idx ON "product" USING btree (sku);
CREATE INDEX IF NOT EXISTS product_updated_at_idx ON "product" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS wallet_history (
	id bigint PRIMARY KEY NOT NULL,
	wallet_id bigint NOT NULL,
	prev_balance double precision,
	curr_balance double precision,
	user_id bigint NOT NULL,
	changes text NOT NULL,
	revision bigint NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL,
	wallet_transaction_id bigint
);
CREATE TABLE IF NOT EXISTS airline (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL Unique,
	description text,
	country_name text,
	carrier_code1 text,
	carrier_code2 text,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS user_fcm_topic (
	user_id bigint,
	topic_id text,
	created_at timestamp,
	updated_at timestamp,
	disabled_at timestamp
);
CREATE INDEX IF NOT EXISTS user_fcm_topic_created_at_idx ON "user_fcm_topic" USING btree (created_at);
CREATE INDEX IF NOT EXISTS user_fcm_topic_disabled_at_idx ON "user_fcm_topic" USING btree (disabled_at);
CREATE INDEX IF NOT EXISTS user_fcm_topic_topic_id_idx ON "user_fcm_topic" USING btree (topic_id);
CREATE INDEX IF NOT EXISTS user_fcm_topic_updated_at_idx ON "user_fcm_topic" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS user_fcm_topic_user_id_idx ON "user_fcm_topic" USING btree (user_id);
CREATE TABLE IF NOT EXISTS merchant_order_history (
	merchant_order_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	prev_state text,
	curr_state text NOT NULL,
	state_final smallint NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS merchant_order_history_merchant_order_id_idx ON "merchant_order_history" USING btree (merchant_order_id);
CREATE INDEX IF NOT EXISTS merchant_order_history_revision_idx ON "merchant_order_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS order_service (
	id bigint NOT NULL,
	merchant_order_id bigint NOT NULL,
	service_id bigint NOT NULL,
	created_at timestamp,
	updated_at timestamp
);
CREATE UNIQUE INDEX IF NOT EXISTS PK_order_service ON "order_service" USING btree (id);
CREATE INDEX IF NOT EXISTS fkIdx_231 ON "order_service" USING btree (merchant_order_id);
CREATE INDEX IF NOT EXISTS fkIdx_241 ON "order_service" USING btree (service_id);
CREATE TABLE IF NOT EXISTS category (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL Unique,
	description text,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS customs_declare_port (
	id bigint PRIMARY KEY NOT NULL,
	hawb_id bigint,
	date_of_customs_gate_in timestamp,
	date_of_customs_gate_out timestamp,
	date_of_customs_clearance timestamp,
	date_of_customs_declare timestamp,
	customs_declare_no text,
	customs_broker_agent text
);
CREATE TABLE IF NOT EXISTS cod_session_history (
	id bigint PRIMARY KEY NOT NULL,
	cod_session_id bigint NOT NULL,
	revision bigint,
	prev_state text,
	curr_state text,
	user_id bigint NOT NULL,
	changes jsonb NOT NULL,
	updated_at timestamp NOT NULL
);
CREATE INDEX IF NOT EXISTS cod_session_history_changes_idx ON "cod_session_history" USING gin (changes jsonb_path_ops);
CREATE INDEX IF NOT EXISTS cod_session_history_cod_session_id_idx ON "cod_session_history" USING btree (cod_session_id);
CREATE INDEX IF NOT EXISTS cod_session_history_curr_state_idx ON "cod_session_history" USING btree (curr_state);
CREATE INDEX IF NOT EXISTS cod_session_history_id_idx ON "cod_session_history" USING btree (id);
CREATE INDEX IF NOT EXISTS cod_session_history_prev_state_idx ON "cod_session_history" USING btree (prev_state);
CREATE INDEX IF NOT EXISTS cod_session_history_updated_at_idx ON "cod_session_history" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS finance_refund_history (
	id bigint PRIMARY KEY NOT NULL,
	finance_refund_id bigint NOT NULL,
	wallet_transaction_id bigint,
	revision bigint,
	prev_state text,
	curr_state text,
	user_id bigint,
	changes text NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS lastmile_status (
	id integer PRIMARY KEY NOT NULL,
	code text,
	description text
);
CREATE TABLE IF NOT EXISTS user_internal (
	user_id bigint PRIMARY KEY NOT NULL,
	user_type text,
	hash_pwd text
);
CREATE TABLE IF NOT EXISTS callback (
	id bigint PRIMARY KEY NOT NULL,
	model text,
	record_id bigint,
	code text,
	state text,
	state_final integer,
	callback_url text,
	status text,
	error_message text,
	created_at timestamp,
	updated_at timestamp,
	record_updated_at timestamp,
	extra_data text
);
CREATE TABLE IF NOT EXISTS cod_session_detail (
	id bigint PRIMARY KEY NOT NULL,
	cod_in_session_id bigint,
	cod_out_session_id bigint,
	parcel_code text,
	record_id bigint,
	amount bigint,
	created_at timestamp,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS cod_session_detail_cod_in_session_id_idx ON "cod_session_detail" USING btree (cod_in_session_id);
CREATE INDEX IF NOT EXISTS cod_session_detail_cod_out_session_id_idx ON "cod_session_detail" USING btree (cod_out_session_id);
CREATE INDEX IF NOT EXISTS cod_session_detail_created_at_idx ON "cod_session_detail" USING btree (created_at);
CREATE INDEX IF NOT EXISTS cod_session_detail_id_idx ON "cod_session_detail" USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS cod_session_detail_record_id_in_session_id_idx ON "cod_session_detail" USING btree (cod_in_session_id, record_id);
CREATE UNIQUE INDEX IF NOT EXISTS cod_session_detail_record_id_out_session_id_idx ON "cod_session_detail" USING btree (cod_out_session_id, record_id);
CREATE INDEX IF NOT EXISTS cod_session_detail_updated_at_idx ON "cod_session_detail" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS mawb (
	id bigint PRIMARY KEY NOT NULL,
	code text,
	mode_of_transport text,
	agent_iata_code text
);
CREATE TABLE IF NOT EXISTS merchant_plan_order (
	merchant_plan_id bigint,
	plan_id bigint,
	merchant_order_id bigint,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS merchant_plan_order_merchant_order_id ON "merchant_plan_order" USING btree (merchant_order_id);
CREATE INDEX IF NOT EXISTS merchant_plan_order_merchant_plan_id ON "merchant_plan_order" USING btree (merchant_plan_id);
CREATE INDEX IF NOT EXISTS merchant_plan_order_plan_id ON "merchant_plan_order" USING btree (plan_id);
CREATE INDEX IF NOT EXISTS merchant_plan_order_updated_at ON "merchant_plan_order" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS province (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL,
	country text NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	sorting_code text
);
CREATE INDEX IF NOT EXISTS province_code_idx ON "province" USING btree (code);
CREATE INDEX IF NOT EXISTS province_country_code_idx ON "province" USING btree (country);
CREATE INDEX IF NOT EXISTS province_sorting_code_idx ON "province" USING btree (sorting_code);
CREATE TABLE IF NOT EXISTS district (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL,
	province integer NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	province_code integer,
	sorting_code text
);
CREATE INDEX IF NOT EXISTS district_code_idx ON "district" USING btree (code);
CREATE INDEX IF NOT EXISTS district_province_code_idx ON "district" USING btree (province);
CREATE TABLE IF NOT EXISTS holiday_kho_table (
	holiday date
);
CREATE TABLE IF NOT EXISTS holiday_table (
	holiday date,
	country text
);
CREATE TABLE IF NOT EXISTS goods_type (
	id bigint PRIMARY KEY NOT NULL,
	name text
);
CREATE TABLE IF NOT EXISTS order_price_history (
	order_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS order_price_history_revision_idx ON "order_price_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS vnhub_parcel (
	id bigint PRIMARY KEY NOT NULL,
	code text,
	state text,
	last_mile_status text,
	num_deliver integer,
	num_contact integer,
	warehouse text,
	dest_warehouse text,
	last_mile_shipping_info_id bigint,
	last_mile_booking_id bigint,
	num_of_pack integer,
	cod_amount integer,
	sorting_code text,
	parcel_type text,
	weight integer,
	dimensions text,
	location bigint,
	description text,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint,
	rid integer,
	demensions text,
	note text,
	vnhub_box_id bigint,
	num_re_attempt integer
);
CREATE TABLE IF NOT EXISTS product_attribute (
	id bigint PRIMARY KEY NOT NULL,
	product_id bigint,
	attribute_id bigint,
	value text,
	created_at timestamp,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS product_attribute_attribute_id_idx ON "product_attribute" USING btree (attribute_id);
CREATE INDEX IF NOT EXISTS product_attribute_created_at_idx ON "product_attribute" USING btree (created_at);
CREATE INDEX IF NOT EXISTS product_attribute_id_idx ON "product_attribute" USING btree (id);
CREATE INDEX IF NOT EXISTS product_attribute_product_id_idx ON "product_attribute" USING btree (product_id);
CREATE INDEX IF NOT EXISTS product_attribute_updated_at_idx ON "product_attribute" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS product_attribute_value_idx ON "product_attribute" USING btree (value);
CREATE TABLE IF NOT EXISTS sku (
	id bigint,
	sku text,
	title text,
	description text,
	brand text,
	model text,
	asin text,
	gtin text,
	size text,
	color text,
	dimension text,
	weight text,
	images text[],
	created_at timestamp,
	updated_at timestamp,
	source text,
	sensitive boolean
);
CREATE INDEX IF NOT EXISTS sku_asin_idx ON "sku" USING btree (asin);
CREATE INDEX IF NOT EXISTS sku_created_at_idx ON "sku" USING btree (created_at);
CREATE UNIQUE INDEX IF NOT EXISTS sku_id_idx ON "sku" USING btree (id);
CREATE INDEX IF NOT EXISTS sku_sensitive_idx ON "sku" USING btree (sensitive);
CREATE UNIQUE INDEX IF NOT EXISTS sku_sku_idx ON "sku" USING btree (sku);
CREATE INDEX IF NOT EXISTS sku_source_idx ON "sku" USING btree (source);
CREATE INDEX IF NOT EXISTS sku_updated_at_idx ON "sku" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS transportation_fee_area (
	id bigint PRIMARY KEY NOT NULL,
	province text NOT NULL,
	area text NOT NULL,
	provider text NOT NULL,
	transportation_fee_id bigint NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp,
	active boolean,
	action_admin_id text,
	description text
);
CREATE INDEX IF NOT EXISTS fkidx_174 ON "transportation_fee_area" USING btree (transportation_fee_id);
CREATE UNIQUE INDEX IF NOT EXISTS pk_transportation_fee_area ON "transportation_fee_area" USING btree (id);
CREATE TABLE IF NOT EXISTS users_group (
	id bigint PRIMARY KEY NOT NULL,
	code text Unique,
	description text,
	rid bigint,
	action_admin_id bigint NOT NULL
);
CREATE TABLE IF NOT EXISTS wh_inventory_package_history (
	wh_inventory_package_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	prev_state text,
	curr_state text NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS wh_inventory_package_history_revision_idx ON "wh_inventory_package_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS fc_parcel_tracking (
	id bigint NOT NULL,
	parcel_id bigint,
	user_id bigint,
	state text,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS fc_parcel_tracking_id_idx ON "fc_parcel_tracking" USING btree (id);
CREATE INDEX IF NOT EXISTS fc_parcel_tracking_parcel_id_idx ON "fc_parcel_tracking" USING btree (parcel_id);
CREATE INDEX IF NOT EXISTS fc_parcel_tracking_state_idx ON "fc_parcel_tracking" USING btree (state);
CREATE INDEX IF NOT EXISTS fc_parcel_tracking_updated_at_idx ON "fc_parcel_tracking" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS fc_parcel_tracking_user_id_idx ON "fc_parcel_tracking" USING btree (user_id);
CREATE TABLE IF NOT EXISTS holiday_kr_table (
	holiday date,
	country text
);
CREATE TABLE IF NOT EXISTS item (
	id text PRIMARY KEY NOT NULL
);
CREATE TABLE IF NOT EXISTS wh_location (
	id bigint PRIMARY KEY NOT NULL,
	parent_id bigint,
	code text,
	name text,
	warehouse text,
	location_type text,
	created_at timestamp NOT NULL,
	updated_at timestamp,
	active boolean
);
CREATE UNIQUE INDEX IF NOT EXISTS wh_location_code_idx ON "wh_location" USING btree (code);
CREATE INDEX IF NOT EXISTS wh_location_id_idx ON "wh_location" USING btree (id);
CREATE INDEX IF NOT EXISTS wh_location_parent_id_idx ON "wh_location" USING btree (parent_id);
CREATE INDEX IF NOT EXISTS wh_location_warehouse_idx ON "wh_location" USING btree (warehouse);
CREATE TABLE IF NOT EXISTS box (
	id bigint PRIMARY KEY NOT NULL,
	code text,
	description text,
	forwarding_agent text,
	warehouse text,
	created_at timestamp,
	updated_at timestamp,
	gross_weight integer,
	quantity integer,
	state text,
	action_admin_id bigint,
	rid bigint,
	delivery_order_id bigint,
	location bigint,
	weight integer,
	length integer,
	height integer,
	width integer,
	f4box_id bigint,
	type text,
	sensitive smallint
);
CREATE UNIQUE INDEX IF NOT EXISTS box_code_idx ON "box" USING btree (code);
CREATE INDEX IF NOT EXISTS box_created_at_idx ON "box" USING btree (created_at);
CREATE INDEX IF NOT EXISTS box_delivery_order_id_idx ON "box" USING btree (delivery_order_id);
CREATE INDEX IF NOT EXISTS box_forwarding_agent_idx ON "box" USING btree (forwarding_agent);
CREATE INDEX IF NOT EXISTS box_rid_idx ON "box" USING btree (rid);
CREATE INDEX IF NOT EXISTS box_sensitive_idx ON "box" USING btree (sensitive);
CREATE INDEX IF NOT EXISTS box_type_idx ON "box" USING btree (type);
CREATE INDEX IF NOT EXISTS box_updated_at_idx ON "box" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS box_warehouse_idx ON "box" USING btree (warehouse);
CREATE INDEX IF NOT EXISTS f4box_idx ON "box" USING btree (f4box_id);
CREATE TABLE IF NOT EXISTS consignee_cbe (
	id bigint PRIMARY KEY NOT NULL,
	merchant_id bigint,
	name text NOT NULL,
	phone text NOT NULL,
	address text NOT NULL,
	ward text NOT NULL,
	district text NOT NULL,
	province text NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint
);
CREATE TABLE IF NOT EXISTS seller (
	id bigint PRIMARY KEY NOT NULL,
	name text NOT NULL,
	merchant_id bigint,
	tax text NOT NULL,
	address text NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint,
	phone text
);
CREATE TABLE IF NOT EXISTS coupon_code (
	id bigint PRIMARY KEY NOT NULL,
	code text NOT NULL Unique,
	description text,
	max_use integer,
	max_used_per_user integer,
	started_at timestamp NOT NULL,
	expired_at timestamp NOT NULL,
	coupon_type smallint NOT NULL,
	value_x integer NOT NULL,
	value_vnd integer,
	max_value_vnd integer,
	discount_on text NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint NOT NULL,
	rid bigint,
	active boolean NOT NULL,
	current_condition_value text,
	title text,
	max_items integer,
	max_items_per_user integer
);
CREATE TABLE IF NOT EXISTS email_history (
	id bigint PRIMARY KEY NOT NULL,
	from_address text,
	to_address text,
	subject text,
	created_at timestamp,
	status boolean,
	error_message text
);
CREATE INDEX IF NOT EXISTS email_history_created_at ON "email_history" USING btree (created_at);
CREATE INDEX IF NOT EXISTS email_history_from_address ON "email_history" USING btree (from_address);
CREATE TABLE IF NOT EXISTS order_item_history (
	order_item_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	prev_state text,
	curr_state text NOT NULL,
	state_final smallint NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS order_item_history_order_item_id_idx ON "order_item_history" USING btree (order_item_id);
CREATE INDEX IF NOT EXISTS order_item_history_revision_idx ON "order_item_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS consignee_name (
	id integer PRIMARY KEY NOT NULL,
	name text,
	created_at timestamp NOT NULL,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS consignee_created_at_idx ON "consignee_name" USING btree (created_at);
CREATE INDEX IF NOT EXISTS consignee_updated_at_idx ON "consignee_name" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS merchant_order (
	id bigint PRIMARY KEY NOT NULL,
	code text Unique,
	flow text,
	state text NOT NULL,
	state_final smallint NOT NULL,
	created_at timestamp,
	updated_at timestamp,
	cancelled_at timestamp,
	created_by_admin_id bigint,
	merchant_id bigint NOT NULL,
	merchant text,
	note_admin text,
	note_cancel text,
	note_order text,
	note_shipping text,
	coupon_code text,
	cod_amount_vnd integer,
	is_test smallint,
	note_admin_merchant text,
	supplier_tracking_number text,
	supplier_order_number text,
	action_admin_id bigint,
	rid bigint,
	supplier_courier text,
	platform text,
	country text,
	invoice_link text,
	use_insurance boolean,
	supplier_coupon_code text,
	first_mile_method text,
	last_mile_method text,
	last_mile_shipping_info_id bigint,
	merchant_plan_id bigint,
	is_cbe boolean,
	cbe_order_date timestamp,
	cbe_consignee_id bigint,
	seller_id bigint,
	estimated_delivery_date timestamp,
	merchant_type text,
	sorting_code text,
	customs_invoice_no text,
	customs_invoice_date timestamp,
	customs_invoice_link text,
	customs_po_no text,
	customs_po_date timestamp,
	customs_po_link text,
	customs_co_link text,
	customs_cq_link text,
	customs_import_duty text,
	customs_vat bigint,
	customs_note text,
	customs_hbl_no text,
	customs_mbl_no text,
	departure_date timestamp,
	truck_no text,
	letter_of_authorization text,
	delivery_order_no text,
	customs_declaration_no text,
	invoice_value_vnd integer,
	need_paying boolean
);
CREATE INDEX IF NOT EXISTS merchant_order_cancelled_at_idx ON "merchant_order" USING btree (cancelled_at);
CREATE INDEX IF NOT EXISTS merchant_order_country_idx ON "merchant_order" USING btree (country);
CREATE INDEX IF NOT EXISTS merchant_order_created_at_idx ON "merchant_order" USING btree (created_at);
CREATE INDEX IF NOT EXISTS merchant_order_merchant_id_idx ON "merchant_order" USING btree (merchant_id);
CREATE INDEX IF NOT EXISTS merchant_order_merchant_idx ON "merchant_order" USING btree (merchant);
CREATE INDEX IF NOT EXISTS merchant_order_platform ON "merchant_order" USING btree (platform);
CREATE INDEX IF NOT EXISTS merchant_order_rid_idx ON "merchant_order" USING btree (rid);
CREATE INDEX IF NOT EXISTS merchant_order_state_final_idx ON "merchant_order" USING btree (state_final);
CREATE INDEX IF NOT EXISTS merchant_order_state_idx ON "merchant_order" USING btree (state);
CREATE INDEX IF NOT EXISTS merchant_order_supplier_order_number_idx ON "merchant_order" USING btree (supplier_order_number);
CREATE INDEX IF NOT EXISTS merchant_order_supplier_tracking_number_idx ON "merchant_order" USING btree (supplier_tracking_number);
CREATE INDEX IF NOT EXISTS merchant_order_updated_at_idx ON "merchant_order" USING btree (updated_at);
CREATE TABLE IF NOT EXISTS vnhub_parcel_history (
	parcel_code text NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	prev_state text,
	curr_state text NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS vnhub_parcel_history_code_idx ON "vnhub_parcel_history" USING btree (parcel_code);
CREATE INDEX IF NOT EXISTS vnhub_parcel_history_revision_idx ON "vnhub_parcel_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS wh_inventory_item_history (
	wh_inventory_item_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS wh_inventory_item_history_revision_idx ON "wh_inventory_item_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS last_mile_booking (
	id bigint PRIMARY KEY NOT NULL,
	last_mile_id bigint,
	booking_code text,
	booking_fee_vnd bigint,
	est_delivery_time timestamp,
	actual_delivery_time timestamp,
	actual_weight integer,
	dim_weight integer,
	length integer,
	width integer,
	height integer,
	state text,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint,
	rid bigint
);
CREATE TABLE IF NOT EXISTS parcel_item (
	parcel_id bigint,
	wh_inventory_item_id bigint,
	quantity integer,
	sku text,
	supplier_tracking_number text,
	created_at timestamp,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS parcel_item_created_at_idx ON "parcel_item" USING btree (created_at);
CREATE INDEX IF NOT EXISTS parcel_item_parcel_id_idx ON "parcel_item" USING btree (parcel_id);
CREATE INDEX IF NOT EXISTS parcel_item_updated_at_idx ON "parcel_item" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS parcel_item_wh_inventory_item_id_idx ON "parcel_item" USING btree (wh_inventory_item_id);
CREATE TABLE IF NOT EXISTS service (
	id bigint NOT NULL,
	name text NOT NULL,
	code text NOT NULL,
	description text NOT NULL,
	service_type text,
	active boolean,
	updated_at date,
	action_admin_id text
);
CREATE UNIQUE INDEX IF NOT EXISTS PK_service ON "service" USING btree (id);
CREATE TABLE IF NOT EXISTS merchant_contract (
	id bigint PRIMARY KEY NOT NULL,
	merchant_code text,
	tax_id text,
	company_name text,
	company_address text,
	company_register_at text,
	company_representor text,
	company_representor_position text,
	verify_state text,
	term_state text,
	ic_number text,
	ic_fullname text,
	ic_birthday_at timestamp,
	ic_place_of_permanent text,
	ic_issuance_at timestamp,
	ic_issuance_place text,
	ic_front_image text,
	ic_back_image text,
	user_id bigint NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);
CREATE INDEX IF NOT EXISTS merchant_contract_created_at ON "merchant_contract" USING btree (created_at);
CREATE INDEX IF NOT EXISTS merchant_contract_id ON "merchant_contract" USING btree (id);
CREATE INDEX IF NOT EXISTS merchant_contract_merchant_code ON "merchant_contract" USING btree (merchant_code);
CREATE INDEX IF NOT EXISTS merchant_contract_term_state ON "merchant_contract" USING btree (term_state);
CREATE INDEX IF NOT EXISTS merchant_contract_updated_at ON "merchant_contract" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS merchant_contract_user_id ON "merchant_contract" USING btree (user_id);
CREATE INDEX IF NOT EXISTS merchant_contract_verify_state ON "merchant_contract" USING btree (verify_state);
CREATE TABLE IF NOT EXISTS warehouse_user (
	id bigint PRIMARY KEY NOT NULL,
	warehouse text,
	user_id bigint,
	created_at timestamp,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS warehouse_user_created_at_idx ON "warehouse_user" USING btree (created_at);
CREATE INDEX IF NOT EXISTS warehouse_user_updated_at_idx ON "warehouse_user" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS warehouse_user_user_id_idx ON "warehouse_user" USING btree (user_id);
CREATE INDEX IF NOT EXISTS warehouse_user_warehouse_idx ON "warehouse_user" USING btree (warehouse);
CREATE TABLE IF NOT EXISTS wh_inventory_package (
	id bigint,
	supplier_tracking_number text,
	warehouse text,
	created_at timestamp,
	updated_at timestamp,
	state smallint,
	action_admin_id bigint,
	rid bigint,
	location bigint
);
CREATE INDEX IF NOT EXISTS wh_inventory_package_created_at_idx ON "wh_inventory_package" USING btree (created_at);
CREATE UNIQUE INDEX IF NOT EXISTS wh_inventory_package_id_idx ON "wh_inventory_package" USING btree (id);
CREATE INDEX IF NOT EXISTS wh_inventory_package_rid_idx ON "wh_inventory_package" USING btree (rid);
CREATE UNIQUE INDEX IF NOT EXISTS wh_inventory_package_supplier_tracking_number_idx ON "wh_inventory_package" USING btree (supplier_tracking_number);
CREATE INDEX IF NOT EXISTS wh_inventory_package_updated_at_idx ON "wh_inventory_package" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS wh_inventory_package_warehouse_idx ON "wh_inventory_package" USING btree (warehouse);
CREATE TABLE IF NOT EXISTS call_history (
	id bigint PRIMARY KEY NOT NULL,
	code text,
	note_code text,
	call_status text,
	extra_note text,
	duration bigint,
	created_at timestamp,
	action_admin_id bigint
);
CREATE INDEX IF NOT EXISTS call_history_code ON "call_history" USING btree (code);
CREATE TABLE IF NOT EXISTS consignee_address (
	id integer PRIMARY KEY NOT NULL,
	address text,
	created_at timestamp NOT NULL,
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS consignee_address_idx ON "consignee_address" USING btree (address);
CREATE TABLE IF NOT EXISTS merchant (
	id bigint PRIMARY KEY NOT NULL,
	code text Unique,
	created_at timestamp,
	updated_at timestamp,
	deleted_at timestamp,
	disabled_at timestamp,
	name text NOT NULL,
	email text NOT NULL,
	phone text NOT NULL Unique,
	address text,
	avatar text,
	refcode text,
	admin_id bigint,
	province text,
	province_name text,
	district text,
	district_name text,
	ward text,
	ward_name text,
	birthday timestamp,
	gender smallint,
	active boolean,
	country text,
	is_cbe boolean,
	type text
);
CREATE TABLE IF NOT EXISTS parcel (
	id bigint PRIMARY KEY NOT NULL,
	code text,
	description text,
	box_id bigint,
	warehouse text,
	shipper_name text,
	shipper_address text,
	shipper_country text,
	shipper_tel text,
	consignee_name text,
	consignee_address text,
	consignee_country text,
	consignee_tel text,
	consignee_checksum text,
	gross_weight integer,
	number_of_package integer,
	value integer,
	quantity integer,
	created_at timestamp,
	updated_at timestamp,
	active boolean,
	state text,
	action_admin_id bigint,
	rid bigint,
	real_weight integer,
	note text,
	dest_warehouse text,
	consignee_ward integer,
	consignee_district integer,
	consignee_province integer,
	last_mile_booking_id bigint,
	location bigint,
	weight integer,
	sorting_code text,
	parcel_type text,
	sensitive boolean,
	vnhub_box_id bigint,
	last_mile_status text,
	num_deliver integer,
	num_contact integer,
	num_re_attempt integer,
	last_mile_shipping_info_id bigint,
	cod_amount integer,
	actual_cod_amount integer
);
CREATE INDEX IF NOT EXISTS order_item_sorting_code_idx ON "parcel" USING btree (sorting_code);
CREATE INDEX IF NOT EXISTS parcel_active_idx ON "parcel" USING btree (active);
CREATE INDEX IF NOT EXISTS parcel_box_id_idx ON "parcel" USING btree (box_id);
CREATE UNIQUE INDEX IF NOT EXISTS parcel_code_idx ON "parcel" USING btree (code);
CREATE INDEX IF NOT EXISTS parcel_consignee_checksum_idx ON "parcel" USING btree (consignee_checksum);
CREATE INDEX IF NOT EXISTS parcel_created_at_idx ON "parcel" USING btree (created_at);
CREATE INDEX IF NOT EXISTS parcel_last_mile_booking_idx ON "parcel" USING btree (last_mile_booking_id);
CREATE INDEX IF NOT EXISTS parcel_parcel_type_idx ON "parcel" USING btree (parcel_type);
CREATE INDEX IF NOT EXISTS parcel_rid_idx ON "parcel" USING btree (rid);
CREATE INDEX IF NOT EXISTS parcel_sensitive_idx ON "parcel" USING btree (sensitive);
CREATE INDEX IF NOT EXISTS parcel_sorting_code_idx ON "parcel" USING btree (sorting_code);
CREATE INDEX IF NOT EXISTS parcel_updated_at_idx ON "parcel" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS parcel_warehouse_idx ON "parcel" USING btree (warehouse);
CREATE INDEX IF NOT EXISTS vnhub_box_idx ON "parcel" USING btree (vnhub_box_id);
CREATE TABLE IF NOT EXISTS tracking_number_history (
	tracking_id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	prev_code text,
	curr_code text NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS tracking_number_history_revision_idx ON "tracking_number_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS webhook (
	id bigint PRIMARY KEY NOT NULL,
	type text,
	method text,
	merchant_id bigint,
	url text,
	action_admin_id bigint,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS bank_history (
	id bigint PRIMARY KEY NOT NULL,
	bank_id bigint NOT NULL,
	owner_name text,
	owner_account text,
	bank_name text,
	bank_province text,
	bank_branch text,
	user_id bigint,
	changes text,
	revision bigint,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS customs_broker_agent (
	code text PRIMARY KEY NOT NULL,
	name text NOT NULL Unique,
	description text,
	short_name text,
	address text,
	phone text,
	fax text,
	pic text,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS pagent_order (
	id bigint PRIMARY KEY NOT NULL,
	merchant_order_id bigint,
	code text,
	pagent_id bigint,
	warehouse text,
	total_amount_x integer,
	discount_x integer,
	supplier_price_x integer,
	shipping_fee_x integer,
	tax_x integer,
	currency text,
	exchange_rate integer,
	commission_percent smallint,
	commission_x integer,
	supplier_order_number text,
	supplier_courier text,
	supplier_tracking_number text,
	est_delivery_xx_at timestamp,
	state text,
	state_final smallint,
	purchased_at timestamp,
	created_at timestamp,
	updated_at timestamp,
	action_admin_id bigint,
	rid bigint,
	basket_value_x integer
);
CREATE INDEX IF NOT EXISTS pagent_order_code_idx ON "pagent_order" USING btree (code);
CREATE INDEX IF NOT EXISTS pagent_order_created_at_idx ON "pagent_order" USING btree (created_at);
CREATE INDEX IF NOT EXISTS pagent_order_id_idx ON "pagent_order" USING btree (id);
CREATE INDEX IF NOT EXISTS pagent_order_merchant_order_id_idx ON "pagent_order" USING btree (merchant_order_id);
CREATE INDEX IF NOT EXISTS pagent_order_pagent_id_idx ON "pagent_order" USING btree (pagent_id);
CREATE INDEX IF NOT EXISTS pagent_order_state_final_idx ON "pagent_order" USING btree (state_final);
CREATE INDEX IF NOT EXISTS pagent_order_state_idx ON "pagent_order" USING btree (state);
CREATE INDEX IF NOT EXISTS pagent_order_updated_at_idx ON "pagent_order" USING btree (updated_at);
CREATE INDEX IF NOT EXISTS pagent_order_warehouse_idx ON "pagent_order" USING btree (warehouse);
CREATE TABLE IF NOT EXISTS cart_attribute (
	id bigint PRIMARY KEY NOT NULL,
	cart_id bigint,
	color text,
	size text,
	image text,
	quantity text,
	created_at timestamp,
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS surcharge_history (
	id bigint NOT NULL,
	revision bigint NOT NULL,
	user_id bigint NOT NULL,
	updated_at timestamp NOT NULL,
	changes jsonb
);
CREATE INDEX IF NOT EXISTS surcharge_history_revision_idx ON "surcharge_history" USING btree (revision);
CREATE TABLE IF NOT EXISTS transportation_fee (
	id bigint PRIMARY KEY NOT NULL,
	fee bigint NOT NULL,
	remark text NOT NULL,
	area text NOT NULL,
	active boolean,
	created_at timestamp,
	updated_at timestamp,
	service_id bigint,
	origin text,
	min_amount numeric(4,0),
	currency text,
	lower_threshold integer,
	upper_threshold integer,
	unit text,
	country_side_fee bigint,
	action_admin_id text,
	description text
);
CREATE UNIQUE INDEX IF NOT EXISTS pk_transportation_fee ON "transportation_fee" USING btree (id);

/*-- TRIGGER BEGIN --*/
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


/*-- TRIGGER END --*/

COMMIT;
