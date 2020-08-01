

-- 1. Напишите запрос по своей базе с inner join

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
	and categories.id = 2;


-- 2. Напишите запрос по своей базе с left join


-- Количество товаров в каждой категории
SELECT c.* , count(p.id) as product_cnt
FROM categories c 
	left join products_categories pc on pc.category_id = c.id
	left join products p on pc.product_id = p.id
	where
	1=1
	group by c.id
;
	
	
	
-- 3. Напишите 5 запросов с WHERE с использованием разных операторов, опишите для чего вам в проекте нужна такая выборка данных

-- 1 Отсортированное дерево категорий
SELECT 
	node.*, 
	(COUNT(parent.name) - 1) AS depth
FROM  
	categories as node,
	categories  as parent
where 
1=1
and node.lft BETWEEN  parent.lft and parent.rgt
GROUP BY node.id, node.lft
ORDER BY node.lft
;

-- 2 Товары из определенной категории
SELECT p.* 
FROM products p
	join products_categories pc on pc.category_id = p.id
	left join categories c on pc.product_id = c.id
	where
	1=1
	and c.id in(1, 2, 3)
;

	
-- 	3 Фильтр товаров по свойствам и цене
SELECT 
pr.name as product,
p.value as price
FROM products pr
	join prices p on p.product_id = pr.id
	join product_values pv on pv.product_id = pr.id
	where 
	1=1
	and pv.split_value->'$.monitor_type.v' = 'LED' 
	or (p.value > 1000 and p.value < 10000)
;



-- 4 Найти всех детей родительской категории

SELECT * FROM categories node  
where 
EXISTS (
	select id FROM 
		categories parent  
	where 
	1=1
	and	parent.id = 1 
	and parent.rgt > node.rgt 
	and parent.lft < node.lft
);


-- 5 

SELECT * FROM products WHERE name LIKE '%телевизор%';

