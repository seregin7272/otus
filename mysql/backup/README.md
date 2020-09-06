востановить таблицу из бэкапа
Цель: В этом ДЗ осваиваем инструмент для резервного копирования и восстановления - xtrabackup. Задача восстановить конкретную таблицу из сжатого и шифрованного бэкапа.
в материалах приложен файл бэкапа backup.xbstream.gz.des3 и дамп структуры базы otus - otus-db.dmp
бэкап был выполнен с помощью команды
xtrabackup --databases='otus' --backup --stream=xbstream | gzip - | openssl des3 -salt -k "password" > backup.xbstream.gz.des3

требуется восстановить таблицу otus.articles из бэкапа


### ДЗ


Patial backups


Делаем бекап только базы otus


Зашифровать
xtrabackup --user=root --password=root --databases='otus' --backup --stream=xbstream | gzip - | openssl des3 -salt -k "password" > backup.xbstream.gz.des3

Расшифровать
openssl des3 -salt -k "password" -d -in backup.xbstream.gz.des3 -out backup.xbstream.gz -md md5
openssl des3 -salt -k "password" -d -in backup.xbstream.gz.des3 -out backup.xbstream.gz
gzip -d backup.xbstream.gz


openssl des3 -salt -k "password" -d -in backup.xbstream.gz.des3 -out backup.xbstream.gz

##### распаковка файла xbtream
xbstream -x < backup.xbstream


##### подготовка для восстановления, опция --export
xtrabackup --prepare --export --target-dir=/backups

ALTER TABLE articles DISCARD TABLESPACE;


копируем файлы таблицы
cp  otus/articles.* /var/lib/mysql/otus/


chown -R mysql:mysql /var/lib/mysql/otus

ALTER TABLE articles IMPORT TABLESPACE


-----


ИНКРЕМЕНТАЛЬНЫЙ БЕКАП


1) xtrabackup --user=root --password=root --backup --target-dir=/backups/base
-- 10


2) xtrabackup --user=root --password=root --backup --target-dir=/backups/inc1 --incremental-basedir=/backups/base

-- 15


3) xtrabackup --user=root --password=root --backup --target-dir=/backups/inc2 --incremental-basedir=/backups/inc1
-- 25 



4) xtrabackup --user=root --password=root --backup --target-dir=/backups/inc3 --incremental-basedir=/backups/inc2
-- 5

5) xtrabackup --user=root --password=root --backup --target-dir=/backups/inc4 --incremental-basedir=/backups/inc3



ВОСТАНОВЛЕНИЕ

xtrabackup --prepare --apply-log-only --target-dir=/backups/base
xtrabackup --prepare --apply-log-only --target-dir=/backups/base --incremental-dir=/backups/inc1
xtrabackup --prepare --apply-log-only --target-dir=/backups/base --incremental-dir=/backups/inc2

xtrabackup --copy-back --target-dir=/backups/base
chown -R mysql:mysql /var/lib/mysql
