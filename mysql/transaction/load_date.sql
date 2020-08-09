-- 
-- 2) Загрузить данные из приложенных в материалах csv.
-- Реализовать следующими путями:
-- - LOAD DATA
-- - mysqlimport


-- LOAD DATA
DROP TABLE if exists tmp_product_csv;

CREATE table if not exists tmp_product_csv(
handle varchar(255),
title varchar(255),
body text,
vendor varchar(255),
types varchar(255),
tags varchar(255),
published boolean,
option1_name varchar(255),
option1_value varchar(255),
option2_name varchar(255),
option2_value varchar(255),
option3_name varchar(255),
option3_value varchar(255),
variant_inventory_qty int,
variant_price DECIMAL(10,2),
image_src varchar(255),
variant_image varchar(255)
);

LOAD DATA INFILE '/var/csv/tmp_product_csv_import.csv'
	 INTO TABLE tmp_product_csv 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(
		handle,
		title,
		body,
		vendor,
		types,
		tags,
		@published,
		option1_name,
		option1_value,
		option2_name ,
		option2_value,
		option3_name,
		option3_value,
		@variant_sku,
		@variant_grams,
		@variant_inventory_tracker,
		@variant_inventory_qty ,
		@variant_inventory_policy,
		@variant_fulfillment_service ,
		@variant_price,
		@variant_compare_price ,
		@variant_requires_shipping,
		@variant_taxable,
		@variant_barcode,
		image_src,
		@image_alt ,
		@gift_card ,
		@seo_title ,
		@seo_description,
		@google_shopping_google_product_category,
		@google_shopping_gender,
		@google_shopping_age_group,
		@google_shopping_mpn,
		@google_shopping_adwords_grouping,
		@google_shopping_adwords_labels,
		@google_shopping_condition,
		@google_shopping_custom_product,
		@google_shopping_custom_label_0 ,
		@google_shopping_custom_label_1 ,
		@google_shopping_custom_label_2 ,
		@google_shopping_custom_label_3 ,
		@google_shopping_custom_label_4 ,
		variant_image,
		@variant_weight_unit
	)
	SET 
	published = if(@published = 'true', 1, 0),
	variant_inventory_qty = @variant_inventory_qty*1,
	variant_price = @variant_price*1
 	;


 SELECT * from tmp_product_csv;


 












 
 








