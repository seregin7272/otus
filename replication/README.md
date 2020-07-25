
Физическая репликация:
Весь стенд собирается в Docker образах. Необходимо:
- Настроить физическую репликации между двумя кластерами базы данных
- Репликация должна работать использую "слот репликации"
- Реплика должна отставать от мастера на 5 минут

Логическая репликация:
В стенд добавить еще один кластер Postgresql. Необходимо:
- Создать на первом кластере базу данных, таблицу и наполнить ее данными (на ваше усмотрение)
- На нем же создать публикацию этой таблицы
- На новом кластере подписаться на эту публикацию
- Убедиться что она среплицировалась. Добавить записи в эту таблицу на основном сервере и убедиться, что они видны на логической реплике

Версия PostgreSQL на ваше усмотрение




# Настройка Master-Slave репликации
### Настройка Master-сервера 
 
 - Создание тестовых данных
     ```sh
       CREATE DATABASE test;
       
       create table test( description text);
       
       INSERT INTO test SELECT 'Just a line' FROM generate_series(1,1000);
      ```

- Создаем пользователя для репликации
  ```sh
    CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'secret';
  ```

- Редактируем файл pg_hba.conf, который отвечает за аутентификацию

    ```pg_hba.conf
    host    replication     replicator      0.0.0.0/0              md5
    host    all             replicator      0.0.0.0/0              md5
  
    ```
- Редактируем файл postgresql.conf

     ```postgresql.conf
    wal_level = replica
    max_wal_senders = 10
    max_replication_slots = 10
    ```

- Создаем слот репликации

    ```sh
    SELECT pg_create_physical_replication_slot('secondary');
    SELECT * FROM pg_replication_slots;
  ```
  
 - Перезагружаем конфиг
   ```sh
    SELECT pg_reload_conf();
    ```
  
### Настройка Slave-сервера
  
  - Делаем полный бекап 
      ```sh
      pg_basebackup -h pg-primary -U replicator -D /var/lib/postgresql/data -Fp -Xs -P -R
       ```
 - Редактируем файл postgresql.conf
    
     ```postgresql.conf
    primary_slot_name = 'secondary'
    hot_standby = on
    recovery_min_apply_delay = 300s
    ```

- Изменяем  PGDATA: /var/lib/postgresql/pgdata/pgdatabackup в docker-compose.yml

- Перзапускаем службу 'pg-secondary' в docker-compose

## Проверка репликации

- На реплики выполняем запросы
    ```sh
    test=# \l
    
    postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
    template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
    template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
    test      | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
    
    
    
    test=# select count(*) from  test;
      1000
    
    
    test=# insert into test values ('test1');
    ERROR:  cannot execute INSERT in a read-only transaction
    ```

    ```sh
        test=# select * from pg_stat_wal_receiver \gx
        pid                   | 29
        status                | streaming
        receive_start_lsn     | 0/5000000
        receive_start_tli     | 1
        received_lsn          | 0/505A7F0
        received_tli          | 1
        last_msg_send_time    | 2020-07-25 13:25:01.372779+00
        last_msg_receipt_time | 2020-07-25 13:25:01.372895+00
        latest_end_lsn        | 0/505A7F0
        latest_end_time       | 2020-07-25 12:53:27.981209+00
        slot_name             | secondary
        sender_host           | pg-primary
        sender_port           | 5432
        conninfo              | user=replicator password=******** dbname=replication host=pg-primary port=5432 fallback_application_name=walreceiver sslmode=prefer sslcompression=0 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
    ```
  
 #Логическая репликация
  
 ## Настройка сервера публикатора
  
  - Редактируем файл postgresql.conf у pg-primary
        
     ```postgresql.conf
     wal_level = logical
      ```
 - Перезагружаем pg-primary
 
 - В публикуемой таблице должен быть настроен «репликационный идентификатор» 
 для нахождения соответствующих строк для изменения или удаления на стороне подписчика.
  По умолчанию это первичный ключ, если он создан
 
     ```sh
    ALTER TABLE test  ADD COLUMN  id serial PRIMARY key;
     ```
   
  - Роль, используемая для подключения репликации, должна иметь атрибут REPLICATION и LOGIN, 
  а что б  иметь возможность скопировать исходные данные таблицы, роль должна иметь право SELECT в публикуемой таблице
  
      ```sh
      ALTER ROLE replicator login;
    
      GRANT ALL ON test to replicator;
    ```
    
 -  В базе данных публикации создаем издателя
     ```sh
     test=# CREATE PUBLICATION test_pub FOR TABLE test;
     CREATE PUBLICATION
     ```
## Сервер подписчика

  - Редактируем файл postgresql.conf у pg-primary
        
     ```postgresql.conf
     wal_level = logical
      ```
 - Перезагружаем pg-primary

  - на сервер pg-replic создаем базу данных и таблицу
    
     ```sh
    postgres=# CREATE DATABASE test;
    CREATE DATABASE
    
    
    test=# CREATE TABLE test(id serial PRIMARY KEY, description text);
    CREATE TABLE
    ```
  
  - Создаем подписку
  
      ```sh
      test=# CREATE SUBSCRIPTION test_pg_primary CONNECTION 'dbname=test host=''pg-primary'' port=5432 user=replicator password=secret' 
      test-# PUBLICATION test_pub;
      NOTICE:  created replication slot "test_pg_primary" on publisher
      CREATE SUBSCRIPTION
     ```
    - Показанная выше команда запустит процесс репликации, который вначале синхронизирует исходное содержимого таблиц, а затем начнёт перенос инкрементальных изменений в этих таблицах.