
-- Добавление дочерней категории
BEGIN;

SELECT @lft := lft, @rgt := rgt, @width := rgt - lft + 1, @parent_id := id  FROM categories WHERE name = 'ELECTRONICS';

UPDATE categories SET rgt = rgt + 2 WHERE rgt > @lft;
UPDATE categories SET lft = lft + 2 WHERE lft > @lft;

INSERT INTO categories(name, lft, rgt, parent_id) VALUES('TELEVISIONS', @lft + 1, @lft + 2, @parent_id);

COMMIT;





-- Добавление товара
BEGIN;

INSERT INTO 
	products (name, quantity, vendor_id, manufacturer_id, product_type_id) 
VALUES (
	'OLED телевизор LG OLED55B8SLB Ultra HD 4K', 500 , 1 , 2, 1 
);

SET @productLastId := LAST_INSERT_ID();

-- Добавление свойств товара
INSERT INTO product_values (product_id, product_prop_id, split_value)
VALUES (@productLastId, 1 , JSON_MERGE(
        JSON_OBJECT("diagonal" , JSON_OBJECT("v", "32", "n", "Диагональ")),
        JSON_OBJECT("monitor_type" ,JSON_OBJECT("v", "LED", "n", "Тип панели")),
        JSON_OBJECT("screen" , JSON_OBJECT("v", "1366 x 768", "n", "Разрешение"))
        )
    );
   
INSERT INTO product_values (product_id, product_prop_id, split_value)
VALUES (@productLastId, 2 , JSON_MERGE(
        JSON_OBJECT("type_usb", JSON_OBJECT("n","Тип разъема USB" , "v", "мультимедийный")),
        JSON_OBJECT("format_play", JSON_OBJECT("n","Форматы воспроизведения" , "v", 
        JSON_ARRAY("DVD видео (VOB), MPEG2/MPEG4 (AVI, MPG), H.264 (MKV, MPG), H.265 HEVC")))
        )
    ); 
     
INSERT INTO prices (value, currency_id, price_type_id, price_unit_id , product_id ) 
VALUES (
	9000, 1, 1, 1, @productLastId
);

COMMIT;


SELECT  * FROM products;








