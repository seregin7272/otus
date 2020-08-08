
-- Создание пользователя
CREATE ROLE otus_shop WITH LOGIN PASSWORD 'otus';

-- Создание базы данных
CREATE DATABASE otus_shop OWNER otus_shop;


-- Создание табличного пространства для Покупателей
CREATE TABLESPACE otus_shop_customers LOCATION '/var/lib/postgresql/data/pg_tblspc';


-- Создание схемы для КАТАЛОГ ПРОДУКЦИИ
CREATE SCHEMA catalogs AUTHORIZATION otus_shop;

-- Создание схемы для ПОКУПАТЕЛЕЙ
CREATE SCHEMA customers AUTHORIZATION otus_shop;

-- Создание схемы для ЗАКАЗОВ
CREATE SCHEMA orders AUTHORIZATION otus_shop;

-- Создание схемы для АДРЕСОВ
CREATE SCHEMA locations AUTHORIZATION otus_shop;



DROP TABLE IF EXISTS 
	locations.building_numbers,
	locations.postal_codes,
	locations.streets,
	locations.regions,
	locations.cities,
	locations.countries
CASCADE
;


DROP TABLE IF EXISTS 
	catalogs.prices,
	catalogs.price_types,
	catalogs.price_units,
	catalogs.currencies,
	catalogs.product_values,
	catalogs.products,
	catalogs.product_props,
	catalogs.product_types,
	catalogs.vendors,
	catalogs.manufacturers,
	catalogs.categories,
	catalogs.products_categories
CASCADE
;


DROP TABLE IF EXISTS 
	customers.customers,
	customers.titles,
	customers.genders,
	customers.material_statuses,
	customers.languages,
	customers.addresses,
cascade
;


DROP TABLE IF EXISTS 
	orders.order_products,
	orders.orders,
	orders.order_statuses
CASCADE
;


 /* Таблицы для АДРЕСОВ */


-- Страны 
CREATE TABLE locations.countries 
(
	id serial PRIMARY KEY, 			-- первичный ключ
	title varchar(255) NOT NULL, 	-- Название страны
	code char(2) UNIQUE NOT NULL 	-- 2-x значный код страны
);



-- Регионы
CREATE TABLE locations.regions 
(
	id serial PRIMARY KEY, 			-- первичный ключ
	title varchar(255) NOT NULL, 	-- Название региона
	country_id integer NOT NULL, 	-- cвязь с locations.countries
	FOREIGN KEY ( country_id )
	REFERENCES locations.countries ( id )
	ON DELETE CASCADE
);


-- Города
CREATE TABLE locations.cities 
(
	id serial PRIMARY KEY,			-- первичный ключ
	title varchar(255) NOT NULL, 	-- Название региона
	country_id integer NOT NULL, 	-- cвязь с locations.countries
	region_id integer, 				-- cвязь с locations.regions
	FOREIGN KEY ( country_id )
	REFERENCES locations.countries ( id )
	ON DELETE CASCADE,
	FOREIGN KEY ( region_id )
	REFERENCES locations.regions ( id )
	ON DELETE SET NULL
);


-- Улицы
CREATE TABLE locations.streets
(
	id serial PRIMARY KEY,			-- первичный ключ
	title varchar(255) NOT NULL, 	-- Название улицы
	city_id integer NOT NULL, 		-- cвязь с locations.cities
	FOREIGN KEY ( city_id )
	REFERENCES locations.cities ( id )
	ON DELETE CASCADE
);



-- Индексы
CREATE TABLE locations.postal_codes
(
	id serial PRIMARY KEY, 			-- первичный ключ
	code varchar(255) NOT NULL, 	-- индекс
	street_id integer NOT NULL, 	-- cвязь с locations.streets
	FOREIGN KEY ( street_id )
	REFERENCES locations.streets ( id )
	ON DELETE cascade,
	CONSTRAINT unique_postal_code_on_street UNIQUE ( code, street_id ) -- Уникальные индекс для каждой улицы
);



-- Номера для зданий
CREATE TABLE locations.building_numbers
(
	id serial PRIMARY KEY, 				-- первичный ключ
	value varchar(255) NOT NULL, 		-- Номер здания
	postal_code_id integer NOT NULL, 	-- cвязь с locations.postal_codes
	FOREIGN KEY ( postal_code_id )
	REFERENCES locations.postal_codes ( id )
	ON DELETE cascade,
	CONSTRAINT unique_building_number UNIQUE ( value, postal_code_id ) -- Уникальные номер здания для каждого индекса
);



/* Таблицы для ПОКУПАТЕЛЯ */


