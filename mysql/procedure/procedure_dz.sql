use x_shop;

-- Создать пользователей client, manager.

CREATE USER 'client'@'%' IDENTIFIED BY 'secret';
CREATE USER 'manager'@'%' IDENTIFIED BY 'secret';


-- Создать процедуру выборки товаров с использованием различных фильтров: категория, цена, производитель, различные дополнительные параметры
-- Также в качестве параметров передавать по какому полю сортировать выборку, и параметры постраничной выдачи



DROP PROCEDURE IF EXISTS GetProducts;

DELIMITER $$
CREATE PROCEDURE GetProducts(
	IN categoryId INT, 
	IN vendorId INT,
	IN priceGt INT,
	IN priceLt INT,
	IN prop_color VARCHAR(255),
	IN prop_size  VARCHAR(255),
	IN fieldSort  VARCHAR(255),
	IN itemLimit INT
)
BEGIN

	SELECT lft, rgt FROM categories WHERE id = categoryId INTO @lft, @rgt;

	SELECT DISTINCT
		pc.category_id, 
		pr.id, pr.name,
		p.value as price 
	FROM products pr
		JOIN products_categories pc on pc.product_id = pr.id
		JOIN prices p on p.product_id = pr.id
		JOIN product_values pv on pv.product_id = pr.id
		WHERE
		category_id IN (SELECT id  FROM categories  WHERE lft >=  @lft and rgt <=@rgt)
		and pr.id IN (
			SELECT 
				product_id 
			FROM 
				product_values 
			where 
				string_value = prop_size and  product_prop_id = 5 
				or 
				string_value = prop_color and  product_prop_id = 1
			)
		and (p.value > priceGt and p.value < priceLt)
		and vendor_id = vendorId
		ORDER BY fieldSort
		LIMIT itemLimit
	;	
END$$
DELIMITER ;


call GetProducts(18, 20, 1, 10000, 'Black', '12', 'price', 100);

-- дать права на запуск процедуры пользователю client
GRANT EXECUTE ON PROCEDURE x_shop.GetProducts TO 'client'@'%';



-- Создать процедуру get_orders - которая позволяет просматривать отчет по продажам за определенный период (час, день, неделя)
-- с различными уровнями группировки (по товару, по категории, по производителю)
-- Права дать пользователю manager


DROP PROCEDURE IF EXISTS GetOrders;

DELIMITER $$
CREATE PROCEDURE GetOrders(
	IN reportInterval VARCHAR(255),
	IN reportGroup VARCHAR(255)
)
BEGIN
    
    IF 
		reportInterval = 'DAY'
	THEN
		SET @rInterval = '(SELECT NOW() - INTERVAL 1 DAY)';
	 ELSEIF 
	 	reportInterval = 'WEEK'
	THEN
	 	SET @rInterval = '(SELECT NOW() - INTERVAL 1 WEEK)';
	ELSE	
	 	SET @rInterval = '(SELECT NOW() - INTERVAL 1 HOUR)';
 	 END IF;
     
      IF 
		reportGroup = 'CATEGORY'
	THEN
		SET @sGroup = 'SELECT c2.id, c2.name, o.id as order_id, o.created_at ';
        SET @rGroup = ' GROUP BY c2.id, o.id';
	 ELSEIF 
	 	reportGroup = 'VENDOR'
	THEN
		SET @sGroup = 'SELECT v.id, v.name, o.id as order_id, o.created_at ';
	 	SET @rGroup = ' GROUP BY v.id, o.id';
	ELSE	
		SET @sGroup = 'SELECT p2.id, p2.name, o.id as order_id, o.created_at ';
	 	SET @rGroup = ' GROUP BY p2.id, o.id';
 	 END IF;
		
        
        
    SET @mainSql = 'FROM 
		orders o 
	JOIN order_products op ON op.order_id = o.id 
	JOIN products p2 ON p2.id = op.product_id
	LEFT JOIN vendors v ON v.id = p2.vendor_id
	JOIN products_categories pc ON pc.product_id = p2.id 
	JOIN categories c2 ON c2.id = pc.category_id 
	WHERE 
	o.created_at >='; 


	SET @sql = CONCAT(@sGroup, @mainSql, @rInterval, @rGroup, ' ORDER BY o.id');
    
	PREPARE stmt FROM @sql;
	EXECUTE stmt;

END$$
DELIMITER ;



call GetOrders('DAY', 'VENDOR');


-- права дать пользователю manager
GRANT EXECUTE ON PROCEDURE x_shop.GetOrders TO 'manager'@'%';
















