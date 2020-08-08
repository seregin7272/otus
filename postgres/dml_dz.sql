


-- Добавление тестовых данных и 
-- 3. Напишите запрос на добавление данных с выводом информации о добавленных строках.

truncate locations.countries cascade;


-- Добавляем страны 

insert into locations.countries
values
(default, 'Австралия', 'AU'),
(default,'Австрия', 'AT'),
(default,'Россия', 'RU'),
(default,'США', 'US')
returning id, title, code 
;


-- Добавляем регионы
insert into locations.regions 
(title, country_id )
select reg_name, ctrs.id from (VALUES 	
	('Новый Южный Уэльс', 'AU' ), 
	( 'Северная территория', 'AU' ),
	( 'Квинсленд',  'AU' )
) AS r (reg_name, country_code)
 join locations.countries ctrs on r.country_code = ctrs.code
 returning id, title, country_id
; 


-- Добавляем города
insert into locations.cities 
(title, country_id )
select city_name, ctrs.id from (VALUES 	
	('Канберра', 'AU' ), 
	( 'Балларат', 'AU' ),
	( 'Бендиго',  'AU' ),
	('Дорнбирн', 'AT' ), 
	( 'Брегенц', 'AT' ),
	( 'Москва',  'RU' ),
	( 'Владивосток',  'RU' )
) AS ct (city_name, country_code)
 join locations.countries ctrs on ct.country_code = ctrs.code
 returning id, title, country_id
; 



-- 1. Напишите запрос по своей базе с регулярным выражением, добавьте пояснение, что вы хотите найти.

-- найти страны начинающиеся на А или Р без учета регистра
select * from locations.countries c
where c.title ~* '^(а|р)';

-- 2. Напишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN, как порядок соединений в FROM влияет на результат? Почему?

select * from locations.countries ctrs
join locations.cities ct on ctrs.id = country_id;

select * from locations.cities ct
join locations.countries ctrs on ctrs.id = country_id;


select * from locations.countries ctrs
left join locations.cities ct on ctrs.id = country_id; 

select * from locations.cities ct
left join locations.countries ctrs on ctrs.id = country_id;


/*
 * Для INNER JOIN - никак, потому что выведет только те строки, для которорых условие соединения является истинным.
 * 
 * Для LEFT JOIN - порядок влияет на то какая таблица будет левой и строки из нее попадут в результаты 
 * даже в случае если в правой таблицы нет подходящих под условия соединения строк.
 * 
 */



-- 4. Напишите запрос с обновлением данные используя UPDATE FROM.

update locations.cities as ct set region_id = r.id
from locations.regions r 
where ct.country_id = r.country_id
and r.title = 'Квинсленд';




-- 5. Напишите запрос для удаления данных с оператором DELETE используя join с другой таблицей с помощью using.
delete from locations.cities c 
using locations.regions r 
where 
c.country_id = r.country_id 
and
r.title = 'Квинсленд' ;


-- 6.* Приведите пример использования утилиты COPY (по желанию)

COPY locations.countries TO '/var/lib/postgresql/data/locations_countries.csv' with (FORMAT csv);

COPY locations.countries FROM '/var/lib/postgresql/data/locations_countries.csv' with (FORMAT csv);

COPY t_oil FROM '/var/lib/postgresql/data/oil_ext.txt';

