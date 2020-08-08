

create table test (
	title varchar
)


insert into test values ('test1');





-- Данные оходе репликации на славе

select * from pg_stat_wal_receiver;

select pg_last_wal_receive_lsn();

select pg_last_wal_replay_lsn();



-- Отслеживане конфликтов между мастером и репликой 

select * from pg_stat_database_conflicts;



/*
 * Настройка репликации для мастера
 */

-- Создаем слот

SELECT pg_create_physical_replication_slot('pg_slave');


SELECT * FROM pg_replication_slots;


-- wal_level = replica
-- max_wal_senders = 10
-- max_replication_slots = 10



--host    all             all             172.21.0.2/16           trust
--host    replication     all             172.21.0.2/16           trust



select pg_reload_conf();

 select pg_relation_filepath();

pg_ctl reload

pg_ctl stop



/*
 * Настройка репликации для slave
 */


 pg_basebackup -h pg-master  -U postgres -D /var/lib/postgresql/data-q

pg_basebackup -U postgres -D /var/lib/postgresql/9.6/main


pg_basebackup -h pg-master -U postgres -D /var/lib/postgresql/data-q -Fp -Xs -P -R





su postgres -c "psql"

su postgres

psql -h pg-master




