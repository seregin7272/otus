### Задание

1) Описать пример транзакции из своего проекта с изменением данных в нескольких таблицах. Реализовать в виде хранимой процедуры.

2) Загрузить данные из приложенных в материалах csv.
Реализовать следующими путями:
- LOAD DATA
- mysqlimport 

*) реализовать загрузку через fifo


### Транзакция

Файл `transaction.sql`

### Загрузка данных из csv

Объеденяем в один файл файл `tmp_product_csv_import.csv`

```sh
cat Apparel.csv Fashion.csv jewelry.csv SnowDevil.csv > tmp_product_csv_import.csv
```


1) LOAD DATA

Нужно установить в my.cnf
```cnf
secure_file_priv='/var/csv
```
 Скрипт загрузки файл `laod_date.sql`

2) mysqlimport

Нужно установить
 ```mysql
SET GLOBAL local_infile=1;
```
Команда для импорта в `csv.sh` 