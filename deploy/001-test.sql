
BEGIN;
CREATE TABLE IF NOT EXISTS airline (
	code text NOT NULL
	name text NOT NULL
	description text
	country_name text
	carrier_code1 text
	carrier_code2 text
	created_at timestamp
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS airport (
	code text NOT NULL
	name text NOT NULL
	description text
	city_name text
	country_name text
	iaco text
	faa text
	created_at timestamp
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS attribute (
	id bigint NOT NULL
	name text
	description text
	merchant_id bigint
	created_at timestamp
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS attribute_created_at_idx ON "attribute" (created_at);
CREATE INDEX IF NOT EXISTS attribute_id_idx ON "attribute" (id);
CREATE INDEX IF NOT EXISTS attribute_merchant_id_idx ON "attribute" (merchant_id);
CREATE INDEX IF NOT EXISTS attribute_name_idx ON "attribute" (name);
CREATE INDEX IF NOT EXISTS attribute_updated_at_idx ON "attribute" (updated_at);
CREATE TABLE IF NOT EXISTS bank (
	id bigint NOT NULL
	merchant_id bigint NOT NULL
	merchant_code text NOT NULL
	owner_name text
	owner_account text
	bank_name text
	bank_province text
	bank_branch text
	user_id bigint
	rid bigint
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS bank_history (
	id bigint NOT NULL
	bank_id bigint NOT NULL
	owner_name text
	owner_account text
	bank_name text
	bank_province text
	bank_branch text
	user_id bigint
	changes text
	revision bigint
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS booking (
	id bigint NOT NULL
	br_code text
	bc_code text
	quotation_id bigint
	etd timestamp
	eta timestamp
	doc_cut_off timestamp
	goods_cut_off timestamp
	state text
);
CREATE TABLE IF NOT EXISTS box (
	id bigint NOT NULL
	code text
	description text
	forwarding_agent text
	warehouse text
	created_at timestamp
	updated_at timestamp
	gross_weight integer
	quantity integer
	state text
	action_admin_id bigint
	rid bigint
	delivery_order_id bigint
	location bigint
	weight integer
	length integer
	height integer
	width integer
	f4box_id bigint
	type text
	sensitive smallint
);
CREATE INDEX IF NOT EXISTS INDEX ON "box" (code);
CREATE INDEX IF NOT EXISTS box_created_at_idx ON "box" (created_at);
CREATE INDEX IF NOT EXISTS box_delivery_order_id_idx ON "box" (delivery_order_id);
CREATE INDEX IF NOT EXISTS box_forwarding_agent_idx ON "box" (forwarding_agent);
CREATE INDEX IF NOT EXISTS box_rid_idx ON "box" (rid);
CREATE INDEX IF NOT EXISTS box_sensitive_idx ON "box" (sensitive);
CREATE INDEX IF NOT EXISTS box_type_idx ON "box" (type);
CREATE INDEX IF NOT EXISTS box_updated_at_idx ON "box" (updated_at);
CREATE INDEX IF NOT EXISTS box_warehouse_idx ON "box" (warehouse);
CREATE INDEX IF NOT EXISTS f4box_idx ON "box" (f4box_id);
CREATE TABLE IF NOT EXISTS box_history (
	box_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	prev_state text
	curr_state text NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS box_history_revision_idx ON "box_history" (revision);
CREATE TABLE IF NOT EXISTS call_history (
	id bigint NOT NULL
	code text
	note_code text
	call_status text
	extra_note text
	duration bigint
	created_at timestamp
	action_admin_id bigint
);
CREATE INDEX IF NOT EXISTS call_history_code ON "call_history" (code);
CREATE TABLE IF NOT EXISTS callback (
	id bigint NOT NULL
	model text
	record_id bigint
	code text
	state text
	state_final integer
	callback_url text
	status text
	error_message text
	created_at timestamp
	updated_at timestamp
	record_updated_at timestamp
	extra_data text
);
CREATE TABLE IF NOT EXISTS cart (
	id bigint NOT NULL
	merchant_id bigint
	name_cart text
	link_cart text
	image_cart text
	site text
	price_cart text
	currency text
	created_at timestamp
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS cart_attribute (
	id bigint NOT NULL
	cart_id bigint
	color text
	size text
	image text
	quantity text
	created_at timestamp
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS category (
	code text NOT NULL
	name text NOT NULL
	description text
	created_at timestamp
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS cod_session (
	id bigint NOT NULL
	parent_id bigint
	code text
	type text
	description text
	action_admin_id bigint
	total_amount bigint
	actual_amount bigint
	amount_of_discrepancy bigint
	state text
	has_child boolean
	transaction_date timestamp
	rid bigint
	created_at timestamp
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS INDEX ON "cod_session" (code);
CREATE INDEX IF NOT EXISTS cod_session_created_at_idx ON "cod_session" (created_at);
CREATE INDEX IF NOT EXISTS cod_session_has_child_idx ON "cod_session" (has_child);
CREATE INDEX IF NOT EXISTS INDEX ON "cod_session" (id);
CREATE INDEX IF NOT EXISTS cod_session_parent_id_idx ON "cod_session" (parent_id);
CREATE INDEX IF NOT EXISTS cod_session_rid_idx ON "cod_session" (rid);
CREATE INDEX IF NOT EXISTS cod_session_state_idx ON "cod_session" (state);
CREATE INDEX IF NOT EXISTS cod_session_transaction_date_idx ON "cod_session" (transaction_date);
CREATE INDEX IF NOT EXISTS cod_session_type_idx ON "cod_session" (type);
CREATE INDEX IF NOT EXISTS cod_session_updated_at_idx ON "cod_session" (updated_at);
CREATE TABLE IF NOT EXISTS cod_session_detail (
	id bigint NOT NULL
	cod_in_session_id bigint
	cod_out_session_id bigint
	parcel_code text
	record_id bigint
	amount bigint
	created_at timestamp
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS cod_session_detail_cod_in_session_id_idx ON "cod_session_detail" (cod_in_session_id);
CREATE INDEX IF NOT EXISTS cod_session_detail_cod_out_session_id_idx ON "cod_session_detail" (cod_out_session_id);
CREATE INDEX IF NOT EXISTS cod_session_detail_created_at_idx ON "cod_session_detail" (created_at);
CREATE INDEX IF NOT EXISTS cod_session_detail_id_idx ON "cod_session_detail" (id);
CREATE INDEX IF NOT EXISTS INDEX ON "cod_session_detail" (ecord_id);
CREATE INDEX IF NOT EXISTS INDEX ON "cod_session_detail" (ecord_id);
CREATE INDEX IF NOT EXISTS cod_session_detail_updated_at_idx ON "cod_session_detail" (updated_at);
CREATE TABLE IF NOT EXISTS cod_session_history (
	id bigint NOT NULL
	cod_session_id bigint NOT NULL
	revision bigint
	prev_state text
	curr_state text
	user_id bigint NOT NULL
	changes jsonb NOT NULL
	updated_at timestamp NOT NULL
);
CREATE INDEX IF NOT EXISTS cod_session_history_changes_idx ON "cod_session_history" (sonb_path_ops);
CREATE INDEX IF NOT EXISTS cod_session_history_cod_session_id_idx ON "cod_session_history" (cod_session_id);
CREATE INDEX IF NOT EXISTS cod_session_history_curr_state_idx ON "cod_session_history" (curr_state);
CREATE INDEX IF NOT EXISTS cod_session_history_id_idx ON "cod_session_history" (id);
CREATE INDEX IF NOT EXISTS cod_session_history_prev_state_idx ON "cod_session_history" (prev_state);
CREATE INDEX IF NOT EXISTS cod_session_history_updated_at_idx ON "cod_session_history" (updated_at);
CREATE TABLE IF NOT EXISTS consignee_address (
	id integer NOT NULL
	address text
	created_at timestamp NOT NULL
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS consignee_address_idx ON "consignee_address" (address);
CREATE TABLE IF NOT EXISTS consignee_cbe (
	id bigint NOT NULL
	merchant_id bigint
	name text NOT NULL
	phone text NOT NULL
	address text NOT NULL
	ward text NOT NULL
	district text NOT NULL
	province text NOT NULL
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint
);
CREATE TABLE IF NOT EXISTS consignee_name (
	id integer NOT NULL
	name text
	created_at timestamp NOT NULL
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS consignee_created_at_idx ON "consignee_name" (created_at);
CREATE INDEX IF NOT EXISTS consignee_updated_at_idx ON "consignee_name" (updated_at);
CREATE TABLE IF NOT EXISTS consignee_tel (
	id integer NOT NULL
	tel text
	created_at timestamp NOT NULL
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS consignee_tel_idx ON "consignee_tel" (tel);
CREATE TABLE IF NOT EXISTS country (
	code text NOT NULL
	name text NOT NULL
	created_at timestamp
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS country_code_idx ON "country" (code);
CREATE TABLE IF NOT EXISTS coupon_code (
	id bigint NOT NULL
	code text NOT NULL
	description text
	max_use integer
	max_used_per_user integer
	started_at timestamp NOT NULL
	expired_at timestamp NOT NULL
	coupon_type smallint NOT NULL
	value_x integer NOT NULL
	value_vnd integer
	max_value_vnd integer
	discount_on text NOT NULL
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint NOT NULL
	rid bigint
	active boolean NOT NULL
	current_condition_value text
	title text
	max_items integer
	max_items_per_user integer
);
CREATE TABLE IF NOT EXISTS coupon_code_history (
	coupon_code_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS coupon_code_history_coupon_id_idx ON "coupon_code_history" (coupon_code_id);
CREATE TABLE IF NOT EXISTS coupon_condition (
	id bigint NOT NULL
	description text
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint NOT NULL
	rid bigint
	condition_type smallint NOT NULL
	condition_value text
);
CREATE TABLE IF NOT EXISTS coupon_condition_history (
	coupon_condition_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS coupon_condition_history_coupon_id_idx ON "coupon_condition_history" (coupon_condition_id);
CREATE TABLE IF NOT EXISTS coupon_rule (
	coupon_code_id bigint NOT NULL
	coupon_condition_id bigint NOT NULL
);
CREATE TABLE IF NOT EXISTS courier (
	code text NOT NULL
	name text NOT NULL
	description text
	created_at timestamp
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS customs_broker_agent (
	code text NOT NULL
	name text NOT NULL
	description text
	short_name text
	address text
	phone text
	fax text
	pic text
	created_at timestamp
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS customs_declare_port (
	id bigint NOT NULL
	hawb_id bigint
	date_of_customs_gate_in timestamp
	date_of_customs_gate_out timestamp
	date_of_customs_clearance timestamp
	date_of_customs_declare timestamp
	customs_declare_no text
	customs_broker_agent text
);
CREATE TABLE IF NOT EXISTS delivery_order (
	id bigint NOT NULL
	code text
	warehouse text
	forwarding_agent text
	truck_number text
	driver_name text
	action_admin_id bigint
	pickup_at timestamp
	est_pickup_at timestamp
	created_at timestamp NOT NULL
	updated_at timestamp
	state text
	picking_type text
	est_weight integer
	weight integer
	admin_id bigint
	dest_warehouse text
	type smallint
	active boolean
	customs_broker_agent text
);
CREATE INDEX IF NOT EXISTS delivery_order_admin_id_idx ON "delivery_order" (action_admin_id);
CREATE INDEX IF NOT EXISTS delivery_order_code_idx ON "delivery_order" (code);
CREATE INDEX IF NOT EXISTS delivery_order_created_at_idx ON "delivery_order" (created_at);
CREATE INDEX IF NOT EXISTS delivery_order_customs_broker_agent_idx ON "delivery_order" (customs_broker_agent);
CREATE INDEX IF NOT EXISTS delivery_order_forwarding_agent_idx ON "delivery_order" (forwarding_agent);
CREATE INDEX IF NOT EXISTS delivery_order_id_idx ON "delivery_order" (id);
CREATE INDEX IF NOT EXISTS delivery_order_pickup_at_idx ON "delivery_order" (pickup_at);
CREATE INDEX IF NOT EXISTS delivery_order_state_idx ON "delivery_order" (state);
CREATE INDEX IF NOT EXISTS delivery_order_updated_at_idx ON "delivery_order" (updated_at);
CREATE INDEX IF NOT EXISTS delivery_order_warehouse_idx ON "delivery_order" (warehouse);
CREATE TABLE IF NOT EXISTS delivery_order_item (
	id bigint NOT NULL
	delivery_order_id bigint
	item_id bigint
	table_name text
);
CREATE INDEX IF NOT EXISTS INDEX ON "delivery_order_item" (tem_id);
CREATE TABLE IF NOT EXISTS district (
	code text NOT NULL
	name text NOT NULL
	province integer NOT NULL
	created_at timestamp
	updated_at timestamp
	province_code integer
	sorting_code text
);
CREATE INDEX IF NOT EXISTS district_code_idx ON "district" (code);
CREATE INDEX IF NOT EXISTS district_province_code_idx ON "district" (province);
CREATE TABLE IF NOT EXISTS email_history (
	id bigint NOT NULL
	from_address text
	to_address text
	subject text
	created_at timestamp
	status boolean
	error_message text
);
CREATE INDEX IF NOT EXISTS email_history_created_at ON "email_history" (created_at);
CREATE INDEX IF NOT EXISTS email_history_from_address ON "email_history" (from_address);
CREATE TABLE IF NOT EXISTS fc_parcel_tracking (
	id bigint NOT NULL
	parcel_id bigint
	user_id bigint
	state text
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS fc_parcel_tracking_id_idx ON "fc_parcel_tracking" (id);
CREATE INDEX IF NOT EXISTS fc_parcel_tracking_parcel_id_idx ON "fc_parcel_tracking" (parcel_id);
CREATE INDEX IF NOT EXISTS fc_parcel_tracking_state_idx ON "fc_parcel_tracking" (state);
CREATE INDEX IF NOT EXISTS fc_parcel_tracking_updated_at_idx ON "fc_parcel_tracking" (updated_at);
CREATE INDEX IF NOT EXISTS fc_parcel_tracking_user_id_idx ON "fc_parcel_tracking" (user_id);
CREATE TABLE IF NOT EXISTS fcm_topic (
	id bigint NOT NULL
	name text
	title text
	created_at timestamp
	updated_at timestamp
	disabled_at timestamp
);
CREATE INDEX IF NOT EXISTS fcm_topic_created_at_idx ON "fcm_topic" (created_at);
CREATE INDEX IF NOT EXISTS fcm_topic_disabled_at_idx ON "fcm_topic" (disabled_at);
CREATE INDEX IF NOT EXISTS fcm_topic_name_idx ON "fcm_topic" (name);
CREATE INDEX IF NOT EXISTS fcm_topic_updated_at_idx ON "fcm_topic" (updated_at);
CREATE TABLE IF NOT EXISTS finance_refund (
	id bigint NOT NULL
	wallet_transaction_id bigint NOT NULL
	value_vnd double NOT NULL
	state text NOT NULL
	type text NOT NULL
	state_final integer NOT NULL
	merchant_id bigint NOT NULL
	wallet_id bigint
	bank_id bigint
	note_admin text
	user_id bigint NOT NULL
	rid bigint
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS finance_refund_history (
	id bigint NOT NULL
	finance_refund_id bigint NOT NULL
	wallet_transaction_id bigint
	revision bigint
	prev_state text
	curr_state text
	user_id bigint
	changes text NOT NULL
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS forwarding_agent (
	code text NOT NULL
	name text NOT NULL
	description text
	short_name text
	address text
	phone text
	fax text
	pic text
	created_at timestamp
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS gic_staff (
	id bigint NOT NULL
	code text
	created_at timestamp
	updated_at timestamp
	deleted_at timestamp
	disabled_at timestamp
	roles text[]
	name text NOT NULL
	email text NOT NULL
	phone text NOT NULL
	avatar text
);
CREATE TABLE IF NOT EXISTS goods_type (
	id bigint NOT NULL
	name text
);
CREATE TABLE IF NOT EXISTS hawb (
	id bigint NOT NULL
	booking_id bigint
	parcel_id bigint
	mawb_id bigint
	lot text
	account_no text
	sign_shipper text
	payment_type_id bigint
	excute_on date
	excute_at text
	excute_by text
	currency text
	chgs text
	wtva_1 text
	wtva_2 text
	other_1 text
	other_2 text
	decl_val_for_carrier text
	decl_val_for_customs text
);
CREATE TABLE IF NOT EXISTS holiday_cn_table (
	holiday date
	country text
);
CREATE TABLE IF NOT EXISTS holiday_kho_table (
	holiday date
);
CREATE TABLE IF NOT EXISTS holiday_kr_table (
	holiday date
	country text
);
CREATE TABLE IF NOT EXISTS holiday_table (
	holiday date
	country text
);
CREATE TABLE IF NOT EXISTS inspection_fee (
	id bigint NOT NULL
	fee bigint NOT NULL
	lower_threshold integer NOT NULL
	upper_threshold integer NOT NULL
	product_price_threshold bigint NOT NULL
	active boolean
	created_at timestamp
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS INDEX ON "inspection_fee" (id);
CREATE TABLE IF NOT EXISTS invoice (
	id bigint NOT NULL
	invoice_no text
	date date
	payment_type text
	payment_term text
	hawb_id bigint
);
CREATE TABLE IF NOT EXISTS invoice_goods_type (
	invoice_id bigint NOT NULL
	goods_type_id bigint NOT NULL
);
CREATE TABLE IF NOT EXISTS item (
	id text NOT NULL
);
CREATE TABLE IF NOT EXISTS last_mile_booking (
	id bigint NOT NULL
	last_mile_id bigint
	booking_code text
	booking_fee_vnd bigint
	est_delivery_time timestamp
	actual_delivery_time timestamp
	actual_weight integer
	dim_weight integer
	length integer
	width integer
	height integer
	state text
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint
	rid bigint
);
CREATE TABLE IF NOT EXISTS last_mile_booking_history (
	id bigint NOT NULL
	last_mile_booking_id bigint
	status text
	created_at timestamp
	rid bigint
	code text
);
CREATE TABLE IF NOT EXISTS last_mile_provider (
	id bigint NOT NULL
	code text
	name text
	description text
	active boolean
	created_at timestamp
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS last_mile_shipping_info (
	id bigint NOT NULL
	merchant_id bigint
	name text NOT NULL
	phone text NOT NULL
	email text
	address text NOT NULL
	district text NOT NULL
	ward text NOT NULL
	province text NOT NULL
	created_at timestamp
	updated_at timestamp
	longitude double
	latitude double
);
CREATE INDEX IF NOT EXISTS last_mile_shipping_info_created_at_idx ON "last_mile_shipping_info" (created_at);
CREATE INDEX IF NOT EXISTS last_mile_shipping_info_id_idx ON "last_mile_shipping_info" (id);
CREATE INDEX IF NOT EXISTS last_mile_shipping_info_merchant_id_idx ON "last_mile_shipping_info" (merchant_id);
CREATE INDEX IF NOT EXISTS last_mile_shipping_info_updated_at_idx ON "last_mile_shipping_info" (updated_at);
CREATE TABLE IF NOT EXISTS lastmile_status (
	id integer NOT NULL
	code text
	description text
);
CREATE TABLE IF NOT EXISTS logistic_partner (
	code TEXT PRIMARY
	name TEXT NOT NULL
	description TEXT
);
CREATE TABLE IF NOT EXISTS mawb (
	id bigint NOT NULL
	code text
	mode_of_transport text
	agent_iata_code text
);
CREATE TABLE IF NOT EXISTS merchant (
	id bigint NOT NULL
	code text
	created_at timestamp
	updated_at timestamp
	deleted_at timestamp
	disabled_at timestamp
	name text NOT NULL
	email text NOT NULL
	phone text NOT NULL
	address text
	avatar text
	refcode text
	admin_id bigint
	province text
	province_name text
	district text
	district_name text
	ward text
	ward_name text
	birthday timestamp
	gender smallint
	active boolean
	country text
	is_cbe boolean
	type text
);
CREATE TABLE IF NOT EXISTS merchant_contract (
	id bigint NOT NULL
	merchant_code text
	tax_id text
	company_name text
	company_address text
	company_register_at text
	company_representor text
	company_representor_position text
	verify_state text
	term_state text
	ic_number text
	ic_fullname text
	ic_birthday_at timestamp
	ic_place_of_permanent text
	ic_issuance_at timestamp
	ic_issuance_place text
	ic_front_image text
	ic_back_image text
	user_id bigint NOT NULL
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
);
CREATE INDEX IF NOT EXISTS merchant_contract_created_at ON "merchant_contract" (created_at);
CREATE INDEX IF NOT EXISTS merchant_contract_id ON "merchant_contract" (id);
CREATE INDEX IF NOT EXISTS merchant_contract_merchant_code ON "merchant_contract" (merchant_code);
CREATE INDEX IF NOT EXISTS merchant_contract_term_state ON "merchant_contract" (term_state);
CREATE INDEX IF NOT EXISTS merchant_contract_updated_at ON "merchant_contract" (updated_at);
CREATE INDEX IF NOT EXISTS merchant_contract_user_id ON "merchant_contract" (user_id);
CREATE INDEX IF NOT EXISTS merchant_contract_verify_state ON "merchant_contract" (verify_state);
CREATE TABLE IF NOT EXISTS merchant_contract_history (
	id bigint NOT NULL
	merchant_contract_id bigint NOT NULL
	verify_state text
	term_state text
	changes text NOT NULL
	user_id bigint NOT NULL
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS merchant_order (
	id bigint NOT NULL
	code text
	flow text
	state text NOT NULL
	state_final smallint NOT NULL
	created_at timestamp
	updated_at timestamp
	cancelled_at timestamp
	created_by_admin_id bigint
	merchant_id bigint NOT NULL
	merchant text
	note_admin text
	note_cancel text
	note_order text
	note_shipping text
	coupon_code text
	cod_amount_vnd integer
	is_test smallint
	note_admin_merchant text
	supplier_tracking_number text
	supplier_order_number text
	action_admin_id bigint
	rid bigint
	supplier_courier text
	platform text
	country text
	invoice_link text
	use_insurance boolean
	supplier_coupon_code text
	first_mile_method text
	last_mile_method text
	last_mile_shipping_info_id bigint
	merchant_plan_id bigint
	is_cbe boolean
	cbe_order_date timestamp
	cbe_consignee_id bigint
	seller_id bigint
	estimated_delivery_date timestamp
	merchant_type text
	sorting_code text
	customs_invoice_no text
	customs_invoice_date timestamp
	customs_invoice_link text
	customs_po_no text
	customs_po_date timestamp
	customs_po_link text
	customs_co_link text
	customs_cq_link text
	customs_import_duty text
	customs_vat bigint
	customs_note text
	customs_hbl_no text
	customs_mbl_no text
	departure_date timestamp
	truck_no text
	letter_of_authorization text
	delivery_order_no text
	customs_declaration_no text
	invoice_value_vnd integer
	need_paying boolean
);
CREATE INDEX IF NOT EXISTS merchant_order_cancelled_at_idx ON "merchant_order" (cancelled_at);
CREATE INDEX IF NOT EXISTS merchant_order_country_idx ON "merchant_order" (country);
CREATE INDEX IF NOT EXISTS merchant_order_created_at_idx ON "merchant_order" (created_at);
CREATE INDEX IF NOT EXISTS merchant_order_merchant_id_idx ON "merchant_order" (merchant_id);
CREATE INDEX IF NOT EXISTS merchant_order_merchant_idx ON "merchant_order" (merchant);
CREATE INDEX IF NOT EXISTS merchant_order_platform ON "merchant_order" (platform);
CREATE INDEX IF NOT EXISTS merchant_order_rid_idx ON "merchant_order" (rid);
CREATE INDEX IF NOT EXISTS merchant_order_state_final_idx ON "merchant_order" (state_final);
CREATE INDEX IF NOT EXISTS merchant_order_state_idx ON "merchant_order" (state);
CREATE INDEX IF NOT EXISTS merchant_order_supplier_order_number_idx ON "merchant_order" (supplier_order_number);
CREATE INDEX IF NOT EXISTS merchant_order_supplier_tracking_number_idx ON "merchant_order" (supplier_tracking_number);
CREATE INDEX IF NOT EXISTS merchant_order_updated_at_idx ON "merchant_order" (updated_at);
CREATE TABLE IF NOT EXISTS merchant_order_history (
	merchant_order_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	prev_state text
	curr_state text NOT NULL
	state_final smallint NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS merchant_order_history_merchant_order_id_idx ON "merchant_order_history" (merchant_order_id);
CREATE INDEX IF NOT EXISTS merchant_order_history_revision_idx ON "merchant_order_history" (revision);
CREATE TABLE IF NOT EXISTS merchant_plan (
	id bigint NOT NULL
	merchant_id bigint
	merchant text
	admin_id bigint
	plan_id bigint
	plan_name text
	mark_paid_by_admin_id bigint
	cancelled_by_admin_id bigint
	created_at timestamp
	updated_at timestamp
	started_at timestamp
	expired_at timestamp
	paid_at timestamp
	disabled_at timestamp
	cancelled_at timestamp
	closed_at timestamp
	max_weight integer
	used_weight integer
	est_used_weight integer
	note text
	is_upgraded boolean
	upgrade_from_plan_id bigint
	upgrade_from_plan_name text
	is_renewal boolean
	is_fallback boolean
	fallback_from_plan_id bigint
	fallback_from_plan_name text
	status boolean
	state smallint
);
CREATE INDEX IF NOT EXISTS merchant_plan_created_at_idx ON "merchant_plan" (created_at);
CREATE INDEX IF NOT EXISTS merchant_plan_expired_at_idx ON "merchant_plan" (expired_at);
CREATE INDEX IF NOT EXISTS merchant_plan_fallback_from_plan_id_idx ON "merchant_plan" (fallback_from_plan_id);
CREATE INDEX IF NOT EXISTS merchant_plan_fallback_from_plan_name_idx ON "merchant_plan" (fallback_from_plan_name);
CREATE INDEX IF NOT EXISTS merchant_plan_is_fallback_idx ON "merchant_plan" (is_fallback);
CREATE INDEX IF NOT EXISTS merchant_plan_is_renewal_idx ON "merchant_plan" (is_renewal);
CREATE INDEX IF NOT EXISTS merchant_plan_merchant_id_idx ON "merchant_plan" (merchant_id);
CREATE INDEX IF NOT EXISTS merchant_plan_merchant_idx ON "merchant_plan" (merchant);
CREATE INDEX IF NOT EXISTS merchant_plan_plan_id_idx ON "merchant_plan" (plan_id);
CREATE INDEX IF NOT EXISTS merchant_plan_plan_name_idx ON "merchant_plan" (plan_name);
CREATE INDEX IF NOT EXISTS merchant_plan_started_at_idx ON "merchant_plan" (started_at);
CREATE INDEX IF NOT EXISTS merchant_plan_status_idx ON "merchant_plan" (status);
CREATE INDEX IF NOT EXISTS merchant_plan_updated_at_idx ON "merchant_plan" (updated_at);
CREATE TABLE IF NOT EXISTS merchant_plan_order (
	merchant_plan_id bigint
	plan_id bigint
	merchant_order_id bigint
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS merchant_plan_order_merchant_order_id ON "merchant_plan_order" (merchant_order_id);
CREATE INDEX IF NOT EXISTS merchant_plan_order_merchant_plan_id ON "merchant_plan_order" (merchant_plan_id);
CREATE INDEX IF NOT EXISTS merchant_plan_order_plan_id ON "merchant_plan_order" (plan_id);
CREATE INDEX IF NOT EXISTS merchant_plan_order_updated_at ON "merchant_plan_order" (updated_at);
CREATE TABLE IF NOT EXISTS notes (
	id bigint NOT NULL
	type text
	code text
	note text
	created_at timestamp
);
CREATE INDEX IF NOT EXISTS note_code ON "notes" (code);
CREATE INDEX IF NOT EXISTS INDEX ON "notes" (ode);
CREATE TABLE IF NOT EXISTS order_item (
	id bigint NOT NULL
	gcode text
	gscode text
	flow text
	state text NOT NULL
	state_final smallint NOT NULL
	created_at timestamp
	updated_at timestamp
	cancelled_at timestamp
	merchant_order_id bigint NOT NULL
	warehouse text
	note_admin text
	note_cancel text
	real_weight integer
	supplier_courier text
	supplier_price_x integer
	supplier_tracking_number text
	forwarding_agent text
	is_test smallint
	product_name text
	action_admin_id bigint
	rid bigint
	customs_broker_agent text
	last_mile_provider text
	last_mile_code text
	sku text
	last_mile_status text
	wh_inventory_item_id bigint
	parcel_id bigint
	weight integer
	vnhub_parcel_id bigint
	product_id bigint
	sorting_code text
	tracking_number_id bigint
	package_info_id bigint
);
CREATE INDEX IF NOT EXISTS order_item_cancelled_at_idx ON "order_item" (cancelled_at);
CREATE INDEX IF NOT EXISTS order_item_created_at_idx ON "order_item" (created_at);
CREATE INDEX IF NOT EXISTS order_item_f4parcel_id_idx ON "order_item" (vnhub_parcel_id);
CREATE INDEX IF NOT EXISTS order_item_gscode_idx ON "order_item" (gscode);
CREATE INDEX IF NOT EXISTS order_item_parcel_id_idx ON "order_item" (parcel_id);
CREATE INDEX IF NOT EXISTS order_item_rid_idx ON "order_item" (rid);
CREATE INDEX IF NOT EXISTS order_item_sku_idx ON "order_item" (sku);
CREATE INDEX IF NOT EXISTS order_item_state_final_idx ON "order_item" (state_final);
CREATE INDEX IF NOT EXISTS order_item_state_idx ON "order_item" (state);
CREATE INDEX IF NOT EXISTS order_item_supplier_tracking_number_idx ON "order_item" (supplier_tracking_number);
CREATE INDEX IF NOT EXISTS order_item_updated_at_idx ON "order_item" (updated_at);
CREATE INDEX IF NOT EXISTS order_item_warehouse_idx ON "order_item" (warehouse);
CREATE INDEX IF NOT EXISTS order_merchant_order_id_idx ON "order_item" (merchant_order_id);
CREATE TABLE IF NOT EXISTS order_item_history (
	order_item_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	prev_state text
	curr_state text NOT NULL
	state_final smallint NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS order_item_history_order_item_id_idx ON "order_item_history" (order_item_id);
CREATE INDEX IF NOT EXISTS order_item_history_revision_idx ON "order_item_history" (revision);
CREATE TABLE IF NOT EXISTS order_price (
	order_id bigint NOT NULL
	pricing_version bigint
	est_basket_value_x integer
	basket_value_x integer
	us_tax_x integer
	us_shipping_fee_x integer
	purchasing_fee_x integer
	surcharge_x integer
	insurance_fee_x integer
	last_mile_fee_vnd integer
	gido_fee_x integer
	total_fee_x integer
	total_amount_x integer
	discount_vnd integer
	total_amount_before_discount_vnd integer
	total_amount_after_discount_vnd integer
	exchange_rate integer
	chargeable_weight integer
	extra_amount_vnd integer
	extra_chargeable_weight integer
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint
	rid bigint
	total_gifts_fee_x integer
	transport_fee bigint
	customs_fee bigint
	pricing_config_id bigint
	transportation_fee_value bigint
	id bigint NOT NULL
	type text
	profit_margin bigint
	cost_of_sale bigint
	chargeable_distance integer
);
CREATE INDEX IF NOT EXISTS order_price_created_at_idx ON "order_price" (created_at);
CREATE INDEX IF NOT EXISTS INDEX ON "order_price" (id);
CREATE INDEX IF NOT EXISTS order_price_order_id_idx ON "order_price" (order_id);
CREATE INDEX IF NOT EXISTS order_price_updated_at_idx ON "order_price" (updated_at);
CREATE TABLE IF NOT EXISTS order_price_history (
	order_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS order_price_history_revision_idx ON "order_price_history" (revision);
CREATE TABLE IF NOT EXISTS order_price_new (
	order_id bigint
	pricing_version bigint
	est_basket_value_x integer
	basket_value_x integer
	us_tax_x integer
	us_shipping_fee_x integer
	purchasing_fee_x integer
	surcharge_x integer
	insurance_fee_x integer
	last_mile_fee_vnd integer
	gido_fee_x integer
	total_fee_x integer
	total_amount_x integer
	discount_vnd integer
	total_amount_before_discount_vnd integer
	total_amount_after_discount_vnd integer
	exchange_rate integer
	chargeable_weight integer
	extra_amount_vnd integer
	extra_chargeable_weight integer
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint
	rid bigint
	total_gifts_fee_x integer
	transport_fee bigint
	customs_fee bigint
	pricing_config_id bigint
	transportation_fee_value bigint
	id bigint NOT NULL
);
CREATE TABLE IF NOT EXISTS order_price_service (
	id bigint NOT NULL
	order_price_id bigint NOT NULL
	value bigint NOT NULL
	created_at timestamp
	updated_at timestamp
	service_id bigint
);
CREATE INDEX IF NOT EXISTS order_price_service_order_price_id_idx ON "order_price_service" (order_price_id);
CREATE INDEX IF NOT EXISTS INDEX ON "order_price_service" (id);
CREATE TABLE IF NOT EXISTS order_price_transportation_fee (
	order_price_id bigint NOT NULL
	transportation_fee_id bigint NOT NULL
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
	service_type text NOT NULL
	value bigint NOT NULL
	chargeable_weight bigint NOT NULL
	service_id bigint NOT NULL
	id bigint NOT NULL
);
CREATE INDEX IF NOT EXISTS fkIdx_194 ON "order_price_transportation_fee" (order_price_id);
CREATE INDEX IF NOT EXISTS fkIdx_203 ON "order_price_transportation_fee" (transportation_fee_id);
CREATE TABLE IF NOT EXISTS order_service (
	id bigint NOT NULL
	merchant_order_id bigint NOT NULL
	service_id bigint NOT NULL
	created_at timestamp
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS INDEX ON "order_service" (id);
CREATE INDEX IF NOT EXISTS fkIdx_231 ON "order_service" (merchant_order_id);
CREATE INDEX IF NOT EXISTS fkIdx_241 ON "order_service" (service_id);
CREATE TABLE IF NOT EXISTS package_info (
	id bigint NOT NULL
	merchant_order_id bigint
	length integer
	height integer
	width integer
	weight integer
	dimension_weight integer
	created_at timestamp
	updated_at timestamp
	tracking_id bigint
	state text
	tracking_number text
	merchant_id bigint
	order_code text
	state_final integer
	rid bigint
	action_admin_id bigint
	actual_weight bigint
);
CREATE INDEX IF NOT EXISTS package_info_created_at_idx ON "package_info" (created_at);
CREATE INDEX IF NOT EXISTS package_info_id_idx ON "package_info" (id);
CREATE INDEX IF NOT EXISTS package_info_merchant_order_id_idx ON "package_info" (merchant_order_id);
CREATE INDEX IF NOT EXISTS package_info_rid_idx ON "package_info" (rid);
CREATE INDEX IF NOT EXISTS package_info_updated_at_idx ON "package_info" (updated_at);
CREATE TABLE IF NOT EXISTS package_info_history (
	package_info_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	prev_tracking text
	curr_tracking text NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS package_info_history_revision_idx ON "package_info_history" (revision);
CREATE TABLE IF NOT EXISTS pagent (
	id bigint NOT NULL
	code text
	created_at timestamp
	updated_at timestamp
	deleted_at timestamp
	disabled_at timestamp
	name text NOT NULL
	email text NOT NULL
	phone text NOT NULL
	address text
	avatar text
	commission_percent double
);
CREATE TABLE IF NOT EXISTS pagent_order (
	id bigint NOT NULL
	merchant_order_id bigint
	code text
	pagent_id bigint
	warehouse text
	total_amount_x integer
	discount_x integer
	supplier_price_x integer
	shipping_fee_x integer
	tax_x integer
	currency text
	exchange_rate integer
	commission_percent smallint
	commission_x integer
	supplier_order_number text
	supplier_courier text
	supplier_tracking_number text
	est_delivery_xx_at timestamp
	state text
	state_final smallint
	purchased_at timestamp
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint
	rid bigint
	basket_value_x integer
);
CREATE INDEX IF NOT EXISTS pagent_order_code_idx ON "pagent_order" (code);
CREATE INDEX IF NOT EXISTS pagent_order_created_at_idx ON "pagent_order" (created_at);
CREATE INDEX IF NOT EXISTS pagent_order_id_idx ON "pagent_order" (id);
CREATE INDEX IF NOT EXISTS pagent_order_merchant_order_id_idx ON "pagent_order" (merchant_order_id);
CREATE INDEX IF NOT EXISTS pagent_order_pagent_id_idx ON "pagent_order" (pagent_id);
CREATE INDEX IF NOT EXISTS pagent_order_state_final_idx ON "pagent_order" (state_final);
CREATE INDEX IF NOT EXISTS pagent_order_state_idx ON "pagent_order" (state);
CREATE INDEX IF NOT EXISTS pagent_order_updated_at_idx ON "pagent_order" (updated_at);
CREATE INDEX IF NOT EXISTS pagent_order_warehouse_idx ON "pagent_order" (warehouse);
CREATE TABLE IF NOT EXISTS pagent_order_history (
	revision bigint
	pagent_order_id bigint
	prev_state text
	curr_state text
	state_final text
	changes jsonb
	user_id bigint
	updated_at timestamp NOT NULL
);
CREATE INDEX IF NOT EXISTS pagent_order_history_curr_state_idx ON "pagent_order_history" (curr_state);
CREATE INDEX IF NOT EXISTS pagent_order_history_pagent_order_id_idx ON "pagent_order_history" (pagent_order_id);
CREATE INDEX IF NOT EXISTS pagent_order_history_prev_state_idx ON "pagent_order_history" (prev_state);
CREATE INDEX IF NOT EXISTS pagent_order_history_revision_idx ON "pagent_order_history" (revision);
CREATE INDEX IF NOT EXISTS pagent_order_history_state_final_idx ON "pagent_order_history" (state_final);
CREATE INDEX IF NOT EXISTS pagent_order_history_updated_at_idx ON "pagent_order_history" (updated_at);
CREATE INDEX IF NOT EXISTS pagent_order_history_user_id_idx ON "pagent_order_history" (user_id);
CREATE TABLE IF NOT EXISTS pagent_receipt (
	id bigint NOT NULL
	pagent_id bigint
	admin_id bigint
	created_at timestamp
	receipt_at timestamp
	pagent_purchasing_amount_x integer
	commission_percent smallint
	commission_amount_x integer
	commission_amount_vnd integer
	exchange_rate integer
	note_purchase_commission text
);
CREATE TABLE IF NOT EXISTS parcel (
	id bigint NOT NULL
	code text
	description text
	box_id bigint
	warehouse text
	shipper_name text
	shipper_address text
	shipper_country text
	shipper_tel text
	consignee_name text
	consignee_address text
	consignee_country text
	consignee_tel text
	consignee_checksum text
	gross_weight integer
	number_of_package integer
	value integer
	quantity integer
	created_at timestamp
	updated_at timestamp
	active boolean
	state text
	action_admin_id bigint
	rid bigint
	real_weight integer
	note text
	dest_warehouse text
	consignee_ward integer
	consignee_district integer
	consignee_province integer
	last_mile_booking_id bigint
	location bigint
	weight integer
	sorting_code text
	parcel_type text
	sensitive boolean
	vnhub_box_id bigint
	last_mile_status text
	num_deliver integer
	num_contact integer
	num_re_attempt integer
	last_mile_shipping_info_id bigint
	cod_amount integer
	actual_cod_amount integer
);
CREATE INDEX IF NOT EXISTS order_item_sorting_code_idx ON "parcel" (sorting_code);
CREATE INDEX IF NOT EXISTS parcel_active_idx ON "parcel" (active);
CREATE INDEX IF NOT EXISTS parcel_box_id_idx ON "parcel" (box_id);
CREATE INDEX IF NOT EXISTS INDEX ON "parcel" (code);
CREATE INDEX IF NOT EXISTS parcel_consignee_checksum_idx ON "parcel" (consignee_checksum);
CREATE INDEX IF NOT EXISTS parcel_created_at_idx ON "parcel" (created_at);
CREATE INDEX IF NOT EXISTS parcel_last_mile_booking_idx ON "parcel" (last_mile_booking_id);
CREATE INDEX IF NOT EXISTS parcel_parcel_type_idx ON "parcel" (parcel_type);
CREATE INDEX IF NOT EXISTS parcel_rid_idx ON "parcel" (rid);
CREATE INDEX IF NOT EXISTS parcel_sensitive_idx ON "parcel" (sensitive);
CREATE INDEX IF NOT EXISTS parcel_sorting_code_idx ON "parcel" (sorting_code);
CREATE INDEX IF NOT EXISTS parcel_updated_at_idx ON "parcel" (updated_at);
CREATE INDEX IF NOT EXISTS parcel_warehouse_idx ON "parcel" (warehouse);
CREATE INDEX IF NOT EXISTS vnhub_box_idx ON "parcel" (vnhub_box_id);
CREATE TABLE IF NOT EXISTS parcel_history (
	parcel_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	prev_state text
	curr_state text NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS parcel_history_revision_idx ON "parcel_history" (revision);
CREATE TABLE IF NOT EXISTS parcel_item (
	parcel_id bigint
	wh_inventory_item_id bigint
	quantity integer
	sku text
	supplier_tracking_number text
	created_at timestamp
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS parcel_item_created_at_idx ON "parcel_item" (created_at);
CREATE INDEX IF NOT EXISTS parcel_item_parcel_id_idx ON "parcel_item" (parcel_id);
CREATE INDEX IF NOT EXISTS parcel_item_updated_at_idx ON "parcel_item" (updated_at);
CREATE INDEX IF NOT EXISTS parcel_item_wh_inventory_item_id_idx ON "parcel_item" (wh_inventory_item_id);
CREATE TABLE IF NOT EXISTS payment_history (
	id bigint NOT NULL
	merchant_order_id bigint NOT NULL
	wallet_transaction_id bigint NOT NULL
	value_vnd double NOT NULL
	type text NOT NULL
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
);
CREATE TABLE IF NOT EXISTS payment_type (
	id bigint NOT NULL
	code text
	description text
);
CREATE TABLE IF NOT EXISTS plan (
	id bigint NOT NULL
	name text
	description text
	max_weight integer
	period smallint
	shipping_price_per_weight_x integer
	purchasing_price_percent integer
	created_at timestamp
	updated_at timestamp
	disabled_at timestamp
	status boolean
	rid bigint
	action_admin_id bigint
);
CREATE INDEX IF NOT EXISTS plan_created_at_idx ON "plan" (created_at);
CREATE INDEX IF NOT EXISTS INDEX ON "plan" (name);
CREATE INDEX IF NOT EXISTS plan_rid_idx ON "plan" (rid);
CREATE INDEX IF NOT EXISTS plan_status_idx ON "plan" (status);
CREATE INDEX IF NOT EXISTS plan_updated_at_idx ON "plan" (updated_at);
CREATE TABLE IF NOT EXISTS plan_history (
	plan_id bigint NOT NULL
	revision bigint NOT NULL
	updated_at timestamp NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS plan_history_revision_idx ON "plan_history" (revision);
CREATE TABLE IF NOT EXISTS pricing_config (
	id bigint NOT NULL
	price_per_item_x integer
	price_per_weight_x integer
	insurance_fee_percent integer
	purchasing_fee_percent integer
	exchange_rate integer
	plan_id bigint
	country text
	currency text
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint
	rid bigint
	active boolean
	category text
	cost_of_sale_percent double
	profit_margin_percent double
);
CREATE INDEX IF NOT EXISTS pricing_config_action_admin_id_idx ON "pricing_config" (action_admin_id);
CREATE INDEX IF NOT EXISTS pricing_config_active_idx ON "pricing_config" (active);
CREATE INDEX IF NOT EXISTS pricing_config_category_idx ON "pricing_config" (category);
CREATE INDEX IF NOT EXISTS pricing_config_country_idx ON "pricing_config" (country);
CREATE INDEX IF NOT EXISTS pricing_config_created_at_idx ON "pricing_config" (created_at);
CREATE INDEX IF NOT EXISTS pricing_config_id_idx ON "pricing_config" (id);
CREATE INDEX IF NOT EXISTS pricing_config_plan_id_idx ON "pricing_config" (plan_id);
CREATE INDEX IF NOT EXISTS pricing_config_updated_at_idx ON "pricing_config" (updated_at);
CREATE TABLE IF NOT EXISTS pricing_config_history (
	pricing_config_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS pricing_config_history_revision_idx ON "pricing_config_history" (revision);
CREATE TABLE IF NOT EXISTS pricing_config_service (
	id bigint NOT NULL
	pricing_config_id bigint
	service_fee_id bigint
	active boolean
	created_at timestamp
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS product (
	id bigint NOT NULL
	merchant_order_id bigint
	sku text
	name text
	category text
	link text NOT NULL
	price_x integer
	currency text
	gift boolean
	number_of_set integer
	item_in_set integer
	package_info_id bigint
	unit_weight integer
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint
	description text
	name_en text
	name_kr text
	name_cn text
	brand text
	image text
);
CREATE INDEX IF NOT EXISTS product_category_idx ON "product" (category);
CREATE INDEX IF NOT EXISTS product_created_at_idx ON "product" (created_at);
CREATE INDEX IF NOT EXISTS product_gift_idx ON "product" (gift);
CREATE INDEX IF NOT EXISTS product_id_idx ON "product" (id);
CREATE INDEX IF NOT EXISTS product_merchant_order_id_idx ON "product" (merchant_order_id);
CREATE INDEX IF NOT EXISTS product_package_info_id_idx ON "product" (package_info_id);
CREATE INDEX IF NOT EXISTS product_sku_idx ON "product" (sku);
CREATE INDEX IF NOT EXISTS product_updated_at_idx ON "product" (updated_at);
CREATE TABLE IF NOT EXISTS product_attribute (
	id bigint NOT NULL
	product_id bigint
	attribute_id bigint
	value text
	created_at timestamp
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS product_attribute_attribute_id_idx ON "product_attribute" (attribute_id);
CREATE INDEX IF NOT EXISTS product_attribute_created_at_idx ON "product_attribute" (created_at);
CREATE INDEX IF NOT EXISTS product_attribute_id_idx ON "product_attribute" (id);
CREATE INDEX IF NOT EXISTS product_attribute_product_id_idx ON "product_attribute" (product_id);
CREATE INDEX IF NOT EXISTS product_attribute_updated_at_idx ON "product_attribute" (updated_at);
CREATE INDEX IF NOT EXISTS product_attribute_value_idx ON "product_attribute" (value);
CREATE TABLE IF NOT EXISTS province (
	code text NOT NULL
	name text NOT NULL
	country text NOT NULL
	created_at timestamp
	updated_at timestamp
	sorting_code text
);
CREATE INDEX IF NOT EXISTS province_code_idx ON "province" (code);
CREATE INDEX IF NOT EXISTS province_country_code_idx ON "province" (country);
CREATE INDEX IF NOT EXISTS province_sorting_code_idx ON "province" (sorting_code);
CREATE TABLE IF NOT EXISTS quotation (
	id bigint NOT NULL
	etd text
	leadtime integer
	doc_cut_off integer
	goods_cut_off integer
	f_agent text
	carrier text
	currency text
	valid_date date
	expired_date date
	state text
);
CREATE TABLE IF NOT EXISTS quotation_charge (
	id bigint NOT NULL
	range integer
	price integer
	quotation_id bigint
);
CREATE TABLE IF NOT EXISTS receipt (
	id bigint NOT NULL
	code text
	type text
	vendor_id bigint
	sender_name text
	sender_phone text
	warehouse text
	status text
	total_amount bigint
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint
);
CREATE INDEX IF NOT EXISTS receipt_code ON "receipt" (code);
CREATE TABLE IF NOT EXISTS receipt_detail (
	id bigint NOT NULL
	receipt_id bigint
	parcel_id bigint
	booking_id bigint
	amount bigint
	created_at timestamp
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS booking_id_idx ON "receipt_detail" (booking_id);
CREATE INDEX IF NOT EXISTS parcel_id_idx ON "receipt_detail" (parcel_id);
CREATE INDEX IF NOT EXISTS receipt_detail_receipt_idx ON "receipt_detail" (receipt_id);
CREATE TABLE IF NOT EXISTS role (
	id bigint NOT NULL
	name text NOT NULL
	created_at timestamp
	updated_at timestamp
	deleted_at timestamp
);
CREATE TABLE IF NOT EXISTS seller (
	id bigint NOT NULL
	name text NOT NULL
	merchant_id bigint
	tax text NOT NULL
	address text NOT NULL
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint
	phone text
);
CREATE TABLE IF NOT EXISTS service (
	id bigint NOT NULL
	name text NOT NULL
	code text NOT NULL
	description text NOT NULL
	service_type text
	active boolean
	updated_at date
	action_admin_id text
);
CREATE INDEX IF NOT EXISTS INDEX ON "service" (id);
CREATE TABLE IF NOT EXISTS service_fee (
	id bigint NOT NULL
	name text NOT NULL
	code text NOT NULL
	description text NOT NULL
	fee bigint NOT NULL
	lower_threshold integer NOT NULL
	upper_threshold integer NOT NULL
	unit text NOT NULL
	active boolean
	created_at timestamp
	updated_at timestamp
	unit_fee text
	service_id bigint
	country text
	action_admin_id text
);
CREATE INDEX IF NOT EXISTS INDEX ON "service_fee" (id);
CREATE TABLE IF NOT EXISTS shipping_instruction (
	id bigint NOT NULL
	mawb_id bigint
	booking_id bigint
	shipper_name text
	f_agent text
	f_consignee text
);
CREATE TABLE IF NOT EXISTS sku (
	id bigint
	sku text
	title text
	description text
	brand text
	model text
	asin text
	gtin text
	size text
	color text
	dimension text
	weight text
	images text[]
	created_at timestamp
	updated_at timestamp
	source text
	sensitive boolean
);
CREATE INDEX IF NOT EXISTS sku_asin_idx ON "sku" (asin);
CREATE INDEX IF NOT EXISTS sku_created_at_idx ON "sku" (created_at);
CREATE INDEX IF NOT EXISTS INDEX ON "sku" (id);
CREATE INDEX IF NOT EXISTS sku_sensitive_idx ON "sku" (sensitive);
CREATE INDEX IF NOT EXISTS INDEX ON "sku" (sku);
CREATE INDEX IF NOT EXISTS sku_source_idx ON "sku" (source);
CREATE INDEX IF NOT EXISTS sku_updated_at_idx ON "sku" (updated_at);
CREATE TABLE IF NOT EXISTS stock_box (
	id bigint NOT NULL
	stock_request_number text
	stock_request_id bigint
	warehouse text
	code text
	length integer
	width integer
	height integer
	state text
	state_final smallint
	action_admin_id bigint
	created_at timestamp
	updated_at timestamp
	cancelled_at timestamp
	weight bigint
);
CREATE INDEX IF NOT EXISTS stock_box_code_idx ON "stock_box" (code);
CREATE INDEX IF NOT EXISTS stock_box_created_at_idx ON "stock_box" (created_at);
CREATE INDEX IF NOT EXISTS stock_box_id_idx ON "stock_box" (id);
CREATE INDEX IF NOT EXISTS stock_box_state_final_idx ON "stock_box" (state_final);
CREATE INDEX IF NOT EXISTS stock_box_state_idx ON "stock_box" (state);
CREATE INDEX IF NOT EXISTS stock_box_stock_request_number_idx ON "stock_box" (stock_request_number);
CREATE INDEX IF NOT EXISTS stock_box_updated_at_idx ON "stock_box" (updated_at);
CREATE INDEX IF NOT EXISTS stock_box_warehouse_idx ON "stock_box" (warehouse);
CREATE TABLE IF NOT EXISTS stock_item (
	id bigint NOT NULL
	stock_request_number text
	stock_request_id bigint
	merchant_id bigint
	merchant_code text
	type text
	code text
	title text
	unit_of_measurement text
	quantity integer
	warehouse text
	state text
	state_final smallint
	action_admin_id bigint
	created_at timestamp
	updated_at timestamp
	cancelled_at timestamp
);
CREATE INDEX IF NOT EXISTS stock_item_code_idx ON "stock_item" (code);
CREATE INDEX IF NOT EXISTS stock_item_created_at_idx ON "stock_item" (created_at);
CREATE INDEX IF NOT EXISTS stock_item_id_idx ON "stock_item" (id);
CREATE INDEX IF NOT EXISTS stock_item_state_final_idx ON "stock_item" (state_final);
CREATE INDEX IF NOT EXISTS stock_item_state_idx ON "stock_item" (state);
CREATE INDEX IF NOT EXISTS stock_item_stock_request_number_idx ON "stock_item" (stock_request_number);
CREATE INDEX IF NOT EXISTS stock_item_updated_at_idx ON "stock_item" (updated_at);
CREATE INDEX IF NOT EXISTS stock_item_warehouse_idx ON "stock_item" (warehouse);
CREATE TABLE IF NOT EXISTS stock_request (
	id bigint NOT NULL
	stock_request_number text
	merchant_id bigint
	type text
	estimated_delivery_date timestamp
	actual_delivery_date timestamp
	stock_location text
	warehouse text
	total_number_of_boxes integer
	total_volume bigint
	total_weight bigint
	country text
	pickup_request boolean
	contact_name text
	contact_address text
	contact_phone text
	state text
	state_final smallint
	action_admin_id bigint
	created_at timestamp
	updated_at timestamp
	cancelled_at timestamp
	tracking_number text
);
CREATE INDEX IF NOT EXISTS stock_request_created_at_idx ON "stock_request" (created_at);
CREATE INDEX IF NOT EXISTS stock_request_id_idx ON "stock_request" (id);
CREATE INDEX IF NOT EXISTS stock_request_merchant_id_idx ON "stock_request" (merchant_id);
CREATE INDEX IF NOT EXISTS stock_request_number_idx ON "stock_request" (stock_request_number);
CREATE INDEX IF NOT EXISTS stock_request_pickup_request_idx ON "stock_request" (pickup_request);
CREATE INDEX IF NOT EXISTS stock_request_state_final_idx ON "stock_request" (state_final);
CREATE INDEX IF NOT EXISTS stock_request_state_idx ON "stock_request" (state);
CREATE INDEX IF NOT EXISTS stock_request_updated_at_idx ON "stock_request" (updated_at);
CREATE INDEX IF NOT EXISTS stock_request_warehouse_idx ON "stock_request" (warehouse);
CREATE TABLE IF NOT EXISTS supplier (
	code text NOT NULL
	name text NOT NULL
	description text
);
CREATE TABLE IF NOT EXISTS surcharge (
	id bigint
	category text
	min_item_price integer
	min_surcharge integer
	surcharge_percent integer
	is_vip boolean
	surcharge_type smallint
	value integer
	box_weight integer
	action_admin_id bigint
	rid bigint
	created_at timestamp
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS INDEX ON "surcharge" (category);
CREATE INDEX IF NOT EXISTS surcharge_id_idx ON "surcharge" (id);
CREATE INDEX IF NOT EXISTS surcharge_is_vip_idx ON "surcharge" (is_vip);
CREATE INDEX IF NOT EXISTS surcharge_rid_idx ON "surcharge" (rid);
CREATE INDEX IF NOT EXISTS surcharge_surcharge_type_idx ON "surcharge" (surcharge_type);
CREATE TABLE IF NOT EXISTS surcharge_history (
	id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS surcharge_history_revision_idx ON "surcharge_history" (revision);
CREATE TABLE IF NOT EXISTS tracking_merchant_order_rel (
	merchant_order_id bigint NOT NULL
	tracking_id bigint NOT NULL
	no_packages integer
);
CREATE TABLE IF NOT EXISTS tracking_number (
	id bigint NOT NULL
	code text
	action_admin_id bigint
	created_at timestamp
	updated_at timestamp
	deleted_at timestamp
	merchant_order_id bigint
	no_packages integer
	rid bigint
);
CREATE INDEX IF NOT EXISTS INDEX ON "tracking_number" (erchant_order_id);
CREATE INDEX IF NOT EXISTS INDEX ON "tracking_number" (erchant_order_id);
CREATE INDEX IF NOT EXISTS tracking_number_rid_idx ON "tracking_number" (rid);
CREATE TABLE IF NOT EXISTS tracking_number_history (
	tracking_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	prev_code text
	curr_code text NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS tracking_number_history_revision_idx ON "tracking_number_history" (revision);
CREATE TABLE IF NOT EXISTS transit_booking (
	id bigint NOT NULL
	booking_id bigint
	transit_no text
	carrier text
	port_of_loading text
	port_of_discharge text
	etd timestamp
	eta timestamp
	ata timestamp
	atd timestamp
	sequence integer
);
CREATE TABLE IF NOT EXISTS transit_booking_history (
	id bigint NOT NULL
	transit_booking_id bigint
	changes jsonb
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS transit_quotation (
	id bigint NOT NULL
	quotation_id bigint
	port_of_loading text
	port_of_discharge text
	sequence integer
);
CREATE TABLE IF NOT EXISTS transportation_fee (
	id bigint NOT NULL
	fee bigint NOT NULL
	remark text NOT NULL
	area text NOT NULL
	active boolean
	created_at timestamp
	updated_at timestamp
	service_id bigint
	origin text
	min_amount numeric(4,0)
	currency text
	lower_threshold integer
	upper_threshold integer
	unit text
	country_side_fee bigint
	action_admin_id text
	description text
);
CREATE INDEX IF NOT EXISTS INDEX ON "transportation_fee" (id);
CREATE TABLE IF NOT EXISTS transportation_fee_area (
	id bigint NOT NULL
	province text NOT NULL
	area text NOT NULL
	provider text NOT NULL
	transportation_fee_id bigint NOT NULL
	created_at timestamp NOT NULL
	updated_at timestamp
	active boolean
	action_admin_id text
	description text
);
CREATE INDEX IF NOT EXISTS fkidx_174 ON "transportation_fee_area" (transportation_fee_id);
CREATE INDEX IF NOT EXISTS INDEX ON "transportation_fee_area" (id);
CREATE TABLE IF NOT EXISTS user_fcm_token (
	user_id bigint
	token text
	access_token text
	platform text
	application text
	created_at timestamp
	updated_at timestamp
	disabled_at timestamp
);
CREATE INDEX IF NOT EXISTS user_fcm_access_token_token_idx ON "user_fcm_token" (access_token);
CREATE INDEX IF NOT EXISTS user_fcm_token_application_idx ON "user_fcm_token" (application);
CREATE INDEX IF NOT EXISTS user_fcm_token_created_at_idx ON "user_fcm_token" (created_at);
CREATE INDEX IF NOT EXISTS user_fcm_token_platform_idx ON "user_fcm_token" (platform);
CREATE INDEX IF NOT EXISTS INDEX ON "user_fcm_token" (token);
CREATE INDEX IF NOT EXISTS user_fcm_token_updated_at_idx ON "user_fcm_token" (updated_at);
CREATE INDEX IF NOT EXISTS user_fcm_token_user_id_idx ON "user_fcm_token" (user_id);
CREATE TABLE IF NOT EXISTS user_fcm_topic (
	user_id bigint
	topic_id text
	created_at timestamp
	updated_at timestamp
	disabled_at timestamp
);
CREATE INDEX IF NOT EXISTS user_fcm_topic_created_at_idx ON "user_fcm_topic" (created_at);
CREATE INDEX IF NOT EXISTS user_fcm_topic_disabled_at_idx ON "user_fcm_topic" (disabled_at);
CREATE INDEX IF NOT EXISTS user_fcm_topic_topic_id_idx ON "user_fcm_topic" (topic_id);
CREATE INDEX IF NOT EXISTS user_fcm_topic_updated_at_idx ON "user_fcm_topic" (updated_at);
CREATE INDEX IF NOT EXISTS user_fcm_topic_user_id_idx ON "user_fcm_topic" (user_id);
CREATE TABLE IF NOT EXISTS user_internal (
	user_id bigint NOT NULL
	user_type text
	hash_pwd text
);
CREATE TABLE IF NOT EXISTS user_users_group_rel (
	users_group_id bigint NOT NULL
	user_id bigint NOT NULL
);
CREATE TABLE IF NOT EXISTS users_group (
	id bigint NOT NULL
	code text
	description text
	rid bigint
	action_admin_id bigint NOT NULL
);
CREATE TABLE IF NOT EXISTS users_group_history (
	users_group_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS users_group_history_group_id_idx ON "users_group_history" (users_group_id);
CREATE TABLE IF NOT EXISTS vnhub_parcel (
	id bigint NOT NULL
	code text
	state text
	last_mile_status text
	num_deliver integer
	num_contact integer
	warehouse text
	dest_warehouse text
	last_mile_shipping_info_id bigint
	last_mile_booking_id bigint
	num_of_pack integer
	cod_amount integer
	sorting_code text
	parcel_type text
	weight integer
	dimensions text
	location bigint
	description text
	created_at timestamp
	updated_at timestamp
	action_admin_id bigint
	rid integer
	demensions text
	note text
	vnhub_box_id bigint
	num_re_attempt integer
);
CREATE TABLE IF NOT EXISTS vnhub_parcel_history (
	parcel_code text NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	prev_state text
	curr_state text NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS vnhub_parcel_history_code_idx ON "vnhub_parcel_history" (parcel_code);
CREATE INDEX IF NOT EXISTS vnhub_parcel_history_revision_idx ON "vnhub_parcel_history" (revision);
CREATE TABLE IF NOT EXISTS wallet (
	id bigint NOT NULL
	balance_vnd double NOT NULL
	merchant_id bigint NOT NULL
	merchant_code text NOT NULL
	merchant_name text NOT NULL
	user_id bigint
	status integer
	rid bigint
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
	wallet_transaction_id bigint
);
CREATE INDEX IF NOT EXISTS wallet_created_at_idx ON "wallet" (created_at);
CREATE INDEX IF NOT EXISTS wallet_merchant_id_idx ON "wallet" (merchant_id);
CREATE INDEX IF NOT EXISTS wallet_status_idx ON "wallet" (status);
CREATE INDEX IF NOT EXISTS wallet_updated_at_idx ON "wallet" (updated_at);
CREATE TABLE IF NOT EXISTS wallet_history (
	id bigint NOT NULL
	wallet_id bigint NOT NULL
	prev_balance double
	curr_balance double
	user_id bigint NOT NULL
	changes text NOT NULL
	revision bigint NOT NULL
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
	wallet_transaction_id bigint
);
CREATE TABLE IF NOT EXISTS wallet_transaction (
	id bigint NOT NULL
	value_vnd double NOT NULL
	actual_value_vnd double
	type text NOT NULL
	state text NOT NULL
	state_final integer NOT NULL
	merchant_order_code text
	merchant_code text
	merchant_name text
	merchant_id bigint NOT NULL
	merchant_order_id bigint
	note_admin text
	note_user text
	user_id bigint NOT NULL
	rid bigint
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
);
CREATE INDEX IF NOT EXISTS wallet_transaction_created_at_idx ON "wallet_transaction" (created_at);
CREATE INDEX IF NOT EXISTS wallet_transaction_merchant_id_idx ON "wallet_transaction" (merchant_id);
CREATE INDEX IF NOT EXISTS wallet_transaction_state_final_idx ON "wallet_transaction" (state_final);
CREATE INDEX IF NOT EXISTS wallet_transaction_state_idx ON "wallet_transaction" (state);
CREATE INDEX IF NOT EXISTS wallet_transaction_type_idx ON "wallet_transaction" (type);
CREATE TABLE IF NOT EXISTS wallet_transaction_history (
	id bigint NOT NULL
	wallet_transaction_id bigint NOT NULL
	revision bigint NOT NULL
	prev_state text
	curr_state text
	merchant_order_id bigint
	user_id bigint NOT NULL
	changes text NOT NULL
	mark_as_read integer
	read_at timestamp
	created_at timestamp NOT NULL
	updated_at timestamp NOT NULL
	merchant_id bigint
	state_final integer
	type text
);
CREATE TABLE IF NOT EXISTS ward (
	code text NOT NULL
	name text NOT NULL
	district integer NOT NULL
	created_at timestamp
	updated_at timestamp
	district_code integer
);
CREATE INDEX IF NOT EXISTS ward_code_idx ON "ward" (code);
CREATE INDEX IF NOT EXISTS ward_district_code_idx ON "ward" (district);
CREATE TABLE IF NOT EXISTS warehouse (
	code text NOT NULL
	name text NOT NULL
	description text
	address text
	ward text
	district text
	province text
	country text
	phone text
	consignee text
	created_at timestamp
	updated_at timestamp
	active boolean
	sorting_code text
);
CREATE INDEX IF NOT EXISTS warehouse_active_idx ON "warehouse" (active);
CREATE TABLE IF NOT EXISTS warehouse_user (
	id bigint NOT NULL
	warehouse text
	user_id bigint
	created_at timestamp
	updated_at timestamp
);
CREATE INDEX IF NOT EXISTS warehouse_user_created_at_idx ON "warehouse_user" (created_at);
CREATE INDEX IF NOT EXISTS warehouse_user_updated_at_idx ON "warehouse_user" (updated_at);
CREATE INDEX IF NOT EXISTS warehouse_user_user_id_idx ON "warehouse_user" (user_id);
CREATE INDEX IF NOT EXISTS warehouse_user_warehouse_idx ON "warehouse_user" (warehouse);
CREATE TABLE IF NOT EXISTS webhook (
	id bigint NOT NULL
	type text
	method text
	merchant_id bigint
	url text
	action_admin_id bigint
	created_at timestamp
	updated_at timestamp
	CONSTRAINT check_method
);
CREATE TABLE IF NOT EXISTS webhook_header_metadata (
	id bigint NOT NULL
	webhook_id bigint NOT NULL
	key text NOT NULL
	value text NOT NULL
	action_admin_id bigint
	created_at timestamp
	updated_at timestamp
);
CREATE TABLE IF NOT EXISTS wh_inventory_item (
	id bigint NOT NULL
	supplier_tracking_number text
	sku text
	product_name text
	color text
	size text
	asin text
	model text
	brand text
	description text
	weight integer
	created_at timestamp
	updated_at timestamp
	state smallint
	action_admin_id bigint
	rid bigint
	active boolean
	status_amount jsonb
	total_weight integer
	total_item integer
	images text[]
	warehouse text
	location bigint
	merchant_code text
	scanned_times integer
	length integer
	width integer
	height integer
);
CREATE INDEX IF NOT EXISTS wh_inventory_item_active_idx ON "wh_inventory_item" (active);
CREATE INDEX IF NOT EXISTS wh_inventory_item_asin_idx ON "wh_inventory_item" (asin);
CREATE INDEX IF NOT EXISTS wh_inventory_item_brand_idx ON "wh_inventory_item" (brand);
CREATE INDEX IF NOT EXISTS wh_inventory_item_created_at_idx ON "wh_inventory_item" (created_at);
CREATE INDEX IF NOT EXISTS wh_inventory_item_merchant_code_idx ON "wh_inventory_item" (merchant_code);
CREATE INDEX IF NOT EXISTS wh_inventory_item_model_idx ON "wh_inventory_item" (model);
CREATE INDEX IF NOT EXISTS wh_inventory_item_product_name_idx ON "wh_inventory_item" (product_name);
CREATE INDEX IF NOT EXISTS wh_inventory_item_rid_idx ON "wh_inventory_item" (rid);
CREATE INDEX IF NOT EXISTS wh_inventory_item_sku_idx ON "wh_inventory_item" (sku);
CREATE INDEX IF NOT EXISTS wh_inventory_item_supplier_tracking_number_idx ON "wh_inventory_item" (supplier_tracking_number);
CREATE INDEX IF NOT EXISTS wh_inventory_item_updated_at_idx ON "wh_inventory_item" (updated_at);
CREATE INDEX IF NOT EXISTS wh_inventory_item_warehouse_idx ON "wh_inventory_item" (warehouse);
CREATE TABLE IF NOT EXISTS wh_inventory_item_history (
	wh_inventory_item_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS wh_inventory_item_history_revision_idx ON "wh_inventory_item_history" (revision);
CREATE TABLE IF NOT EXISTS wh_inventory_package (
	id bigint
	supplier_tracking_number text
	warehouse text
	created_at timestamp
	updated_at timestamp
	state smallint
	action_admin_id bigint
	rid bigint
	location bigint
);
CREATE INDEX IF NOT EXISTS wh_inventory_package_created_at_idx ON "wh_inventory_package" (created_at);
CREATE INDEX IF NOT EXISTS INDEX ON "wh_inventory_package" (id);
CREATE INDEX IF NOT EXISTS wh_inventory_package_rid_idx ON "wh_inventory_package" (rid);
CREATE INDEX IF NOT EXISTS INDEX ON "wh_inventory_package" (supplier_tracking_number);
CREATE INDEX IF NOT EXISTS wh_inventory_package_updated_at_idx ON "wh_inventory_package" (updated_at);
CREATE INDEX IF NOT EXISTS wh_inventory_package_warehouse_idx ON "wh_inventory_package" (warehouse);
CREATE TABLE IF NOT EXISTS wh_inventory_package_history (
	wh_inventory_package_id bigint NOT NULL
	revision bigint NOT NULL
	user_id bigint NOT NULL
	updated_at timestamp NOT NULL
	prev_state text
	curr_state text NOT NULL
	changes jsonb
);
CREATE INDEX IF NOT EXISTS wh_inventory_package_history_revision_idx ON "wh_inventory_package_history" (revision);
CREATE TABLE IF NOT EXISTS wh_location (
	id bigint NOT NULL
	parent_id bigint
	code text
	name text
	warehouse text
	location_type text
	created_at timestamp NOT NULL
	updated_at timestamp
	active boolean
);
CREATE INDEX IF NOT EXISTS INDEX ON "wh_location" (code);
CREATE INDEX IF NOT EXISTS wh_location_id_idx ON "wh_location" (id);
CREATE INDEX IF NOT EXISTS wh_location_parent_id_idx ON "wh_location" (parent_id);
CREATE INDEX IF NOT EXISTS wh_location_warehouse_idx ON "wh_location" (warehouse);

/*-- TRIGGER BEGIN --*/
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
 ......
/*-- TRIGGER END --*/

COMMIT;