-- Формы обращения
CREATE TABLE customers.titles
(
	id serial PRIMARY KEY,		-- первичный ключ
	title varchar(255) NOT null	-- форма обращения
) TABLESPACE otus_shop_customers;


-- Пол
CREATE TABLE customers.genders
(
	id serial PRIMARY KEY, 		-- первичный ключ
	title varchar(255) NOT null	-- пол
) TABLESPACE otus_shop_customers;


-- Материальное положение
CREATE TABLE customers.material_statuses
(
	id serial PRIMARY KEY,		-- первичный ключ
	title varchar(255) NOT null 	-- название статуса
);


-- Язык покупателя
CREATE TABLE customers.languages
(
	id serial PRIMARY KEY,		-- первичный ключ
	title varchar(255) NOT NULL	-- название языка
) TABLESPACE otus_shop_customers;



-- Покупатель
CREATE TABLE customers.customers
(
	id serial PRIMARY KEY,						-- первичный ключ
	first_name varchar(255) NOT NULL,			-- имя
	last_name varchar(255) NOT NULL,			-- фамилия
	birth_date date,							-- дата рождения
	title_id integer REFERENCES  				-- cвязь с формой обращения
		customers.titles 
		ON DELETE SET NULL,
	material_statuse_id integer REFERENCES 		-- cвязь с материальным статусом
		customers.material_statuses 
		ON DELETE SET NULL,
	correspondence_language_id integer references -- cвязь с названием языка
		customers.languages 
		ON DELETE SET NULL,
	gender_id integer references				-- cвязь с указаним пола
		customers.genders 
		ON DELETE SET NULL
) TABLESPACE otus_shop_customers;



-- Адреса покупателя
CREATE TABLE customers.addresses
(
	id serial PRIMARY KEY, 						-- первичный ключ
	title varchar(255) NOT NULL,					-- наименование адреса
	building_number_id integer NOT NULL,		-- связь с адресом
	customer_id integer,						-- связь с покупателем
	FOREIGN KEY ( building_number_id )			
	REFERENCES locations.building_numbers
	ON DELETE cascade,
	FOREIGN KEY (customer_id)
	REFERENCES customers.customers
	ON DELETE cascade
) TABLESPACE otus_shop_customers;



 /* Таблицы для КАТАЛОГ ПРОДУКЦИИ */


-- Категории продуктов
CREATE TABLE catalogs.categories
(
	id serial PRIMARY KEY, 									-- первичный ключ
	title varchar(255) NOT NULL,							-- наименование категории
	lvl integer NOT NULL CHECK (lvl >=0) DEFAULT 0, -- уровень узла и показывает количество родителей узла
	left_key integer NOT NULL CHECK (left_key >=0),			-- левый ключ узла и указывает на точку отсчета начала ветки
	right_key integer NOT NULL CHECK (right_key >=0),			-- правый ключ узла и указывает на точку останова конца ветки.
	parent_id integer,										-- связь с родительской категорией
	FOREIGN KEY ( parent_id )								
	REFERENCES catalogs.categories( id ) 
	ON DELETE CASCADE
);


-- Производители продуктов
CREATE TABLE catalogs.manufacturers
(
	id serial PRIMARY KEY, 									-- первичный ключ
	title varchar(255) NOT NULL,							-- наименование
	logo varchar(255), 										-- логотип производителя
	description text, 										-- описание
	contacts jsonb 											-- контактные данные 
);

-- Поставщики продуктов
CREATE TABLE catalogs.vendors
(
	id serial PRIMARY KEY, 									-- первичный ключ
	title varchar(255) NOT NULL,							-- наименование
	description text, 										-- описание
	contacts jsonb 											-- контактные данные 
);



-- Типы продуктов
CREATE TABLE catalogs.product_types
(
	id serial PRIMARY KEY, 									-- первичный ключ
	title varchar(255) NOT NULL							-- наименование типа
);


-- Свойства продуктов
CREATE TABLE catalogs.product_props
(
	id serial PRIMARY KEY, 										-- первичный ключ
	prop_name varchar(255) NOT NULL,							-- наименование свойства
	prop_type varchar(255) NOT NULL,							-- тип свойства
	product_type_id integer NOT NULL REFERENCES catalogs.product_props	-- связь с типом продуктов						
);


