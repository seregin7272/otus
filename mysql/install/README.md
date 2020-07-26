docker-compose exec otusdb mysql -u root -psecret otus
show databases;
 CREATE USER 'otus'@'localhost' IDENTIFIED BY 'pasQp9443SH9e!';
 GRANT ALL PRIVILEGES ON *.* TO 'otus'@'localhost';

Цель: Упаковка скриптов создания БД в контейнер

1) забрать стартовый репозиторий https://github.com/erlong15/otus-mysql-docker
2) прописать sql скрипт для создания своей БД в init.sql
3) проверить запуск и работу контейнера следую описанию в репозитории
4) прописать кастомный конфиг - настроить innodb_buffer_pool и другие параметры по желанию
*) протестить сисбенчем - результат теста приложить в README

Критерии оценки: 
4 - контейнер с базой запускается, база создается
5 - также реализован кастомный конфиг
6 - приложены результаты сисбенча