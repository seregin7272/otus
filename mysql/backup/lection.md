# MySQL.<br> Backup & Restore.

---

## Сегодня мы разберем...

- Подходы к организации резервного копирования
- mysqldump
- xtrabackup: сценарии
    - инкрементный бэкап
    - бэкап на другую машину
    - шифрование
    - восстановление

---

## Подходы к организации резервного копирования

- Логически бэкап
    - mysqldump
    - mysqlpump
- Физически backup
    - бэкап средствами файловой системы (zfs, LVM snapshots)
    - xtrabackup

---

# mysqldump<br> демо

---

## Преимущества xtrabackup

- Онлайн бэкап без преывания работы БД (InnoDB)
- Инкрементальные бэкапы
- Потоковый бэкап на другой сервер 
- Компрессия, шифрование
- Перемещение таблице меж серверами online
- Легкое создание  новых слейвов

---

## xtrabackup

- Полный бэкап
-  1й Инкрементальный с момента полного
- 2й Инкрементальный с момента 1-го

```bash
xtrabackup --backup --target-dir=/data/backups/base
xtrabackup --backup --target-dir=/data/backups/inc1  --incremental-basedir=/data/backups/base
xtrabackup --backup --target-dir=/data/backups/inc2  --incremental-basedir=/data/backups/inc1
```

---

## Restore

- prepare - Подготовка для восстановления
- опция **apply-log-only** - обязательна для инкрементального восстановления
- подготавливаем для восстановления базовый бэкап и оба инкремента

```bash
xtrabackup --prepare --apply-log-only --target-dir=/data/backups/base
xtrabackup --prepare --apply-log-only --target-dir=/data/backups/base  --incremental-dir=/data/backups/inc1
xtrabackup --prepare --apply-log-only --taet-dir=/data/backups/base  --incremental-dir=/data/backups/inc2
xtrabackup --copy-back --target-dir=/data/backups/base
```

---

## Point-In-Time recovery

Необходимо включить binary logs
восстановление по бинари логам производится после восстановления базы и выставления нужных прав

```bash
# находим стартовую позицию для восстановления
cat /path/to/backup/xtrabackup_binlog_info

# стартуем восстановление до нужной точки
mysqlbinlog /path/to/datadir/mysql-bin.000003 /path/to/datadir/mysql-bin.000004 \ 
 --start-position=57 \
 --stop-datetime="11-12-25 01:00:00 > mybinlog.sql
```


---

## Patial backups

```bash

# бэкап конкретных таблиц
xtrabackup --backup --datadir=/var/lib/mysql --target-dir=/data/backups/ \ --tables="^test[.].*"
xtrabackup --backup --tables-file=/tmp/tables.txt

# бэкап конкретных БД (схем)
xtrabackup --databases='mysql sys performance_schema ...'

## подготовка для восстановления, опция --export
xtrabackup --prepare --export --target-dir=/path/to/partial/backup
```

---

## Partial восстановление
- необходим знать структуру таблиц ( dump)
- если восстанавливаем БД, то сначала   CREATE DATABASE
- создаем нужную таблицу
- ALTER TABLE <table_name> DISCARD TABLESPACE
- копируем файлы таблицы
- ALTER TABLE <table_name> IMPORT TABLESPACE

---
## Stream

режим STREAM направляет поток в STDOUT в формате xbstream, а STDOUT уже можно перенаправить куда угодно

```bash
# Направляем поток в файл
xtrabackup --backup --stream=xbstream --target-dir=./ > backup.xbstream

# с компрессией
xtrabackup --backup --stream=xbstream --compress --target-dir=./ > backup. xbstream

# c шифрованием
xtrabackup --backup --stream=xbstream | gzip - | openssl des3 -salt -k "password" > backup.xbstream.gz.des3
# расшифровка
openssl des3 -salt -k "password" -d -in backup.xbstream.gz.des3 -out backup.xbstream.gz
gzip -d backup.xbstream.gz

# распаковка файла xbtream
xbstream -x < backup.xbstream

```

---

## Stream на другой сервер

```bash
xtrabackup --backup --compress --stream=xbstream --target-dir=./ | ssh xtrabackup@10.51.21.42 "xbstream -x -C backup"

# Слушаем на приемщике
$ nc -l 9999 | cat - > /data/backups/backup.xbstream
# Отсылаем с сервера базы
$ xtrabackup --backup --stream=xbstream ./ | nc desthost 9999
```


---

# Ваши вопросы