-- Продукты
CREATE TABLE catalogs.products
(
	id serial PRIMARY KEY, 										-- первичный ключ
	title varchar(255) NOT NULL,								-- наименование
	description text, 											-- описание
	active boolean NOT null DEFAULT true, 									-- признак активности
	created_at timestamp NOT NULL DEFAULT current_timestamp, 	-- когда создали 
	updated_at timestamp NOT NULL DEFAULT current_timestamp, 	-- когда обновили
	quantity smallint NOT NULL DEFAULT 0 CHECK(quantity >= 0),	-- количество,
	product_type_id integer NOT NULL REFERENCES catalogs.product_types, -- Связь с типом продукта
	manufacturer_id integer REFERENCES catalogs.manufacturers,			-- Связь с производителем
	vendor_id integer REFERENCES catalogs.vendors						-- Связь с поставщиком
);

-- Связь продукта с его категориями
CREATE TABLE catalogs.products_categories
(
	customer_id integer,			-- связь с  покупателем
	address_id integer,				-- связь с адресами покупателя
	PRIMARY KEY ( customer_id, address_id ),
	FOREIGN KEY ( customer_id ) REFERENCES customers.customers ON DELETE cascade,
	FOREIGN KEY ( address_id ) REFERENCES customers.addresses ON DELETE cascade
);


-- Значения свойств продукта
CREATE TABLE catalogs.product_values
(
	id serial PRIMARY KEY, 										-- первичный ключ
	int_value integer, 											-- целочисленные данные
	num_value numeric,											-- c плавающий точкой данные
	string_value varchar(512), 									-- строковый данные
	text_value text, 											-- текстовые данные 
	timestamp_value timestamp,									-- дата и время данные
	split_value jsonb, 											-- множественные данные
	product_id integer NOT NULL, 								-- связь с продуктом
	product_prop_id integer NOT NULL,                           -- связь со свойством продукта
	FOREIGN KEY ( product_id ) REFERENCES catalogs.products ON DELETE cascade,
	FOREIGN KEY ( product_prop_id ) REFERENCES catalogs.product_props ON DELETE cascade 
);


-- Валюта
CREATE TABLE catalogs.currencies
(
	id serial PRIMARY KEY, 										-- первичный ключ
	title varchar(100) NOT NULL, 								-- наименование
	code varchar(10) NOT NULL UNIQUE							-- код валюты
);


-- Название еденицы товара
CREATE TABLE catalogs.price_units
(
	id serial PRIMARY KEY, 										-- первичный ключ
	title varchar(100) NOT NULL								-- наименование
);


-- Тип цены
CREATE TABLE catalogs.price_types
(
	id serial PRIMARY KEY, 										-- первичный ключ
	title varchar(100) NOT NULL 								-- наименование
);


-- Цена товара
CREATE TABLE catalogs.prices
(
	id serial PRIMARY KEY, 											-- первичный ключ
	amount integer NOT null CHECK(amount >= 0), 							-- стоимость товара
	price_type_id integer NOT NULL REFERENCES catalogs.price_types, -- связь с типом цены
	currency_id integer NOT NULL REFERENCES catalogs.currencies,	-- связь с валютой
	product_id integer NOT NULL REFERENCES catalogs.products, 		-- связь с продуктом
	price_unit_id integer NOT NULL REFERENCES catalogs.price_units  -- связь с название еденицы товара
);



 /* Таблицы для ЗАКАЗОВ */


-- Статусы заказа
CREATE TABLE orders.order_statuses
(
	id serial PRIMARY KEY, 										-- первичный ключ
	title varchar(255) NOT NULL, 								-- наименование
	code varchar(10) NOT NULL UNIQUE							-- код стауса
);


-- Заказы
CREATE TABLE orders.orders
(
	id serial PRIMARY KEY, 										-- первичный ключ
	created_at timestamp NOT NULL DEFAULT current_timestamp, 	-- когда создали 
	updated_at timestamp NOT NULL DEFAULT current_timestamp, 	-- когда обновили
	customer_id integer NOT NULL REFERENCES customers.customers, -- связь покупателем
	order_status_id integer NOT NULL REFERENCES orders.order_statuses,	-- связь со статусом заказа
	address_id integer NOT NULL REFERENCES customers.addresses 		-- связь с адресом покупателя
);


-- Продукты в заказе
CREATE TABLE orders.order_products
(
	id serial PRIMARY KEY, 										-- первичный ключ
	title varchar(255) NOT NULL, 								-- наименование
	amount integer NOT null CHECK(amount >= 0), 				-- цена
	quantity smallint NOT NULL DEFAULT 0 CHECK(quantity >= 0),	-- количество
	product_id integer references catalogs.products on delete set null,  -- связ с продуктами из каталога
	order_id integer references orders.orders, 							-- связ с заказом
	order_product_props jsonb									-- информация свойствах купленного продукта
);




