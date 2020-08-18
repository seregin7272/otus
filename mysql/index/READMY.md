сделать полнотекстовый индекс, который ищет по свойствам, названию товара и описанию
в README представить запрос для тестирования

```mysql

CREATE FULLTEXT INDEX product_name_desc_full on products(name, description);
CREATE FULLTEXT INDEX product_value_string_full on product_values(string_value);

 
 SELECT * 
 FROM products p2 
 WHERE MATCH (name, description ) AGAINST ('Approach')
 and EXISTS (SELECT * FROM product_values pv WHERE pv.product_id = p2.id and MATCH (string_value) AGAINST ('Medium'))
 ;
 
```


анализируем свой проект - добавляем или обновляем индексы
в README пропишите какие индексы были изменены или добавлены
explain и результаты выборки без индекса и с индексом

 ```mysql

 -- 	Фильтр товаров по свойствам и цене
 EXPLAIN SELECT 
 pr.name as product,
 p.value as price,
 pv.string_value 
 FROM products pr
 	join prices p on p.product_id = pr.id
 	join product_values pv on pv.product_id = pr.id
 	where  pv.string_value  = 'Medium'
 	and (p.value > 5 and p.value < 50)
 ;
 

 -- id|select_type|table|partitions|type  |possible_keys                                            |key                    |key_len|ref                 |rows|filtered|Extra      |
 -- --|-----------|-----|----------|------|---------------------------------------------------------|-----------------------|-------|--------------------|----|--------|-----------|
 --  1|SIMPLE     |pv   |          |ALL   |fk_product_values_products1_idx,product_value_string_full|                       |       |                    |2475|    10.0|Using where|
 --  1|SIMPLE     |p    |          |ref   |fk_prices_products1_idx                                  |fk_prices_products1_idx|4      |x_shop.pv.product_id|   1|   11.11|Using where|
 --  1|SIMPLE     |pr   |          |eq_ref|PRIMARY                                                  |PRIMARY                |4      |x_shop.pv.product_id|   1|   100.0|           |
 
 
 CREATE INDEX product_value_string_idx on product_values(string_value);
 
 
 
 
 -- 
 -- id|select_type|table|partitions|type  |possible_keys                                                                     |key                     |key_len|ref                 |rows|filtered|Extra      |
 -- --|-----------|-----|----------|------|----------------------------------------------------------------------------------|------------------------|-------|--------------------|----|--------|-----------|
 --  1|SIMPLE     |pv   |          |ref   |fk_product_values_products1_idx,product_value_string_idx,product_value_string_full|product_value_string_idx|1539   |const               |  78|   100.0|           |
 --  1|SIMPLE     |pr   |          |eq_ref|PRIMARY                                                                           |PRIMARY                 |4      |x_shop.pv.product_id|   1|   100.0|           |
 --  1|SIMPLE     |p    |          |ref   |fk_prices_products1_idx                                                           |fk_prices_products1_idx |4      |x_shop.pv.product_id|   1|   11.11|Using where|
 --  
 --  
  
 
 -- Фильтр товара по цене
 
 EXPLAIN SELECT 
 pr.name as product,
 p.value as price,
 pv.string_value 
 FROM products pr
 	join prices p on p.product_id = pr.id
 	join product_values pv on pv.product_id = pr.id
 	where (p.value > 5 and p.value < 50)
 ;
 

 -- id|select_type|table|partitions|type  |possible_keys                  |key                            |key_len|ref                |rows|filtered|Extra      |
 -- --|-----------|-----|----------|------|-------------------------------|-------------------------------|-------|-------------------|----|--------|-----------|
 --  1|SIMPLE     |p    |          |ALL   |fk_prices_products1_idx        |                               |       |                   |1319|   11.11|Using where|
 --  1|SIMPLE     |pr   |          |eq_ref|PRIMARY                        |PRIMARY                        |4      |x_shop.p.product_id|   1|   100.0|           |
 --  1|SIMPLE     |pv   |          |ref   |fk_product_values_products1_idx|fk_product_values_products1_idx|4      |x_shop.p.product_id|   1|   100.0|           |
 -- 
 
 
 CREATE INDEX price_value_idx on prices(value);
 
 
 -- id|select_type|table|partitions|type  |possible_keys                          |key                            |key_len|ref                |rows|filtered|Extra                |
 -- --|-----------|-----|----------|------|---------------------------------------|-------------------------------|-------|-------------------|----|--------|---------------------|
 --  1|SIMPLE     |p    |          |range |fk_prices_products1_idx,price_value_idx|price_value_idx                |5      |                   |  95|   100.0|Using index condition|
 --  1|SIMPLE     |pr   |          |eq_ref|PRIMARY                                |PRIMARY                        |4      |x_shop.p.product_id|   1|   100.0|                     |
 --  1|SIMPLE     |pv   |          |ref   |fk_product_values_products1_idx        |fk_product_values_products1_idx|4      |x_shop.p.product_id|   1|   100.0|                     |
 -- 
 
 
```