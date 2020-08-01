-- SELECT * FROM categories;
--  SELECT * FROM products;
--  SELECT * FROM prices p ;
--  SELECT * FROM product_values pv ;

-- SELECT  Concat ('TRUNCATE TABLE ', table_schema, '.', TABLE_NAME, ';')
--      FROM INFORMATION_SCHEMA.TABLES where table_schema in ('x_shop');

-- DROP PROCEDURE IF EXISTS truncate_x_shop;
--
--
-- CREATE PROCEDURE truncate_x_shop()
-- BEGIN
-- 	SET FOREIGN_KEY_CHECKS = 0;
-- 	TRUNCATE TABLE x_shop.addresses;
-- 	TRUNCATE TABLE x_shop.building_numbers;
-- 	TRUNCATE TABLE x_shop.categories;
-- 	TRUNCATE TABLE x_shop.cities;
-- 	TRUNCATE TABLE x_shop.countries;
-- 	TRUNCATE TABLE x_shop.currencies;
-- 	TRUNCATE TABLE x_shop.customer_address;
-- 	TRUNCATE TABLE x_shop.customers;
-- 	TRUNCATE TABLE x_shop.genders;
-- 	TRUNCATE TABLE x_shop.languages;
-- 	TRUNCATE TABLE x_shop.manufacturers;
-- 	TRUNCATE TABLE x_shop.marital_statuses;
-- 	TRUNCATE TABLE x_shop.order_products;
-- 	TRUNCATE TABLE x_shop.order_statuses;
-- 	TRUNCATE TABLE x_shop.orders;
-- 	TRUNCATE TABLE x_shop.postal_codes;
-- 	TRUNCATE TABLE x_shop.price_types;
-- 	TRUNCATE TABLE x_shop.price_units;
-- 	TRUNCATE TABLE x_shop.prices;
-- 	TRUNCATE TABLE x_shop.product_prop_type;
-- 	TRUNCATE TABLE x_shop.product_props;
-- 	TRUNCATE TABLE x_shop.product_types;
-- 	TRUNCATE TABLE x_shop.product_values;
-- 	TRUNCATE TABLE x_shop.products;
-- 	TRUNCATE TABLE x_shop.products_categories;
-- 	TRUNCATE TABLE x_shop.regions;
-- 	TRUNCATE TABLE x_shop.streets;
-- 	TRUNCATE TABLE x_shop.titles;
-- 	TRUNCATE TABLE x_shop.vendors;
-- 	SET FOREIGN_KEY_CHECKS = 1;
-- END;


call  truncate_x_shop();

-- КАТЕГОРИИ

-- Добавление первой категории
INSERT INTO categories (name, parent_id, lft, rgt) VALUES('ELECTRONICS', null, 1, 2);

-- Добавление дочерней
SELECT @lft := lft, @rgt := rgt, @width := rgt - lft + 1, @parent_id := id  FROM categories WHERE name = 'ELECTRONICS';

UPDATE categories SET rgt = rgt + 2 WHERE rgt > @lft;
UPDATE categories SET lft = lft + 2 WHERE lft > @lft;

INSERT INTO categories(name, lft, rgt, parent_id) VALUES('TELEVISIONS', @lft + 1, @lft + 2, @parent_id);

-- ТОВАРЫ


-- Производители
INSERT INTO manufacturers (name, contacts) VALUES
('Xiaomi', JSON_MERGE(
        JSON_OBJECT("phone" , "123456"),
        JSON_OBJECT("phone2" , "123456"),
        JSON_OBJECT("email" , "qwert@ex.com"),
        JSON_OBJECT("email2" , "qwert@ex.com")
        )
),('Samsung',JSON_MERGE(
        JSON_OBJECT("phone" , "123456"),
        JSON_OBJECT("phone2" , "123456"),
        JSON_OBJECT("email" , "qwert@ex.com"),
        JSON_OBJECT("email2" , "qwert@ex.com")
        )

);

-- Поставщики

INSERT INTO vendors (name, contacts) VALUES (
'ООО Рога и Копыта',
JSON_MERGE(
        JSON_OBJECT("phone" , "123456"),
        JSON_OBJECT("phone2" , "123456"),
        JSON_OBJECT("email" , "qwert@ex.com"),
        JSON_OBJECT("email2" , "qwert@ex.com")
        )
);


-- Цены
INSERT INTO price_units (name) VALUES ('шт.');
INSERT INTO currencies (name, code) VALUES ('руб.' , 'RUB');
INSERT INTO price_types (name) VALUES ('Розничная цена');


