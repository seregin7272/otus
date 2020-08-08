-- 
-- 2) Загрузить данные из приложенных в материалах csv.
-- Реализовать следующими путями:
-- - LOAD DATA
-- - mysqlimport

-- mysqlimport

SET GLOBAL local_infile=1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

DROP table IF EXISTS tmp_product_csv_import;
CREATE table if not exists tmp_product_csv_import(
	handle varchar(255),
	title varchar(255),
	body text,
	vendor varchar(255),
	types varchar(255),
	tags varchar(255),
	published varchar(255),
	option1_name varchar(255),
	option1_value varchar(255),
	option2_name varchar(255),
	option2_value varchar(255),
	option3_name varchar(255),
	option3_value varchar(255),
	variant_inventory_qty varchar(255),
	variant_price varchar(255),
	image_src varchar(255),
	variant_image varchar(255)
);

SELECT * from tmp_product_csv_import;
