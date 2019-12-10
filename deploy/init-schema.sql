
BEGIN;
CREATE TABLE IF NOT EXISTS airline (
	code TEXT PRIMARY
	name TEXT NOT NULL
	description TEXT
);
CREATE TABLE IF NOT EXISTS category (
	code TEXT PRIMARY
	name TEXT NOT NULL
	description TEXT
);
CREATE TABLE IF NOT EXISTS country (
	code TEXT PRIMARY
	name TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS country_code_idx ON "country" (code);
CREATE TABLE IF NOT EXISTS courier (
	code TEXT PRIMARY
	name TEXT NOT NULL
	description TEXT
);
CREATE TABLE IF NOT EXISTS district (
	code TEXT PRIMARY
	name TEXT NOT NULL
	province_code INT4 NOT NULL
);
CREATE INDEX IF NOT EXISTS district_code_idx ON "district" (code);
CREATE INDEX IF NOT EXISTS district_province_code_idx ON "district" (province_code);
CREATE TABLE IF NOT EXISTS gic_staff (
	id INT8 PRIMARY
	code TEXT
	created_at TIMESTAMPTZ
	updated_at TIMESTAMPTZ
	deleted_at TIMESTAMPTZ
	disabled_at TIMESTAMPTZ
	roles TEXT[]
	name TEXT NOT NULL
	email TEXT NOT NULL
	phone TEXT NOT NULL
	avatar TEXT
);
CREATE TABLE IF NOT EXISTS logistic_partner (
	code TEXT PRIMARY
	name TEXT NOT NULL
	description TEXT
);
CREATE TABLE IF NOT EXISTS merchant (
	id INT8 PRIMARY
	code TEXT
	created_at TIMESTAMPTZ
	updated_at TIMESTAMPTZ
	deleted_at TIMESTAMPTZ
	disabled_at TIMESTAMPTZ
	name TEXT NOT NULL
	email TEXT NOT NULL
	phone TEXT NOT NULL
	address TEXT
	avatar TEXT
	refcode TEXT
	admin_id INT8
);
CREATE TABLE IF NOT EXISTS merchant_order (
	id INT8 PRIMARY
	code TEXT
	flow TEXT
	flow_version INT2
	state TEXT NOT NULL
	state_final INT2 NOT NULL
	created_at TIMESTAMPTZ
	updated_at TIMESTAMPTZ
	cancelled_at TIMESTAMPTZ
	closed_at TIMESTAMPTZ
	price_updated_at TIMESTAMPTZ
	mark_paid_at TIMESTAMPTZ
	admin_id INT8
	created_by_admin_id INT8
	merchant_id INT8 NOT NULL
	merchant TEXT
	note_admin TEXT
	note_cancel TEXT
	note_order TEXT
	note_shipping TEXT
	note_admin_merchant TEXT
	payment_status INT4
	payment_type INT4
	prepaid_amount_vnd INT4
	basket_value_vnd INT4
	basket_value_x INT4
	remain_amount_vnd INT4
	cod_amount_vnd INT4
	discount_vnd INT4
	discount_x INT4
	us_tax_x INT4
	us_shipping_fee_x INT4
	purchase_fee_x INT4
	purchase_fee_vnd INT4
	surcharge_x INT4
	gido_fee_x INT4
	gido_fee_vnd INT4
	total_fee_vnd INT4
	total_amount_vnd INT4
	order_items_json JSONB
	coupon_code TEXT
	total_items INT2
	closed_items INT2
	cancelled_items INT2
	plan_id INT8
	plan_name TEXT
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
CREATE TABLE IF NOT EXISTS merchant_order_history (
	merchant_order_id INT8 NOT NULL
	revision INT2 NOT NULL
	user_id INT8 NOT NULL
	updated_at TIMESTAMPTZ NOT NULL
	prev_state TEXT
	curr_state TEXT NOT NULL
	state_final INT2 NOT NULL
	changes JSONB
);
CREATE INDEX IF NOT EXISTS merchant_order_history_merchant_order_id_idx ON "merchant_order_history" (merchant_order_id);
CREATE TABLE IF NOT EXISTS order_item (
	id INT8 PRIMARY
	gcode TEXT
	gscode TEXT
	flow TEXT
	flow_version INT2
	state TEXT
	state_final INT2
	created_at TIMESTAMPTZ
	updated_at TIMESTAMPTZ
	closed_at TIMESTAMPTZ
	cancelled_at TIMESTAMPTZ
	admin_id INT8
	box_id INT8
	created_by_admin_id INT8
	merchant_id INT8
	merchant_order_id INT8
	pagent_id INT8
	airline TEXT
	airline_name TEXT
	basket_value_vnd INT4
	basket_value_x INT4
	category TEXT
	category_name TEXT
	chargeable_weight INT4
	cod_amount_vnd INT4
	consol_warehouse TEXT
	consol_warehouse_name TEXT
	currency TEXT
	custom_clearance_at TIMESTAMPTZ
	delivered_to_customer_at TIMESTAMPTZ
	delivered_xx_at TIMESTAMPTZ
	discount_vnd INT4
	est_delivery_to_customer_at TIMESTAMPTZ
	est_delivery_xx_at TIMESTAMPTZ
	exchange_rate INT4
	height INT4
	last_mile_fee_vnd INT4
	length INT4
	mark_paid_at TIMESTAMPTZ
	merchant TEXT
	merchant_cashback_vnd INT4
	note_admin TEXT
	note_cancel TEXT
	note_product TEXT
	note_shipping TEXT
	pagent TEXT
	pagent_assigned_at TIMESTAMPTZ
	pagent_commission_percent INT2
	pagent_commission_x INT4
	pagent_est_purchasing_amount_x INT4
	pagent_expired_at TIMESTAMPTZ
	pagent_other_fee_x INT4
	pagent_price_x INT4
	pagent_proceed_price_x INT4
	pagent_purchase_price_x INT4
	pagent_purchased_at TIMESTAMPTZ
	pagent_receipt_id INT8
	payment_status INT4
	payment_type INT4
	prepaid_amount_vnd INT4
	price_updated_at TIMESTAMPTZ
	product_link TEXT
	purchase_fee_vnd INT4
	purchase_fee_x INT4
	purchased_pagent_commission_at TIMESTAMPTZ
	quantity INT4
	real_weight INT4
	remain_amount_vnd INT4
	shipping_address TEXT
	shipping_district TEXT
	shipping_district_name TEXT
	shipping_name TEXT
	shipping_phone TEXT
	shipping_province TEXT
	shipping_province_name TEXT
	shipping_ward TEXT
	shipping_ward_name TEXT
	supplier TEXT
	supplier_courier TEXT
	supplier_courier_name TEXT
	supplier_name TEXT
	supplier_order_number TEXT
	supplier_price_vnd INT4
	supplier_price_x INT4
	supplier_shipping_fee_x INT4
	supplier_tracking_number TEXT
	surcharge_x INT4
	t3pl TEXT
	t3pl_name TEXT
	tax_x INT4
	total_amount_vnd INT4
	total_fee_vnd INT4
	update_pagent_price_at TIMESTAMPTZ
	volumetric_weight INT4
	width INT4
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
CREATE TABLE IF NOT EXISTS order_item_history (
	order_item_id INT8 NOT NULL
	revision INT2 NOT NULL
	user_id INT8 NOT NULL
	updated_at TIMESTAMPTZ NOT NULL
	prev_state TEXT
	curr_state TEXT NOT NULL
	state_final INT2 NOT NULL
	changes JSONB
);
CREATE INDEX IF NOT EXISTS order_item_history_order_item_id_idx ON "order_item_history" (rder_item_history_order_item_id_i);
CREATE TABLE IF NOT EXISTS pagent (
	id INT8 PRIMARY
	code TEXT
	created_at TIMESTAMPTZ
	updated_at TIMESTAMPTZ
	deleted_at TIMESTAMPTZ
	disabled_at TIMESTAMPTZ
	name TEXT NOT NULL
	email TEXT NOT NULL
	phone TEXT NOT NULL
	address TEXT
	avatar TEXT
);
CREATE TABLE IF NOT EXISTS pagent_receipt (
	id INT8 PRIMARY
	pagent_id INT8
	admin_id INT8
	created_at TIMESTAMPTZ
	receipt_at TIMESTAMPTZ
	pagent_purchasing_amount_x INT4
	commission_percent INT2
	commission_amount_x INT4
	commission_amount_vnd INT4
	exchange_rate INT4
	note_purchase_commission TEXT
);
CREATE TABLE IF NOT EXISTS province (
	code TEXT PRIMARY
	name TEXT NOT NULL
	country_code TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS province_code_idx ON "province" (code);
CREATE INDEX IF NOT EXISTS province_country_code_idx ON "province" (country_code);
CREATE TABLE IF NOT EXISTS role (
	id INT8 PRIMARY
	name TEXT NOT NULL
	created_at TIMESTAMPTZ
	updated_at TIMESTAMPTZ
	deleted_at TIMESTAMPTZ
);
CREATE TABLE IF NOT EXISTS supplier (
	code TEXT PRIMARY
	name TEXT NOT NULL
	description TEXT
);
CREATE TABLE IF NOT EXISTS test (
	code TEXT PRIMARY
	name TEXT NOT NULL
	description TEXT
);
CREATE TABLE IF NOT EXISTS user_internal (
	user_id INT8 PRIMARY
	user_type TEXT
	hash_pwd TEXT
);
CREATE TABLE IF NOT EXISTS ward (
	code TEXT PRIMARY
	name TEXT NOT NULL
	district_code INT4 NOT NULL
);
CREATE INDEX IF NOT EXISTS ward_code_idx ON "ward" (code);
CREATE INDEX IF NOT EXISTS ward_district_code_idx ON "ward" (district_code);
CREATE TABLE IF NOT EXISTS warehouse (
	code TEXT PRIMARY
	name TEXT NOT NULL
	description TEXT
	address TEXT
	ward TEXT
	district TEXT
	province TEXT
	country TEXT,
	phone TEXT
	consignee TEXT
);

/*-- TRIGGER BEGIN --*/

/*-- TRIGGER END --*/

COMMIT;