-- Свойства товаров

INSERT INTO product_types (name) VALUES ('Телевизоры');

INSERT INTO product_props (prop_name, prop_type) VALUES ('Экран телевизора', 'SPLIT_VALUE');
INSERT INTO product_props (prop_name, prop_type) VALUES ('Медиаплеер', 'SPLIT_VALUE');

INSERT INTO product_prop_type (product_type_id,product_prop_id ) VALUES(1, 1);
INSERT INTO product_prop_type (product_type_id, product_prop_id ) VALUES(1, 2);

-- Товары

INSERT INTO products (name, quantity, vendor_id, manufacturer_id, product_type_id) VALUES
(
'LED телевизор DIGMA DM-LED32R201BT2', 100 , 1 , 1, 1
);

INSERT INTO products (name, quantity, vendor_id, manufacturer_id, product_type_id) VALUES
(
'OLED телевизор LG OLED55B8SLB Ultra HD 4K', 500 , 1 , 2, 1
);


-- Привязка товаров к категориям
INSERT INTO products_categories (product_id, category_id ) VALUES (1, 2);

INSERT INTO products_categories (product_id, category_id ) VALUES (2, 2);


-- Добавление свойств товара для 1 товара

   -- {"diagonal": {"v": "32", n:Диагональ}, "monitor_type": {"v": "LED", n: "Тип панели"}, {"screen: {"v": "1366 x 768", n: "Разрешение"}}
INSERT INTO product_values (product_id, product_prop_id, split_value)
VALUES (1, 1 , JSON_MERGE(
        JSON_OBJECT("diagonal" , JSON_OBJECT("v", "32", "n", "Диагональ")),
        JSON_OBJECT("monitor_type" ,JSON_OBJECT("v", "LED", "n", "Тип панели")),
        JSON_OBJECT("screen" , JSON_OBJECT("v", "1366 x 768", "n", "Разрешение"))
        )
    );

INSERT INTO product_values (product_id, product_prop_id, split_value)
VALUES (1, 2 , JSON_MERGE(
        JSON_OBJECT("type_usb", JSON_OBJECT("n","Тип разъема USB" , "v", "мультимедийный")),
        JSON_OBJECT("format_play", JSON_OBJECT("n","Форматы воспроизведения" , "v",
        JSON_ARRAY("DVD видео (VOB), MPEG2/MPEG4 (AVI, MPG), H.264 (MKV, MPG), H.265 HEVC")))
        )
    );



-- Добавление свойст товара для 2 товара
INSERT INTO product_values (product_id, product_prop_id, split_value)
VALUES (2, 1 , JSON_MERGE(
        JSON_OBJECT("diagonal" , JSON_OBJECT("v", "55", "n", "Диагональ")),
        JSON_OBJECT("monitor_type" ,JSON_OBJECT("v", "	OLED", "n", "Тип панели")),
        JSON_OBJECT("screen" , JSON_OBJECT("v", "3840 x 2160", "n", "Разрешение"))
        )
    );


INSERT INTO product_values (product_id, product_prop_id, split_value)
VALUES (2, 2 , JSON_MERGE(
        JSON_OBJECT("type_usb", JSON_OBJECT("n","Тип разъема USB" , "v", "мультимедийный")),
        JSON_OBJECT("format_play", JSON_OBJECT("n","Форматы воспроизведения" , "v",
        JSON_ARRAY("DVD видео (VOB), MPEG2/MPEG4 (AVI, MPG), H.264 (MKV, MPG), H.265 HEVC")))
        )
    );



-- Слздание цены для товара
INSERT INTO prices (value, currency_id, price_type_id, price_unit_id , product_id )
VALUES(9000, 1, 1, 1, 1);

INSERT INTO prices (value, currency_id, price_type_id, price_unit_id , product_id )
VALUES(5000, 1, 1, 1, 2);

--


-- Пример выборки JSON

SELECT
products.name as product,
p.value as price ,
pu.name as unit,
c.name as currency,
categories.name as category_name,
pv.split_value
FROM products
	join products_categories on products_categories.product_id = products.id
	left join categories on categories.id = products_categories.category_id
	join prices p on p.product_id = products.id
	join price_units pu on pu.id = p.price_unit_id
	join currencies c on c.id = p.currency_id
	join product_values pv on pv.product_id = products.id
	where
	1=1
	and categories.id = 2
	and pv.split_value->'$.monitor_type.v' = 'LED'
	;





































