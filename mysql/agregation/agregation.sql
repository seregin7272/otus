SET sql_mode = '';

-- сделать выборку показывающую самый дорогой и самый дешевый товар в каждой категории 
SELECT c.id, c.name, min(prs.value) min_price, max(prs.value) max_price
FROM categories c 
	JOIN products_categories pc on pc.category_id = c.id
	JOIN products p on pc.product_id = p.id
	JOIN prices prs ON  prs.product_id = p.id
	WHERE 
	1=1
	GROUP BY c.id
;
	

-- сделать rollup с количеством товаров по категориям

SELECT
IF(GROUPING(c.id), 'total products', c.id ) as category_id,
count(c.id) as product_cnt
FROM categories c 
	LEFT JOIN products_categories pc on pc.category_id = c.id
	LEFT JOIN products p on pc.product_id = p.id
	GROUP BY c.id  WITH ROLLUP;
;












